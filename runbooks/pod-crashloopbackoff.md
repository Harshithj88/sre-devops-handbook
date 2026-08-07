# Runbook: Kubernetes Pod CrashLoopBackOff

## Purpose

This runbook helps troubleshoot Kubernetes pods stuck in `CrashLoopBackOff`.

## Symptoms

- Pod repeatedly restarts
- Application is unavailable
- Deployment rollout does not complete
- Logs show application startup failure

## Initial Checks

```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
```

## Common Causes

- Application configuration issue
- Missing secret or ConfigMap
- Incorrect environment variable
- Failed dependency connection
- Application startup exception
- Insufficient CPU or memory
- Bad container image
- Failing liveness probe
- OOMKilled due to memory limits

## Investigation Steps

### 1. Check pod status

```bash
kubectl get pod <pod-name> -n <namespace> -o wide
```

### 2. Review pod events

```bash
kubectl describe pod <pod-name> -n <namespace>
```

Look for:
- Back-off restarting failed container
- ImagePullBackOff
- OOMKilled
- FailedMount
- Unhealthy
- Probe failures

### 3. Check previous container logs

```bash
kubectl logs <pod-name> -n <namespace> --previous
```

### 4. Check deployment configuration

```bash
kubectl describe deployment <deployment-name> -n <namespace>
```

Validate:
- Image tag
- Environment variables
- Secret references
- ConfigMap references
- Resource requests and limits
- Liveness and readiness probes

### 5. Check resource usage

```bash
kubectl top pod <pod-name> -n <namespace>
```

## Resolution Options

Depending on the root cause:
- Fix missing configuration
- Restore missing secret or ConfigMap
- Correct environment variables
- Increase memory or CPU limits
- Fix application startup error
- Correct probe configuration
- Roll back to the previous working deployment

## Rollback

```bash
kubectl rollout history deployment/<deployment-name> -n <namespace>
kubectl rollout undo deployment/<deployment-name> -n <namespace>
kubectl rollout status deployment/<deployment-name> -n <namespace>
```

## Post-Incident Follow-Up

- Add alert for repeated pod restarts
- Improve startup logging
- Add deployment smoke test
- Validate secrets/config before deployment
- Update this runbook with the confirmed root cause