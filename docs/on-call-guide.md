# On-Call Engineer Guide

## Purpose

This guide defines expectations, responsibilities, and best practices for engineers participating in on-call rotations. A well-structured on-call program is a cornerstone of reliable service operations.

## On-Call Responsibilities

### Before Your Shift

- [ ] Review the on-call handoff notes from the previous engineer
- [ ] Verify you have access to all required systems (monitoring, alerting, VPN, cloud consoles)
- [ ] Confirm alerting notifications are reaching you (phone, Slack, PagerDuty)
- [ ] Review any ongoing incidents or known issues
- [ ] Check the maintenance calendar for scheduled changes during your rotation
- [ ] Ensure your laptop is charged and you have reliable internet access

### During Your Shift

- **Acknowledge alerts** within the defined SLA (typically 5 minutes for SEV1/SEV2)
- **Triage** — determine severity, scope, and whether it needs immediate action
- **Communicate** — update the incident channel, status page, and stakeholders
- **Mitigate** — follow runbooks, apply known fixes, escalate when stuck
- **Document** — log actions taken, timeline of events, and resolution steps
- **Hand off** — brief the next on-call engineer on any active or unresolved issues

### After Your Shift

- [ ] Write handoff notes for the incoming engineer
- [ ] File tickets for any toil or reliability improvements discovered
- [ ] Contribute to postmortems for incidents during your rotation
- [ ] Update runbooks with new knowledge gained

## Severity Levels and Response Times

| Severity | Description | Acknowledge | Respond | Examples |
|---|---|---|---|---|
| SEV1 | Complete outage, data loss, security breach | 5 min | 15 min | Service down, data corruption, active exploit |
| SEV2 | Major degradation affecting many users | 15 min | 30 min | High error rate, significant latency, partial outage |
| SEV3 | Minor degradation with limited impact | 30 min | 2 hours | Slow performance for subset of users, non-critical feature broken |
| SEV4 | Low urgency, cosmetic, or informational | 1 hour | Next business day | Warning thresholds, non-urgent maintenance |

## Escalation Guidelines

### When to Escalate

- You cannot diagnose the issue within 30 minutes
- The issue involves a system you don't have access to or expertise in
- A SEV1 or SEV2 incident needs more hands
- The blast radius is expanding
- You need approval for a risky mitigation (e.g., database changes, rollback)

### How to Escalate

1. Contact the next-level on-call or the relevant team's on-call
2. Provide: **what** is broken, **who** is affected, **what** you've tried, **what** you need
3. Stay engaged — you remain the incident coordinator until someone else takes over
4. Document the escalation in the incident channel

## Triage Workflow

```text
Alert Fired
  │
  ├── Is it a known false positive? → Silence alert, file ticket to fix
  │
  ├── Is it informational / warning? → Monitor, acknowledge, note in handoff
  │
  ├── Is there an existing runbook? → Follow the runbook
  │
  ├── Can you diagnose it? → Investigate, mitigate, resolve
  │
  └── Cannot diagnose / out of scope → Escalate to the owning team
```

## Alert Hygiene

### Good Alerts

- **Actionable** — every alert should have a clear next step or runbook
- **Relevant** — alerts fire for conditions that need human intervention
- **Timely** — alerts detect issues before users notice
- **Scoped** — alerts tell you which service, environment, and component

### Alert Anti-Patterns

- **Alert fatigue** — too many low-priority or noisy alerts; on-call ignores them
- **Missing runbook** — alert fires but nobody knows what to do
- **Overly sensitive** — threshold is too tight, causing false positives
- **Stale alerts** — alert references a service or component that no longer exists

If you encounter any of these during your rotation, file a ticket to fix them.

## On-Call Health

### Sustainable On-Call

- Maximum **one week on, at least two weeks off** rotation
- On-call engineers should not carry more than **two pages per shift** on average
- If page volume is consistently high, invest in reliability and alert tuning
- On-call compensation or time-off-in-lieu should be defined by your organization

### Burnout Signals

- Dreading on-call shifts
- Ignoring alerts or delaying response
- Consistently interrupted sleep
- Feeling unsupported or unable to escalate

Raise these concerns with your manager. On-call should be manageable, not miserable.

## Tools Checklist

Ensure you have access to and are familiar with:

| Category | Tools |
|---|---|
| Alerting | PagerDuty, Opsgenie, or equivalent |
| Monitoring | Grafana, Prometheus, Azure Monitor, Datadog |
| Logging | Log Analytics, Kibana, Splunk |
| Communication | Slack/Teams incident channel, status page |
| Access | VPN, cloud console, Kubernetes clusters, database tools |
| Runbooks | This handbook, internal wiki, team runbooks |

## References

- [Google SRE Book - Being On-Call](https://sre.google/sre-book/being-on-call/)
- [Google SRE Workbook - On-Call](https://sre.google/workbook/on-call/)
- [PagerDuty Incident Response Guide](https://response.pagerduty.com/)
