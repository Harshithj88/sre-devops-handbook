# Incident Response Checklist

## Detection and Triage

- [ ] Alert acknowledged within SLA
- [ ] Incident severity assessed (SEV1/SEV2/SEV3/SEV4)
- [ ] Incident channel or bridge created
- [ ] Incident commander assigned
- [ ] Initial scope of impact determined
- [ ] Affected services identified
- [ ] Number of affected users estimated

## Communication

- [ ] Stakeholders notified of the incident
- [ ] Status page updated (if applicable)
- [ ] Communication cadence established (every 15/30/60 minutes)
- [ ] Customer-facing communication drafted (if applicable)
- [ ] Management notified for SEV1/SEV2

## Investigation

- [ ] Recent changes and deployments reviewed
- [ ] Monitoring dashboards checked
- [ ] Application logs reviewed
- [ ] Infrastructure health verified
- [ ] Dependency health verified
- [ ] Error messages and stack traces analyzed
- [ ] Timeline of events documented

## Mitigation

- [ ] Mitigation strategy identified
- [ ] Rollback executed (if deployment-related)
- [ ] Service restarted (if applicable)
- [ ] Scaling applied (if resource-related)
- [ ] Configuration corrected (if config-related)
- [ ] Workaround applied (if root fix not immediately available)
- [ ] Service health validated after mitigation

## Resolution

- [ ] Root cause identified
- [ ] Permanent fix applied or scheduled
- [ ] All affected services verified healthy
- [ ] Monitoring confirms metrics are normal
- [ ] No related alerts firing
- [ ] Stakeholders notified of resolution

## Post-Incident

- [ ] Incident timeline documented
- [ ] Incident ticket updated and closed
- [ ] Post-incident review scheduled (within 48 hours for SEV1/SEV2)
- [ ] Postmortem document created
- [ ] Action items created with owners and due dates
- [ ] Runbook updated with lessons learned
- [ ] Monitoring gaps identified and addressed
- [ ] Communication retrospective completed
