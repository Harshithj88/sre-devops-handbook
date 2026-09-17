# Runbook: Kubernetes CrashLoopBackOff

## Overview

A pod in `CrashLoopBackOff` means the container is starting, crashing, and being restarted repeatedly by kubelet with exponential back-off delays (10s, 20s, 40s, up to 5 minutes).

## When to Use

- Alert fires: "Pod CrashLoopBackOff" or "Container restart count > threshold"
- `kubectl get pods` shows `CrashLoopBackOff` status

## Triage Steps

### 1. Identify the Affected Pod

```bash
# Find crashing pods across all namespaces
kubectl get pods -A --field-selector=status.phase!=Running | grep -i crash

# Or in a specific namespace
kubectl get pods -n <namespace> | grep CrashLoopBackOff
```

### 2. Get Pod Details

```bash
kubectl describe pod <pod-name> -n <namespace>
```

Key fields to check:
- **Last State** → termination reason, exit code, signal
- **Events** → OOMKilled, FailedScheduling, image pull errors
- **Restart Count** → how many times it has restarted

### 3. Check Container Logs

```bash
# Current (may be empty if crash is immediate)
kubectl logs <pod-name> -n <namespace> -c <container-name>

# Previous crashed instance
kubectl logs <pod-name> -n <namespace> -c <container-name> --previous

# Follow logs during next restart
kubectl logs <pod-name> -n <namespace> -c <container-name> -f
```

### 4. Common Exit Codes

| Exit Code | Meaning | Likely Cause |
|-----------|---------|-------------|
| 0 | Success | Container completed but `restartPolicy: Always` restarts it |
| 1 | Application error | Unhandled exception, missing config, bad startup |
| 126 | Permission denied | File not executable |
| 127 | Command not found | Wrong entrypoint/CMD or missing binary in image |
| 137 | SIGKILL (OOMKilled) | Out of memory — increase memory limits |
| 139 | SIGSEGV | Segmentation fault — application bug |
| 143 | SIGTERM | Graceful shutdown requested but timed out |

---

## Root Cause Categories

### A. OOMKilled (Exit Code 137)

```bash
# Confirm OOM
kubectl describe pod <pod-name> -n <namespace> | grep -A5 "Last State"
# Look for: Reason: OOMKilled
```

**Fix:**
```yaml
resources:
  limits:
    memory: "512Mi"  # Increase this
  requests:
    memory: "256Mi"
```

### B. Configuration Error

Application can't start due to missing env vars, secrets, or config files.

```bash
# Check environment variables
kubectl exec <pod-name> -n <namespace> -- env | sort

# Check mounted secrets/configmaps
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.volumes[*].name}'
```

**Fix:** Verify ConfigMap/Secret exists and has correct keys.

### C. Image Issues

```bash
# Check image pull status
kubectl describe pod <pod-name> -n <namespace> | grep -A3 "Events"
# Look for: ErrImagePull, ImagePullBackOff
```

**Fix:**
- Verify image tag exists in registry
- Check imagePullSecrets for private registries
- Ensure ACR/registry is accessible from the cluster

### D. Liveness Probe Failure

The container starts but the liveness probe fails, causing kubelet to kill it.

```bash
kubectl describe pod <pod-name> -n <namespace> | grep -A10 "Liveness"
```

**Fix:**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30  # Increase if app needs more startup time
  periodSeconds: 10
  failureThreshold: 5      # Allow more failures before restart
```

### E. Dependency Unavailable

App crashes because a database, message queue, or upstream API is down.

```bash
# Check if the dependency is reachable from the pod's network
kubectl exec <running-pod-in-same-ns> -- curl -sf <dependency-url>
kubectl exec <running-pod-in-same-ns> -- nslookup <service-name>
```

**Fix:** Add retry logic to app startup, or use init containers to wait for dependencies.

---

## Quick Debug Commands

```bash
# Get all events sorted by time
kubectl get events -n <namespace> --sort-by=.lastTimestamp | tail -20

# Exec into a running container for debugging
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh

# Run a debug container (if main container won't start)
kubectl debug <pod-name> -n <namespace> -it --image=busybox --target=<container-name>

# Check resource usage
kubectl top pods -n <namespace>

# View pod YAML for full spec
kubectl get pod <pod-name> -n <namespace> -o yaml
```

## Escalation

If the issue cannot be resolved within 30 minutes:

1. Check if this is a known deployment issue (recent releases, config changes)
2. Roll back to the last known good deployment
3. Escalate to the application team with logs and `kubectl describe` output
4. Update the incident channel with findings

## Prevention

- Set appropriate resource requests and limits
- Use readiness probes (separate from liveness) to prevent traffic before app is ready
- Add `initialDelaySeconds` to liveness probes for slow-starting apps
- Test container startup locally with `docker run` before deploying
- Use `PodDisruptionBudget` to prevent mass restarts during node drains

## Related

- [Kubernetes Production Checklist](../checklists/kubernetes-production-checklist.md)
- [Incident Response Checklist](../checklists/incident-response-checklist.md)
