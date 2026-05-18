# SLO, SLI, and Error Budget Guide

## Definitions

### SLI - Service Level Indicator

A measurable signal that indicates service reliability.

Examples:

- Availability percentage
- Request latency
- Error rate
- Successful request rate
- Queue processing delay

### SLO - Service Level Objective

A target value for an SLI over a specific time window.

Example:

```text
99.9% of HTTP requests should complete successfully over a 30-day window.