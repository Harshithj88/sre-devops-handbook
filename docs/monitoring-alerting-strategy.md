# Monitoring and Alerting Strategy

## Overview

Effective monitoring and alerting is the foundation of reliable operations. The goal is to detect issues before users are impacted and provide actionable information for rapid resolution.

## The Three Pillars of Observability

| Pillar | Purpose | Tools |
|---|---|---|
| Metrics | Numeric measurements over time (CPU, latency, error rate) | Prometheus, Azure Monitor, Datadog |
| Logs | Event-level details and application output | Loki, ELK Stack, Azure Log Analytics |
| Traces | Request flow across distributed services | Jaeger, Tempo, Application Insights |

## What to Monitor

### Infrastructure

- CPU utilization
- Memory utilization
- Disk usage and I/O
- Network throughput and errors
- Node health and availability

### Application

- Request rate (throughput)
- Error rate (4xx, 5xx)
- Latency (p50, p95, p99)
- Saturation (queue depth, thread pool usage)
- Health endpoint status

### Business

- Transaction volume
- Conversion rate
- Revenue-impacting errors
- User-facing error pages

## The USE Method (Infrastructure)

For every resource, check:

| Signal | Description |
|---|---|
| **U**tilization | Percentage of resource capacity being used |
| **S**aturation | Amount of work queued or waiting |
| **E**rrors | Count of error events |

## The RED Method (Services)

For every service, monitor:

| Signal | Description |
|---|---|
| **R**ate | Requests per second |
| **E**rrors | Failed requests per second |
| **D**uration | Latency distribution (histograms) |

## The Four Golden Signals (Google SRE)

| Signal | Description |
|---|---|
| Latency | Time to serve a request |
| Traffic | Demand on the system |
| Errors | Rate of failed requests |
| Saturation | How full the system is |

## Alerting Best Practices

### Alert on Symptoms, Not Causes

- **Good**: "Error rate exceeds 5% for the last 5 minutes"
- **Bad**: "CPU usage above 80%"

CPU can be high without user impact. Alert on what users experience.

### Make Alerts Actionable

Every alert should answer:

1. **What** is broken?
2. **Who** should respond?
3. **How** should they investigate? (link to runbook)

### Avoid Alert Fatigue

- Remove alerts that are never acted on
- Tune thresholds based on historical data
- Use severity levels appropriately
- Aggregate related alerts
- Suppress during planned maintenance windows

### Alert Severity Levels

| Level | Criteria | Notification |
|---|---|---|
| Critical (P1) | User-facing impact, immediate action needed | Page on-call engineer |
| Warning (P2) | Potential issue, action needed soon | Notify team channel |
| Info (P3) | Notable event, no immediate action | Dashboard or log only |

## Dashboard Design

### Overview Dashboard

- Service health status (up/down)
- Key SLI metrics (availability, latency, error rate)
- Recent deployments
- Active alerts

### Service Dashboard

- Request rate and error rate
- Latency percentiles (p50, p95, p99)
- Resource usage (CPU, memory)
- Dependency health
- Pod/instance count

### Infrastructure Dashboard

- Node CPU, memory, disk usage
- Network throughput
- Cluster autoscaler activity
- Pod scheduling and eviction events

## Alert Examples

### Prometheus Alert Rules

```yaml
groups:
  - name: application-alerts
    rules:
      - alert: HighErrorRate
        expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Error rate above 5%"
          runbook: "https://wiki/runbooks/high-error-rate"

      - alert: HighLatency
        expr: histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m]))) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "P95 latency above 1 second"

      - alert: PodRestarting
        expr: increase(kube_pod_container_status_restarts_total[1h]) > 3
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Pod {{ $labels.pod }} restarting frequently"
```

## On-Call Best Practices

- Rotate on-call duties fairly across the team
- Provide clear escalation paths
- Maintain up-to-date runbooks for all alerts
- Track on-call load and alert volume
- Conduct regular on-call handoff meetings
- Compensate on-call engineers appropriately

## References

- [Google SRE Book - Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [USE Method](https://www.brendangregg.com/usemethod.html)
- [RED Method](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
