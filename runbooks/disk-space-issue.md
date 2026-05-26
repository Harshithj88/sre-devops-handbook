# Runbook: Disk Space Issue

## Purpose

This runbook provides steps to diagnose and resolve disk space issues on servers and Kubernetes nodes.

## Symptoms

- Disk usage alert fired (typically at 80%, 90%, or 95% thresholds)
- Application errors related to write failures
- Pods evicted from Kubernetes nodes due to disk pressure
- Log ingestion failures
- Database write failures

## Impact

Low disk space can cause application failures, data loss, pod evictions, and complete service outage if the disk becomes full.

## Initial Checks

### Linux / Kubernetes Node

```bash
# Check disk usage
df -h

# Check disk usage for specific mount
df -h /var

# Find largest directories
du -sh /* 2>/dev/null | sort -rh | head -20

# Check inode usage
df -i
```

### Windows Server

```powershell
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{N='Used(GB)';E={[math]::Round($_.Used/1GB,2)}}, @{N='Free(GB)';E={[math]::Round($_.Free/1GB,2)}}

# Find large files
Get-ChildItem -Path C:\ -Recurse -File -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 20 FullName, @{N='Size(MB)';E={[math]::Round($_.Length/1MB,2)}}
```

### Kubernetes

```bash
# Check node conditions for disk pressure
kubectl describe node <node-name> | grep -A5 "Conditions"

# Check PVC usage
kubectl get pvc -A
kubectl exec <pod-name> -n <namespace> -- df -h
```

## Investigation Steps

### 1. Identify what is consuming disk space

Common culprits:

- **Log files** — application logs, IIS logs, system logs growing unbounded
- **Temp files** — build artifacts, cache files, temporary downloads
- **Container images** — unused images filling up container runtime storage
- **Database files** — transaction logs, data files growing
- **Core dumps** — crash dumps consuming space

### 2. Check log directories

```bash
# Linux
du -sh /var/log/*
ls -lhS /var/log/ | head -20

# Check container logs
du -sh /var/lib/docker/containers/*/
```

```powershell
# Windows - IIS logs
Get-ChildItem C:\inetpub\logs -Recurse | Measure-Object -Property Length -Sum
Get-ChildItem C:\inetpub\logs -Recurse -File | Sort-Object Length -Descending | Select-Object -First 10 FullName, @{N='Size(MB)';E={[math]::Round($_.Length/1MB,2)}}
```

### 3. Check for unused Docker/container resources

```bash
docker system df
docker image ls --format "{{.Size}}\t{{.Repository}}:{{.Tag}}" | sort -rh
```

## Resolution Steps

### Clean up log files

```bash
# Truncate a large log file (keeps file handle open)
truncate -s 0 /var/log/large-file.log

# Remove old log files (older than 7 days)
find /var/log -name "*.log" -mtime +7 -delete
```

```powershell
# Remove IIS logs older than 30 days
Get-ChildItem C:\inetpub\logs -Recurse -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force
```

### Clean up container resources

```bash
# Remove unused Docker resources
docker system prune -a --volumes

# Remove dangling images
docker image prune -a
```

### Clean up temp files

```bash
# Linux
rm -rf /tmp/old-files-*
```

```powershell
# Windows
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
```

### Expand disk (if cleanup is insufficient)

- For Azure VMs: expand the managed disk via Azure portal or CLI
- For Kubernetes PVCs: expand the PVC if the storage class supports it
- For on-premises: coordinate with infrastructure team

## Prevention

- Configure log rotation for all application and system logs
- Set up disk usage alerts at 80% and 90% thresholds
- Implement automated cleanup jobs for temp files and old logs
- Set container log max-size limits in Docker daemon configuration
- Review disk usage trends in monitoring dashboards regularly

## Post-Incident Follow-Up

- [ ] Root cause of disk growth identified
- [ ] Log rotation configured if missing
- [ ] Automated cleanup job created if needed
- [ ] Disk usage alert thresholds reviewed
- [ ] Disk sizing reviewed for adequacy
- [ ] Update this runbook
