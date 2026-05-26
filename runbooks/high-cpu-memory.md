# Runbook: High CPU or Memory Usage

## Purpose

This runbook provides steps to diagnose and resolve high CPU or memory usage on servers and Kubernetes workloads.

## Symptoms

- CPU or memory usage alert fired
- Application response times increased
- Pods being OOMKilled in Kubernetes
- Server becoming unresponsive
- Users reporting slow performance

## Impact

High resource usage can cause degraded application performance, request timeouts, pod evictions, and complete service unavailability.

## Initial Checks

### Kubernetes

```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods -n <namespace> --sort-by=cpu
kubectl top pods -n <namespace> --sort-by=memory

# Check for OOMKilled pods
kubectl get pods -n <namespace> -o json | jq '.items[] | select(.status.containerStatuses[]?.lastState.terminated.reason=="OOMKilled") | .metadata.name'

# Check pod resource requests and limits
kubectl describe pod <pod-name> -n <namespace> | grep -A3 "Requests\|Limits"
```

### Linux

```bash
# Top processes by CPU
top -bn1 | head -20
ps aux --sort=-%cpu | head -10

# Top processes by memory
ps aux --sort=-%mem | head -10

# System memory overview
free -h
vmstat 1 5
```

### Windows

```powershell
# Top processes by CPU
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, @{N='Memory(MB)';E={[math]::Round($_.WorkingSet64/1MB,2)}}

# System memory
Get-CimInstance Win32_OperatingSystem | Select-Object @{N='TotalMemory(GB)';E={[math]::Round($_.TotalVisibleMemorySize/1MB,2)}}, @{N='FreeMemory(GB)';E={[math]::Round($_.FreePhysicalMemory/1MB,2)}}

# Check IIS worker process memory
Get-Process w3wp -ErrorAction SilentlyContinue | Select-Object Id, @{N='Memory(MB)';E={[math]::Round($_.WorkingSet64/1MB,2)}}, CPU
```

## Investigation Steps

### 1. Identify the offending process or pod

- Which process or pod is consuming the most resources?
- Is this a gradual increase (memory leak) or sudden spike (traffic burst)?
- Did a recent deployment happen?

### 2. Check for recent changes

```bash
# Check recent deployments
kubectl rollout history deployment/<deployment-name> -n <namespace>

# Check recent events
kubectl get events -n <namespace> --sort-by=.lastTimestamp | tail -20
```

### 3. Check application metrics

- Review application-level metrics (request rate, error rate, queue depth)
- Check for traffic spikes or unusual request patterns
- Review garbage collection metrics if applicable

### 4. Check resource limits

```bash
# Are resource limits set appropriately?
kubectl get deployment <deployment-name> -n <namespace> -o jsonpath='{.spec.template.spec.containers[*].resources}'
```

## Resolution Steps

### Scale up (immediate relief)

```bash
# Scale horizontally
kubectl scale deployment <deployment-name> --replicas=<count> -n <namespace>

# If HPA is configured, check its status
kubectl get hpa -n <namespace>
```

### Restart the workload

```bash
# Kubernetes
kubectl rollout restart deployment/<deployment-name> -n <namespace>

# Windows service
Restart-Service -Name <service-name>

# IIS app pool
Restart-WebAppPool -Name <pool-name>
```

### Increase resource limits

```bash
kubectl edit deployment <deployment-name> -n <namespace>
# Increase memory limits or CPU limits as needed
```

### Roll back if caused by recent deployment

```bash
kubectl rollout undo deployment/<deployment-name> -n <namespace>
```

## Common Root Causes

| Cause | Indicator | Resolution |
|---|---|---|
| Memory leak | Gradual memory increase over time | Fix application code, restart as temporary mitigation |
| Traffic spike | Sudden CPU increase, correlated with request rate | Scale out, enable autoscaling |
| Inefficient query | High CPU on database or API pod | Optimize query, add caching |
| Missing resource limits | Pod consuming all node resources | Set appropriate requests and limits |
| Noisy neighbor | Other pods on same node consuming resources | Use resource quotas, node affinity |
| Garbage collection | CPU spikes in Java/.NET apps | Tune GC settings, increase heap size |

## Prevention

- Set resource requests and limits on all workloads
- Configure Horizontal Pod Autoscaler for variable workloads
- Set up alerts for CPU > 80% and memory > 80% sustained for 5+ minutes
- Monitor for OOMKilled events
- Profile applications for memory leaks during development
- Review resource usage trends weekly

## Post-Incident Follow-Up

- [ ] Root cause identified
- [ ] Resource limits adjusted if needed
- [ ] Autoscaling configured if appropriate
- [ ] Application code fix deployed if memory leak
- [ ] Monitoring and alerting improved
- [ ] Update this runbook
