# Runbook: Application Down

## Purpose

This runbook provides steps to diagnose and resolve an application that is completely unresponsive or returning errors to all users.

## Symptoms

- Application returns HTTP 5xx errors or does not respond
- Health check endpoint is failing
- Users report inability to access the application
- Monitoring alerts for availability or uptime fired

## Impact

Complete service outage affecting all users of the application.

## Initial Checks

```bash
# Check if the application endpoint is responding
curl -s -o /dev/null -w "%{http_code}" https://<app-url>/health

# Check DNS resolution
nslookup <app-url>

# Check network connectivity
Test-NetConnection -ComputerName <app-url> -Port 443
```

## Investigation Steps

### 1. Check application pods or processes

```bash
# Kubernetes
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --tail=100

# IIS (Windows)
Get-Website
Get-WebAppPoolState -Name <pool-name>
```

### 2. Check recent deployments

```bash
kubectl rollout history deployment/<deployment-name> -n <namespace>
```

Has a deployment happened recently? If yes, consider rolling back.

### 3. Check dependencies

- Database connectivity
- External API dependencies
- Message queue availability
- Cache service health
- DNS resolution

### 4. Check infrastructure

```bash
# Kubernetes nodes
kubectl get nodes
kubectl top nodes

# Check events
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

### 5. Check load balancer and ingress

```bash
kubectl get ingress -n <namespace>
kubectl describe ingress <ingress-name> -n <namespace>
kubectl get svc -n <namespace>
```

### 6. Check certificates

```bash
# Check certificate expiry
echo | openssl s_client -servername <app-url> -connect <app-url>:443 2>/dev/null | openssl x509 -noout -dates
```

## Resolution Options

| Root Cause | Resolution |
|---|---|
| Bad deployment | Roll back to previous version |
| Pod crash loop | Check logs, fix config, restart |
| Resource exhaustion | Scale up pods or nodes |
| Dependency failure | Verify and restore dependency |
| Certificate expired | Renew certificate |
| DNS issue | Verify DNS records |
| Infrastructure failure | Engage infrastructure team |

## Rollback

```bash
kubectl rollout undo deployment/<deployment-name> -n <namespace>
kubectl rollout status deployment/<deployment-name> -n <namespace>
```

## Escalation

| Role | Contact |
|---|---|
| Application Owner | [Team/Contact] |
| Platform/Infrastructure | [Team/Contact] |
| Database | [Team/Contact] |
| Network | [Team/Contact] |

## Post-Incident Follow-Up

- [ ] Document incident timeline
- [ ] Identify root cause
- [ ] Create postmortem
- [ ] Add or improve alerting
- [ ] Update this runbook