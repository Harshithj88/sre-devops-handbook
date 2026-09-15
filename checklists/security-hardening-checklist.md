# Security Hardening Checklist

Pre-production security review for Azure infrastructure, Kubernetes workloads, and CI/CD pipelines.

## Azure Infrastructure

- [ ] **TLS 1.2+ enforced** — Disable TLS 1.0/1.1 on all endpoints (App Services, Storage, SQL)
- [ ] **Network segmentation** — VNet isolation with NSGs; deny-all default rules
- [ ] **Private endpoints** — Key Vault, Storage, SQL, ACR accessible only via private link
- [ ] **No public IPs on workloads** — Use Azure Front Door, Application Gateway, or Load Balancer as ingress
- [ ] **Managed identities** — Replace service principal secrets with system/user-assigned managed identities
- [ ] **Key Vault for secrets** — No secrets in app settings, environment variables, or code
- [ ] **RBAC scoped roles** — Least-privilege role assignments per resource group, not subscription
- [ ] **Azure Policy** — Deny public IP creation, enforce tagging, restrict VM SKUs
- [ ] **Diagnostic settings** — All resources send logs to Log Analytics workspace
- [ ] **Delete locks** — Production resource groups protected with CanNotDelete locks
- [ ] **Disk encryption** — OS and data disks encrypted at rest (Azure Disk Encryption or SSE)

## Kubernetes / AKS

- [ ] **Non-root containers** — `runAsNonRoot: true`, `runAsUser: 1000` in security context
- [ ] **Read-only root filesystem** — `readOnlyRootFilesystem: true`
- [ ] **Seccomp profile** — `RuntimeDefault` or custom profile applied
- [ ] **Resource limits** — CPU and memory limits set on all containers
- [ ] **Network policies** — Namespace-level ingress/egress rules (Calico or Azure NPM)
- [ ] **Pod Security Standards** — Enforce `restricted` or `baseline` at namespace level
- [ ] **Image scanning** — Trivy, Defender for Containers, or equivalent in CI pipeline
- [ ] **Private ACR** — Images pulled from private registry with digest pinning
- [ ] **RBAC** — Kubernetes RBAC with least-privilege service accounts; no `cluster-admin` for workloads
- [ ] **Secrets management** — Use CSI Secret Store driver or External Secrets Operator, not plain K8s secrets
- [ ] **Admission controllers** — OPA Gatekeeper or Kyverno for policy enforcement

## CI/CD Pipelines

- [ ] **OIDC authentication** — GitHub Actions / Azure DevOps use federated identity, not stored secrets
- [ ] **Branch protections** — Require PR reviews, status checks, and signed commits on main
- [ ] **Environment approvals** — Manual approval gates for production deployments
- [ ] **Dependency scanning** — Dependabot, Snyk, or GitHub Advanced Security enabled
- [ ] **SAST scanning** — SonarQube, CodeQL, or Semgrep on pull requests
- [ ] **Secret scanning** — GitHub secret scanning or pre-commit hooks to prevent credential leaks
- [ ] **Immutable artifacts** — Build once, deploy to all environments from the same artifact
- [ ] **Audit trail** — All deployments logged with who, what, when, and approval chain

## Identity & Access

- [ ] **MFA enforced** — All human accounts require multi-factor authentication
- [ ] **Service accounts audited** — Regular review of service account permissions and rotation
- [ ] **gMSA for Windows services** — Group Managed Service Accounts instead of static passwords
- [ ] **Conditional Access** — Location and device-based policies for privileged access
- [ ] **PIM for elevated roles** — Just-in-time activation for Owner, Contributor, Admin roles
- [ ] **Break-glass accounts** — Documented and monitored emergency access accounts

## Monitoring & Incident Response

- [ ] **Alert on auth failures** — Failed logins, permission denied, and token expiry alerts
- [ ] **Alert on resource changes** — Azure Activity Log alerts for critical resource modifications
- [ ] **Runbooks documented** — Incident response procedures for common failure scenarios
- [ ] **On-call rotation** — Defined escalation paths with PagerDuty, OpsGenie, or equivalent
- [ ] **Postmortem process** — Blameless postmortem template and regular review cadence
