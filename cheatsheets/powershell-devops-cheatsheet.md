# PowerShell DevOps Cheat Sheet

## File and Directory Operations

```powershell
Get-ChildItem -Path C:\Logs -Recurse -Filter *.log
Get-Content -Path .\config.json
Set-Content -Path .\output.txt -Value "Hello"
Add-Content -Path .\output.txt -Value "Appended line"
Test-Path -Path .\file.txt
New-Item -Path .\folder -ItemType Directory
Copy-Item -Path .\source.txt -Destination .\dest.txt
Remove-Item -Path .\file.txt -Force
```

## Process and Service Management

```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
Get-Service | Where-Object { $_.Status -eq 'Running' }
Restart-Service -Name <service-name>
Stop-Service -Name <service-name>
Start-Service -Name <service-name>
Get-Service -Name <service-name> | Select-Object Name, Status, StartType
```

## IIS Management

```powershell
Import-Module WebAdministration
Get-Website
Get-WebAppPoolState -Name <pool-name>
Restart-WebAppPool -Name <pool-name>
Start-Website -Name <site-name>
Stop-Website -Name <site-name>
Get-WebBinding -Name <site-name>
```

## Certificate Management

```powershell
Get-ChildItem Cert:\LocalMachine\My
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.NotAfter -lt (Get-Date).AddDays(30) }
Get-ChildItem Cert:\LocalMachine\My | Select-Object Subject, Thumbprint, NotAfter | Sort-Object NotAfter
```

## REST API Calls

```powershell
Invoke-RestMethod -Uri "https://api.example.com/health" -Method GET
Invoke-RestMethod -Uri "https://api.example.com/data" -Method POST -Body ($body | ConvertTo-Json) -ContentType "application/json"
Invoke-WebRequest -Uri "https://example.com" -UseBasicParsing | Select-Object StatusCode
```

## JSON and Data Handling

```powershell
$data = Get-Content .\config.json | ConvertFrom-Json
$data | ConvertTo-Json -Depth 10 | Set-Content .\output.json
$data.PropertyName
$csv = Import-Csv .\data.csv
$csv | Export-Csv .\output.csv -NoTypeInformation
```

## Event Log

```powershell
Get-EventLog -LogName Application -Newest 20
Get-EventLog -LogName System -EntryType Error -Newest 10
Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2} -MaxEvents 10
```

## Remote Management

```powershell
Enter-PSSession -ComputerName <server>
Invoke-Command -ComputerName <server> -ScriptBlock { Get-Service }
Invoke-Command -ComputerName server1, server2 -ScriptBlock { hostname }
Test-Connection -ComputerName <server> -Count 2
Test-NetConnection -ComputerName <server> -Port 443
```

## Disk and System Info

```powershell
Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, LastBootUpTime, FreePhysicalMemory
Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object DeviceID, Size, FreeSpace
systeminfo | Select-String "OS Name|Total Physical Memory|Available Physical Memory"
```

## Scheduled Tasks

```powershell
Get-ScheduledTask | Where-Object { $_.State -eq 'Running' }
Start-ScheduledTask -TaskName <task-name>
Stop-ScheduledTask -TaskName <task-name>
Get-ScheduledTaskInfo -TaskName <task-name>
```

## Active Directory

```powershell
Get-ADUser -Identity <username> -Properties *
Get-ADGroup -Identity <groupname> -Properties Members
Get-ADGroupMember -Identity <groupname>
Get-ADComputer -Filter * -SearchBase "OU=Servers,DC=domain,DC=com"
```

## Error Handling

```powershell
try {
    # risky operation
} catch {
    Write-Error "Error: $_"
    $_ | Format-List -Force
} finally {
    # cleanup
}
```

## Logging Pattern

```powershell
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$Level] $Message" | Add-Content -Path .\script.log
    Write-Host "$timestamp [$Level] $Message"
}
```