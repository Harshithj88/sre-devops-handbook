```mermaid
flowchart TD
    App[Application] --> Metrics[Metrics]
    App --> Logs[Logs]
    App --> Traces[Traces]

    Metrics --> Prometheus[Prometheus]
    Logs --> Loki[Loki / Log Analytics]
    Traces --> Tempo[Tempo / OpenTelemetry Collector]

    Prometheus --> Grafana[Grafana Dashboards]
    Loki --> Grafana
    Tempo --> Grafana

    Prometheus --> AlertManager[Alertmanager]
    AlertManager --> OnCall[On-Call Engineer]
```

## Observability Signals

| Signal | Purpose |
|---|---|
| Metrics | Numeric measurements such as CPU, memory, latency, error rate |
| Logs | Event and application-level details |
| Traces | Request flow across distributed services |
| Alerts | Notifications for actionable reliability issues |