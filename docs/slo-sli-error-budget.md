# SLO, SLI, and Error Budget Guide

## Definitions

### SLI - Service Level Indicator

A measurable signal that indicates service reliability. SLIs are the metrics you use to determine whether your service is healthy.

Examples:

- Availability percentage
- Request latency (p50, p95, p99)
- Error rate
- Successful request rate
- Throughput
- Queue processing delay
- Data freshness

### SLO - Service Level Objective

A target value for an SLI over a specific time window. SLOs define "good enough" reliability for a service.

Example:

```text
99.9% of HTTP requests should complete successfully over a 30-day window.
95% of requests should complete in under 200ms over a 30-day window.
```

### SLA - Service Level Agreement

A formal contract between a service provider and a customer that defines consequences (typically financial) if SLOs are not met. SLAs are typically more lenient than internal SLOs.

### Error Budget

The allowed amount of unreliability within an SLO window. If your SLO is 99.9% availability, your error budget is 0.1%.

```text
Error Budget = 1 - SLO target

Example:
  SLO = 99.9%
  Error Budget = 0.1%
  In a 30-day window (43,200 minutes):
    Allowed downtime = 43,200 * 0.001 = 43.2 minutes
```

## Error Budget Table

| SLO Target | Error Budget | Downtime per 30 days | Downtime per year |
|---|---|---|---|
| 99% | 1% | 7.2 hours | 3.65 days |
| 99.5% | 0.5% | 3.6 hours | 1.83 days |
| 99.9% | 0.1% | 43.2 minutes | 8.77 hours |
| 99.95% | 0.05% | 21.6 minutes | 4.38 hours |
| 99.99% | 0.01% | 4.32 minutes | 52.6 minutes |

## How SLOs Drive Decisions

### Error Budget is Healthy (budget remaining)

- Deploy new features
- Run experiments
- Take on planned technical debt
- Focus on velocity

### Error Budget is Burned (budget exhausted)

- Freeze feature releases
- Focus on reliability improvements
- Investigate and fix root causes
- Improve monitoring and alerting
- Conduct postmortems

## Choosing SLIs

Pick SLIs that reflect the user experience:

| Service Type | Recommended SLIs |
|---|---|
| Web API | Availability, latency (p95/p99), error rate |
| Background worker | Processing rate, queue depth, error rate, data freshness |
| Data pipeline | Data freshness, processing latency, completeness |
| Storage system | Availability, latency, durability |
| Streaming service | Throughput, latency, message loss rate |

## Setting SLOs

1. Start with historical data — what is the service actually achieving today?
2. Align with user expectations — what level of reliability do users need?
3. Leave room for error budget — do not set SLOs at 100%
4. Review and adjust quarterly — SLOs should evolve with the service
5. Document the SLO — make it visible to all stakeholders

## Measuring SLIs

### Availability SLI

```text
Availability = (Successful Requests / Total Requests) * 100
```

### Latency SLI

```text
Latency SLI = Percentage of requests completing within threshold
Example: 95% of requests < 200ms
```

### PromQL Examples

```promql
# Availability (success rate)
sum(rate(http_requests_total{status!~"5.."}[30d]))
/
sum(rate(http_requests_total[30d]))

# Latency (percentage under threshold)
sum(rate(http_request_duration_seconds_bucket{le="0.2"}[30d]))
/
sum(rate(http_request_duration_seconds_count[30d]))
```

## Error Budget Policy

An error budget policy defines what actions to take based on remaining error budget:

| Budget Remaining | Action |
|---|---|
| > 50% | Normal feature development |
| 25% - 50% | Increased reliability focus, review recent incidents |
| 10% - 25% | Pause non-critical changes, prioritize reliability work |
| < 10% | Feature freeze, all hands on reliability |
| 0% (exhausted) | Full freeze until budget is restored |

## References

- [Google SRE Book - Service Level Objectives](https://sre.google/sre-book/service-level-objectives/)
- [Google SRE Workbook - Implementing SLOs](https://sre.google/workbook/implementing-slos/)
- [Art of SLOs](https://sre.google/resources/practices-and-processes/art-of-slos/)
