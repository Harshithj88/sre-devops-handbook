# Error Budget Policy

Defines how error budgets are calculated, monitored, and enforced for production services.

## What Is an Error Budget?

An error budget is the inverse of an SLO. If a service has a **99.9% availability SLO**, the error budget is **0.1%** — meaning the service is allowed ~43 minutes of downtime per 30-day window.

| SLO Target | Error Budget (30 days) | Error Budget (90 days) |
|------------|----------------------|----------------------|
| 99.0% | 7h 12m | 21h 36m |
| 99.5% | 3h 36m | 10h 48m |
| 99.9% | 43m 12s | 2h 9m |
| 99.95% | 21m 36s | 1h 4m |
| 99.99% | 4m 19s | 12m 58s |

## How We Calculate

```
error_budget_remaining = 1 - (actual_bad_minutes / allowed_bad_minutes)
```

Where:
- `allowed_bad_minutes = window_minutes × (1 - SLO_target)`
- `actual_bad_minutes` = total minutes where the service violated the SLI

## Budget States

### Green (> 50% remaining)
- Normal operations
- Feature development proceeds at full velocity
- Deploy freely with standard approval gates

### Yellow (25–50% remaining)
- Increased caution
- All deployments require explicit SRE review
- Prioritize reliability work alongside features
- Increase monitoring frequency

### Red (< 25% remaining)
- **Feature freeze** — only reliability improvements and critical bug fixes ship
- All changes require SRE sign-off
- Postmortem required for any further budget consumption
- Daily standup on reliability status

### Exhausted (0% remaining)
- **Full deployment freeze** for non-reliability changes
- Incident-level response: dedicated team focus on restoration
- Executive escalation if freeze extends beyond 5 business days
- All pending feature work is re-prioritized behind reliability

## Monitoring

### Prometheus Queries

**Budget remaining (30-day window):**
```promql
1 - (
  (1 - (sum(rate(http_requests_total{code!~"5.."}[30d])) / sum(rate(http_requests_total[30d]))))
  /
  (1 - 0.999)
)
```

**Burn rate (how fast the budget is being consumed):**
```promql
sum(rate(http_requests_total{code=~"5.."}[1h])) / sum(rate(http_requests_total[1h]))
/
(1 - 0.999)
```

### Alert Thresholds

| Alert | Condition | Severity | Action |
|-------|-----------|----------|--------|
| Budget warning | < 50% remaining | Warning | Notify team channel |
| Budget critical | < 25% remaining | Critical | Page on-call + feature freeze |
| Fast burn | 14.4x burn rate for 1h | Critical | Page on-call immediately |
| Slow burn | 6x burn rate for 6h | Warning | Notify team lead |

## Stakeholder Responsibilities

### Engineering Team
- Owns the SLO and error budget for their services
- Decides how to spend budget (features vs. reliability)
- Implements reliability improvements when budget is yellow/red

### SRE / Platform Team
- Defines SLO measurement methodology
- Monitors budget consumption and burn rate
- Enforces deployment freezes when budget is exhausted
- Provides tooling for budget visibility (dashboards, alerts)

### Product / Management
- Respects deployment freezes as contractual obligations to users
- Balances feature velocity against reliability investment
- Participates in quarterly SLO review

## Quarterly Review

Every quarter, review:
1. Was the SLO target appropriate? (Too tight = constant freezes; too loose = poor reliability)
2. How much budget was consumed? By what?
3. Were deployment freezes effective?
4. Should targets be adjusted for the next quarter?

## Related

- [SLO Alert Rules](https://github.com/Harshithj88/aks-sre-platform-lab/blob/main/monitoring/prometheus-rules/slo-alerts.yaml)
- [Postmortem Template](https://github.com/Harshithj88/aks-sre-platform-lab/blob/main/docs/postmortem-template.md)
- [Incident Response Checklist](../checklists/incident-response-checklist.md)
