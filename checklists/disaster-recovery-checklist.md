# Disaster Recovery Checklist

## DR Planning

- [ ] Recovery Point Objective (RPO) defined for all critical services
- [ ] Recovery Time Objective (RTO) defined for all critical services
- [ ] Critical services and dependencies identified and documented
- [ ] DR runbooks exist for each critical service
- [ ] DR plan reviewed and updated at least annually
- [ ] DR contacts and escalation paths documented

## Backup Verification

- [ ] Database backups running on schedule
- [ ] Backup retention policy meets RPO requirements
- [ ] Backup restoration tested within the last quarter
- [ ] Backup integrity verified (checksum, test restore)
- [ ] Backups stored in a geographically separate region
- [ ] Backup encryption enabled and keys securely managed
- [ ] Application configuration and secrets backed up
- [ ] Infrastructure as Code templates version-controlled and current

## Infrastructure Readiness

- [ ] Secondary region or failover environment provisioned
- [ ] DNS failover or traffic manager configured
- [ ] Load balancer health checks configured for automatic failover
- [ ] Database replication to DR site active and healthy
- [ ] Replication lag monitored and within acceptable thresholds
- [ ] Network connectivity between primary and DR verified
- [ ] Certificates and secrets available in DR environment
- [ ] Container images available in DR region registry

## Data Recovery

- [ ] Restore procedure documented step-by-step
- [ ] Point-in-time recovery tested for databases
- [ ] Data consistency checks defined for post-recovery validation
- [ ] Application-level data integrity verification procedure exists
- [ ] Partial recovery procedures documented (single service, single database)

## Application Recovery

- [ ] Application deployment procedure to DR environment documented
- [ ] Feature flags or circuit breakers available to degrade gracefully
- [ ] Dependency order for service startup documented
- [ ] Health check endpoints available for all services
- [ ] Smoke tests defined for post-recovery validation
- [ ] Static assets and CDN failover configured

## Communication

- [ ] Internal communication plan defined (who to notify, channels)
- [ ] External communication plan defined (status page, customer email)
- [ ] Stakeholder contact list current and accessible offline
- [ ] Status page or incident communication tool ready
- [ ] Communication templates drafted for common DR scenarios

## DR Testing

- [ ] Full DR failover test conducted within the last 12 months
- [ ] Tabletop exercise conducted within the last 6 months
- [ ] Partial failover test (single service) conducted within the last quarter
- [ ] Recovery time measured and compared against RTO
- [ ] Recovery point measured and compared against RPO
- [ ] Test results documented with gaps and action items
- [ ] Action items from previous DR tests resolved

## Post-Failover Verification

- [ ] All critical services responding and healthy
- [ ] Data integrity verified (record counts, checksums, recent transactions)
- [ ] Monitoring and alerting active in DR environment
- [ ] Log aggregation functioning in DR environment
- [ ] External integrations reconnected and verified
- [ ] Performance baseline acceptable in DR environment
- [ ] DNS propagation confirmed for all customer-facing endpoints

## Failback Planning

- [ ] Failback procedure documented
- [ ] Data sync from DR back to primary planned
- [ ] Failback testing scheduled
- [ ] Communication plan for failback defined
- [ ] Verification steps for primary environment readiness documented

## Reference Targets

| Tier | RPO | RTO | Examples |
|---|---|---|---|
| Tier 1 — Critical | < 1 hour | < 1 hour | Payment processing, authentication, core API |
| Tier 2 — Important | < 4 hours | < 4 hours | Reporting, notifications, internal tools |
| Tier 3 — Standard | < 24 hours | < 24 hours | Dev/test environments, batch jobs |
| Tier 4 — Low | < 72 hours | < 72 hours | Archives, documentation sites |
