# SRE / DevOps Handbook

![Repo Status](https://img.shields.io/badge/status-active-brightgreen)
![Focus](https://img.shields.io/badge/focus-SRE%20%7C%20DevOps%20%7C%20Kubernetes-blue)
![Docs](https://img.shields.io/badge/docs-runbooks%20%7C%20checklists%20%7C%20cheatsheets-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

A practical, open-source SRE and DevOps handbook containing production-readiness checklists, troubleshooting runbooks, cheat sheets, architecture diagrams, incident response templates, automation scripts, and curated learning resources.

> Inspired by practices from [Google SRE Books](https://sre.google/books/), [Microsoft Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/), [Kubernetes Documentation](https://kubernetes.io/docs/), and the [CNCF Landscape](https://landscape.cncf.io/).

---

## Table of Contents

- [Repository Structure](#repository-structure)
- [Checklists](#checklists)
- [Cheat Sheets](#cheat-sheets)
- [Runbooks](#runbooks)
- [Architecture](#architecture)
- [Documentation](#documentation)
- [Templates](#templates)
- [Scripts](#scripts)
- [Resources](#resources)
- [Topics Covered](#topics-covered)
- [Contributing](#contributing)
- [License](#license)

---

## Repository Structure

| Folder | Purpose |
|---|---|
| [`checklists/`](checklists/) | Production readiness, deployment, Kubernetes, and incident response checklists |
| [`cheatsheets/`](cheatsheets/) | Quick command references for kubectl, Git, Azure CLI, Docker, PowerShell, and PromQL |
| [`runbooks/`](runbooks/) | Step-by-step troubleshooting guides for common production issues |
| [`architecture/`](architecture/) | Architecture diagrams and design documentation (Mermaid) |
| [`docs/`](docs/) | SRE/DevOps concepts, best practices, and strategy guides |
| [`resources/`](resources/) | Official documentation links and learning paths |
| [`templates/`](templates/) | Reusable templates for runbooks, postmortems, and change requests |
| [`scripts/`](scripts/) | PowerShell automation scripts for operational tasks |

---

## Checklists

- [SRE Readiness Checklist](checklists/sre-readiness-checklist.md) — service ownership, reliability, observability, security
- [Production Deployment Checklist](checklists/production-deployment-checklist.md) — pre/post deployment validation
- [Kubernetes Production Checklist](checklists/kubernetes-production-checklist.md) — workload config, security, availability
- [Incident Response Checklist](checklists/incident-response-checklist.md) — detection through post-incident review

## Cheat Sheets

- [kubectl](cheatsheets/kubectl-cheatsheet.md) — pods, deployments, services, events, troubleshooting, RBAC
- [Git](cheatsheets/git-cheatsheet.md) — branching, merging, rebasing, stashing, undoing changes
- [Azure CLI](cheatsheets/azure-cli-cheatsheet.md) — AKS, ACR, Key Vault, VMs, networking, monitoring
- [Docker](cheatsheets/docker-cheatsheet.md) — images, containers, compose, networking, cleanup
- [PowerShell DevOps](cheatsheets/powershell-devops-cheatsheet.md) — IIS, certs, REST APIs, remote management
- [Prometheus / PromQL](cheatsheets/prometheus-promql-cheatsheet.md) — queries, aggregation, alerting rules

## Runbooks

- [Application Down](runbooks/application-down.md) — diagnose and resolve complete service outages
- [Pod CrashLoopBackOff](runbooks/pod-crashloopbackoff.md) — troubleshoot Kubernetes pod restart loops
- [High CPU / Memory](runbooks/high-cpu-memory.md) — investigate and resolve resource exhaustion
- [Disk Space Issue](runbooks/disk-space-issue.md) — identify and clean up disk space problems
- [Certificate Expiry](runbooks/certificate-expiry.md) — detect and renew expiring TLS certificates
- [Deployment Rollback](runbooks/deployment-rollback.md) — safely roll back problematic deployments

## Architecture

- [AKS Platform Architecture](architecture/aks-platform-architecture.md) — reference AKS architecture with networking, security, and observability
- [CI/CD Architecture](architecture/cicd-architecture.md) — pipeline flow with quality gates and rollback strategy
- [Observability Architecture](architecture/observability-architecture.md) — metrics, logs, traces, and alerting stack

All diagrams use [Mermaid](https://mermaid.js.org/) for native GitHub rendering — no external tools needed.

## Documentation

- [SLO, SLI, and Error Budget Guide](docs/slo-sli-error-budget.md) — defining reliability targets with error budget policy
- [Monitoring and Alerting Strategy](docs/monitoring-alerting-strategy.md) — USE, RED, Golden Signals, alert design
- [Incident Management](docs/incident-management.md) — lifecycle, severity levels, roles, communication
- [Change Management](docs/change-management.md) — change types, risk assessment, approval process
- [DevOps Best Practices](docs/devops-best-practices.md) — CI/CD, IaC, DORA metrics, DevSecOps

## Templates

- [Postmortem Template](templates/postmortem-template.md) — blameless post-incident review format
- [Runbook Template](templates/runbook-template.md) — standard runbook structure
- [Change Request Template](templates/change-request-template.md) — change request with risk assessment

## Scripts

- [Check-ServiceHealth.ps1](scripts/powershell/Check-ServiceHealth.ps1) — HTTP health check for service endpoints
- [Check-CertificateExpiry.ps1](scripts/powershell/Check-CertificateExpiry.ps1) — scan local certs for upcoming expiry
- [Get-DiskSpaceReport.ps1](scripts/powershell/Get-DiskSpaceReport.ps1) — disk usage report with threshold alerts

## Resources

- [Official Documentation Links](resources/official-documentation-links.md) — curated links to Azure, Kubernetes, Prometheus, and more
- [Learning Path](resources/learning-path.md) — beginner to advanced progression with books and certifications

---

## Topics Covered

`SRE` `DevOps` `Kubernetes` `AKS` `CI/CD` `GitHub Actions` `Azure DevOps` `Infrastructure as Code` `Bicep` `Observability` `Prometheus` `Grafana` `OpenTelemetry` `Monitoring` `Alerting` `Incident Response` `Change Management` `PowerShell` `Production Readiness` `Postmortems` `SLOs` `SLIs` `Error Budgets`

---

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Recommended Reading

- [Google SRE Books](https://sre.google/books/)
- [Microsoft Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [CNCF Cloud Native Landscape](https://landscape.cncf.io/)
- [The Phoenix Project](https://itrevolution.com/the-phoenix-project/)
- [Accelerate](https://itrevolution.com/accelerate-book/)