# Runbook: Deployment Rollback

## Purpose

This runbook provides steps to safely roll back a deployment when issues are detected after a release.

## Symptoms

- Increased error rate after a deployment
- Application health check failures
- Performance degradation following a release
- New bugs or regressions reported by users
- Pods failing to start with new image version

## Impact

Degraded or unavailable service for users due to a problematic deployment.

## Decision Criteria

Roll back if any of the following are true:

- [ ] Error rate exceeds acceptable threshold (e.g., > 1% of requests returning 5xx)
- [ ] Health endpoint is failing
- [ ] Critical functionality is broken
- [ ] Performance has degraded beyond SLO thresholds
- [ ] Data corruption risk exists
- [ ] Fix cannot be deployed within the acceptable time window

## Rollback Steps

### Kubernetes Deployment

```bash
# Check rollout history
kubectl rollout history deployment/<deployment-name> -n <namespace>

# Roll back to previous version
kubectl rollout undo deployment/<deployment-name> -n <namespace>

# Roll back to a specific revision
kubectl rollout undo deployment/<deployment-name> -n <namespace> --to-revision=<revision>

# Monitor rollback progress
kubectl rollout status deployment/<deployment-name> -n <namespace>

# Verify pods are running with previous image
kubectl get pods -n <namespace> -o jsonpath='{.items[*].spec.containers[*].image}'
```

### Azure App Service

```bash
# List deployment slots
az webapp deployment slot list --resource-group <rg> --name <app> --output table

# Swap back to previous slot
az webapp deployment slot swap --resource-group <rg> --name <app> --slot staging --target-slot production
```

### Pipeline-Based Rollback

1. Identify the last known-good artifact version
2. Trigger the deployment pipeline with the previous version
3. Monitor deployment progress
4. Validate application health after rollback

## Post-Rollback Validation

- [ ] Application health endpoint returns 200
- [ ] Error rate has returned to normal levels
- [ ] Key functionality is working
- [ ] No data inconsistencies from the failed deployment
- [ ] Monitoring dashboards show normal metrics
- [ ] Stakeholders have been notified

## Communication

1. Notify the team that a rollback is in progress
2. Update the change request or incident ticket
3. Communicate status to stakeholders once rollback is complete
4. Schedule a postmortem if the rollback was due to a significant issue

## Root Cause Investigation

After rollback is complete and service is stable:

1. Review deployment logs for the failed release
2. Compare configuration between old and new versions
3. Check for missing environment variables or secrets
4. Review recent code changes in the release
5. Verify database migration compatibility
6. Document findings

## Post-Incident Follow-Up

- [ ] Root cause identified
- [ ] Fix developed and tested
- [ ] Deployment validation improved (e.g., smoke tests, canary)
- [ ] Rollback process reviewed and updated
- [ ] Postmortem completed
- [ ] Update this runbook