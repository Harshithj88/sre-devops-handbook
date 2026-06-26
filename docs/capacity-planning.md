# Capacity Planning Guide

## Purpose

Capacity planning ensures that infrastructure and application resources can handle current workloads and anticipated growth without degradation. It bridges the gap between reactive firefighting and proactive reliability.

## Key Concepts

### Capacity vs. Performance

| Term | Definition |
|---|---|
| **Capacity** | The maximum amount of work a system can handle |
| **Performance** | How fast or efficiently a system handles work |
| **Headroom** | The gap between current usage and capacity limits |
| **Saturation** | The degree to which a resource is being utilized |

Running at high saturation leaves no room for traffic spikes, deployments, or failure recovery. Aim for **sufficient headroom** at all times.

### The USE Method

For every resource (CPU, memory, disk, network), check:

| Signal | Question | Example Metric |
|---|---|---|
| **Utilization** | How busy is it? | CPU usage %, memory usage % |
| **Saturation** | Is work queuing? | CPU run queue length, swap usage |
| **Errors** | Are failures occurring? | Disk I/O errors, network packet drops |

## Capacity Planning Process

### 1. Inventory Current Resources

Document what you have:

```text
Service: order-api
Environment: Production
  Instances:     4 pods (2 CPU, 4Gi memory each)
  Database:      Azure SQL S3 (100 DTU)
  Cache:         Redis C2 (6 GB)
  Storage:       50 GB managed disk
  Network:       Internal LB, 1 Gbps VNet
```

### 2. Measure Current Usage

Collect baseline metrics over a representative period (at least 2 weeks, including peak days):

```promql
# CPU utilization by pod
avg(rate(container_cpu_usage_seconds_total{namespace="production", pod=~"order-api.*"}[5m])) by (pod)

# Memory usage by pod
avg(container_memory_working_set_bytes{namespace="production", pod=~"order-api.*"}) by (pod)

# Request rate
sum(rate(http_requests_total{service="order-api"}[5m]))

# Request latency p95
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service="order-api"}[5m])) by (le))
```

### 3. Identify Growth Trends

```text
Current peak:       1,200 requests/sec
3-month trend:      +15% per month
Projected in 6 mo:  2,800 requests/sec
Current capacity:   2,000 requests/sec (load test result)
Action needed:      Yes — will exceed capacity in ~3 months
```

### 4. Model Scenarios

Plan for at least three scenarios:

| Scenario | Assumptions | Action |
|---|---|---|
| **Steady state** | Current growth rate continues | Scale incrementally |
| **Spike event** | 3x traffic (sale, marketing campaign, viral event) | Pre-scale, autoscaler tuning |
| **Failure mode** | Lose one AZ or 50% of nodes | Verify N+1 redundancy |

### 5. Set Capacity Thresholds

| Resource | Warning | Critical | Action |
|---|---|---|---|
| CPU | 60% sustained | 80% sustained | Scale horizontally or vertically |
| Memory | 70% sustained | 85% sustained | Scale or optimize memory usage |
| Disk | 70% used | 85% used | Expand disk or archive data |
| Database DTU/vCores | 65% sustained | 80% sustained | Scale database tier |
| Connection pool | 70% used | 90% used | Increase pool size or add instances |

## Autoscaling

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: order-api
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: order-api
  minReplicas: 3
  maxReplicas: 12
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 25
          periodSeconds: 120
```

### Cluster Autoscaler

```bash
# Check cluster autoscaler status
kubectl get configmap -n kube-system cluster-autoscaler-status -o yaml

# Check pending pods (waiting for nodes)
kubectl get pods --all-namespaces --field-selector=status.phase=Pending
```

### Autoscaling Is Not a Substitute for Planning

Autoscalers react to load — they don't predict it. If your application takes 5 minutes to start, and traffic doubles in 30 seconds, autoscaling alone won't save you. Combine autoscaling with:

- Pre-scaling before known events
- Adequate minimum replica counts
- Fast container startup times
- Connection draining and graceful shutdown

## Load Testing

Validate capacity assumptions with load tests before they matter:

```bash
# Example with k6
k6 run --vus 100 --duration 5m load-test.js

# Example with hey
hey -n 10000 -c 100 https://api.example.com/orders

# Example with Artillery
artillery run load-test.yml
```

### What to Measure During Load Tests

- Request throughput (req/sec)
- Latency percentiles (p50, p95, p99)
- Error rate at load
- CPU, memory, and disk utilization
- Database connection count and query latency
- Autoscaler response time and accuracy

## Capacity Review Cadence

| Activity | Frequency |
|---|---|
| Review resource utilization dashboards | Weekly |
| Update capacity projections | Monthly |
| Conduct load test for critical services | Quarterly |
| Full capacity planning review | Semi-annually |
| Pre-event capacity assessment | Before any major event |

## References

- [Google SRE Book - Software Engineering in SRE](https://sre.google/sre-book/software-engineering-in-sre/)
- [USE Method - Brendan Gregg](https://www.brendangregg.com/usemethod.html)
- [Kubernetes Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [k6 Load Testing](https://k6.io/docs/)
