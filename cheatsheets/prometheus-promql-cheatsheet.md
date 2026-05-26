# Prometheus / PromQL Cheat Sheet

## Basic Queries

```promql
# Instant vector - current value of a metric
up

# Filter by label
up{job="kubernetes-pods"}

# Filter by multiple labels
http_requests_total{method="GET", status="200"}

# Regex match
http_requests_total{status=~"5.."}

# Negative regex match
http_requests_total{status!~"2.."}
```

## Rate and Increase

```promql
# Per-second rate over 5 minutes
rate(http_requests_total[5m])

# Per-second rate (for sparse/slow counters)
irate(http_requests_total[5m])

# Total increase over a time range
increase(http_requests_total[1h])
```

## Aggregation

```promql
# Sum across all instances
sum(rate(http_requests_total[5m]))

# Sum grouped by a label
sum by (namespace) (rate(http_requests_total[5m]))

# Average across instances
avg(rate(http_requests_total[5m]))

# Max value
max by (pod) (container_memory_usage_bytes)

# Count number of time series
count(up{job="app"})

# Top 5 by value
topk(5, rate(http_requests_total[5m]))

# Bottom 5 by value
bottomk(5, rate(http_requests_total[5m]))
```

## CPU and Memory (Kubernetes)

```promql
# CPU usage per pod
sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="production"}[5m]))

# Memory usage per pod
sum by (pod) (container_memory_working_set_bytes{namespace="production"})

# CPU request utilization
sum by (pod) (rate(container_cpu_usage_seconds_total[5m]))
/
sum by (pod) (kube_pod_container_resource_requests{resource="cpu"})

# Memory request utilization
sum by (pod) (container_memory_working_set_bytes)
/
sum by (pod) (kube_pod_container_resource_requests{resource="memory"})

# Node CPU utilization
1 - avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))

# Node memory utilization
1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
```

## HTTP Metrics

```promql
# Request rate by status code
sum by (status) (rate(http_requests_total[5m]))

# Error rate (5xx)
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))

# 99th percentile latency
histogram_quantile(0.99, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))

# 95th percentile latency
histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))

# 50th percentile (median) latency
histogram_quantile(0.50, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))

# Average latency
rate(http_request_duration_seconds_sum[5m])
/
rate(http_request_duration_seconds_count[5m])
```

## Kubernetes Pod Health

```promql
# Pod restart count
sum by (pod, namespace) (kube_pod_container_status_restarts_total)

# Pods not ready
kube_pod_status_ready{condition="false"}

# Pods in CrashLoopBackOff
kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff"}

# Pods pending
kube_pod_status_phase{phase="Pending"}

# Container OOMKilled
kube_pod_container_status_last_terminated_reason{reason="OOMKilled"}
```

## Disk

```promql
# Disk usage percentage
(node_filesystem_size_bytes - node_filesystem_avail_bytes)
/
node_filesystem_size_bytes * 100

# PVC usage (if available)
kubelet_volume_stats_used_bytes
/
kubelet_volume_stats_capacity_bytes * 100
```

## Useful Functions

| Function | Description |
|---|---|
| `rate()` | Per-second average rate of increase over time range |
| `irate()` | Instant rate based on last two data points |
| `increase()` | Total increase over time range |
| `histogram_quantile()` | Calculate percentile from histogram |
| `sum()` | Sum values across series |
| `avg()` | Average values |
| `max()` / `min()` | Maximum or minimum value |
| `count()` | Count number of series |
| `topk()` / `bottomk()` | Top or bottom K series by value |
| `absent()` | Returns 1 if metric is missing (useful for alerts) |
| `changes()` | Number of times a value changed in a range |
| `delta()` | Difference between first and last value in range |

## Alert Rule Examples

```yaml
# High error rate
- alert: HighErrorRate
  expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.05
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "Error rate above 5%"

# Pod CrashLooping
- alert: PodCrashLooping
  expr: increase(kube_pod_container_status_restarts_total[1h]) > 5
  for: 10m
  labels:
    severity: warning
  annotations:
    summary: "Pod {{ $labels.pod }} is crash looping"

# High memory usage
- alert: HighMemoryUsage
  expr: container_memory_working_set_bytes / container_spec_memory_limit_bytes > 0.9
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Memory usage above 90%"
```