# Kubernetes Production Checklist

## Workload Configuration

- [ ] Resource requests are defined
- [ ] Resource limits are defined
- [ ] Liveness probe is configured
- [ ] Readiness probe is configured
- [ ] Startup probe is configured if needed
- [ ] Pod disruption budget is configured
- [ ] Horizontal pod autoscaler is configured
- [ ] Deployment strategy is defined

## Security

- [ ] Containers run as non-root where possible
- [ ] Privileged containers are avoided
- [ ] Secrets are not stored in plain text
- [ ] RBAC permissions are least privilege
- [ ] Network policies are configured where required
- [ ] Container images are scanned
- [ ] Image tags are pinned and not using `latest`

## Availability

- [ ] Multiple replicas are configured
- [ ] Pods are spread across nodes
- [ ] Node pool sizing is reviewed
- [ ] Cluster autoscaler is considered
- [ ] Critical workloads have disruption protection
- [ ] Ingress/load balancer health is validated

## Observability

- [ ] Application exposes metrics
- [ ] Logs are shipped to centralized logging
- [ ] Dashboards are available
- [ ] Alerts exist for pod restarts
- [ ] Alerts exist for high CPU/memory
- [ ] Alerts exist for failed deployments
- [ ] Alerts exist for unavailable endpoints