# Runbook: IIS Application Issues

## Purpose

This runbook covers troubleshooting common IIS application issues on Windows servers: app pool crashes, 503 errors, high memory, hung worker processes, and deployment failures.

## Symptoms

- Application returns HTTP 503 Service Unavailable
- App pool stops unexpectedly or enters a rapid-fail state
- High memory or CPU from `w3wp.exe` worker processes
- Requests queue and time out
- Site unavailable after deployment

## Initial Checks

```powershell
# Check app pool state
Import-Module WebAdministration
Get-ChildItem IIS:\AppPools | Select-Object Name, State, @{N='PID';E={(Get-ChildItem "IIS:\AppPools\$($_.Name)\WorkerProcesses" -ErrorAction SilentlyContinue).processId}}

# Check site state
Get-Website | Select-Object Name, State, PhysicalPath

# Check event logs for W3SVC errors
Get-WinEvent -LogName System -FilterXPath "*[System[Provider[@Name='WAS'] and (Level=1 or Level=2 or Level=3)]]" -MaxEvents 20 | Format-Table TimeCreated, Message -Wrap

# Check application event log
Get-WinEvent -LogName Application -FilterXPath "*[System[(Level=1 or Level=2) and TimeCreated[timediff(@SystemTime) <= 3600000]]]" -MaxEvents 20
```

## Common Causes

- **App pool crash** — unhandled exception, stack overflow, access violation
- **Rapid fail protection** — app pool disabled after too many crashes in a short window
- **Memory leak** — worker process exceeding private memory limit
- **Deadlock** — hung requests blocking the thread pool
- **Bad deployment** — missing DLL, config error, binding conflict
- **Certificate issue** — expired or missing HTTPS certificate
- **Permission issue** — app pool identity lacks file system or registry access

## Investigation Steps

### 1. App pool stopped

```powershell
# Check if rapid fail protection triggered
Get-ItemProperty "IIS:\AppPools\<AppPoolName>" | Select-Object name, state, failure

# Check failure settings
Get-ItemProperty "IIS:\AppPools\<AppPoolName>" -Name failure | Format-List

# Restart the app pool
Start-WebAppPool -Name "<AppPoolName>"
```

### 2. HTTP 503 errors

```powershell
# Check HTTP.sys error log for rejection reason
Get-Content C:\Windows\System32\LogFiles\HTTPERR\httperr*.log -Tail 50

# Common reasons: AppOffline, ConnLimit, AppPool (pool stopped), Timer_ConnectionIdle
```

### 3. High memory / CPU

```powershell
# Check w3wp process memory
Get-Process w3wp -ErrorAction SilentlyContinue | Select-Object Id, WorkingSet64, CPU, StartTime | Format-Table @{N='PID';E={$_.Id}}, @{N='MemoryMB';E={[math]::Round($_.WorkingSet64/1MB)}}, CPU, StartTime

# Map PID to app pool
Get-ChildItem IIS:\AppPools | ForEach-Object {
    $wp = Get-ChildItem "IIS:\AppPools\$($_.Name)\WorkerProcesses" -ErrorAction SilentlyContinue
    if ($wp) { [PSCustomObject]@{ AppPool = $_.Name; PID = $wp.processId } }
}

# Check current requests (hung requests)
Get-ChildItem "IIS:\AppPools\<AppPoolName>\WorkerProcesses" | ForEach-Object {
    $_.GetRequests(0) | Where-Object { $_.timeElapsed -gt 30000 } | Select-Object url, timeElapsed, verb
}
```

### 4. Post-deployment failure

```powershell
# Verify the physical path is correct
(Get-Website -Name "<SiteName>").PhysicalPath

# Check if app_offline.htm is present (blocks all requests)
Test-Path "<DeployPath>\app_offline.htm"

# Verify web.config is valid
[xml](Get-Content "<DeployPath>\web.config")

# Check bindings
Get-WebBinding -Name "<SiteName>"
```

### 5. Certificate issues

```powershell
# Check HTTPS binding certificate
Get-ChildItem IIS:\SslBindings | Select-Object Host, Port, @{N='Thumbprint';E={$_.Thumbprint}}, @{N='Expires';E={(Get-ChildItem "Cert:\LocalMachine\My\$($_.Thumbprint)").NotAfter}}

# Verify certificate exists and is valid
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.NotAfter -lt (Get-Date) } | Select-Object Subject, NotAfter
```

## Resolution Actions

| Issue | Action |
|---|---|
| App pool stopped | `Start-WebAppPool -Name "<Name>"` |
| Rapid fail lockout | Reset failure count: `Set-ItemProperty "IIS:\AppPools\<Name>" -Name failure.rapidFailProtection -Value $false` (temporarily) |
| Memory leak | Recycle the app pool: `Restart-WebAppPool -Name "<Name>"` |
| Hung requests | Full IIS restart: `iisreset /restart` |
| Bad deployment | Roll back: restore backup, restart site |
| Missing DLL | Check deployment artifacts, re-deploy |
| Expired cert | Install new certificate, update binding |
| Permission issue | Grant app pool identity access to the path |

## Rollback

```powershell
# Stop the site
Stop-Website -Name "<SiteName>"

# Restore from backup
Copy-Item -Path "<BackupPath>\*" -Destination "<DeployPath>" -Recurse -Force

# Start the site
Start-Website -Name "<SiteName>"

# Verify
Invoke-WebRequest -Uri "https://localhost/<path>" -UseBasicParsing
```

## Post-Incident Follow-Up

- Review event logs for root cause
- Add monitoring for app pool crashes and recycles
- Set memory-based recycling if memory leak suspected
- Review rapid fail protection thresholds
- Add pre-deploy config validation to the pipeline
- Update this runbook with confirmed root cause
