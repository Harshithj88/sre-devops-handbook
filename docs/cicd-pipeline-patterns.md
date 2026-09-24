# CI/CD Pipeline Patterns

A reference of proven pipeline patterns for building, testing, and deploying applications and infrastructure safely.

## Core Principles

- **Fail fast** — Run cheap, fast checks (lint, unit tests) before expensive ones (integration, deploy)
- **Shift left on security** — Scan code, dependencies, and IaC in the pipeline, not after deploy
- **Immutable artifacts** — Build once, promote the same artifact through environments
- **Everything as code** — Pipelines, infrastructure, and policy live in version control
- **Least privilege** — Use OIDC/federated identity instead of long-lived secrets

---

## Pattern 1: Build Once, Promote Everywhere

Build a single immutable artifact and promote it across environments. Never rebuild per environment.

```
Build → Test → Package (tag: git-sha) → Deploy Dev → Deploy QA → Deploy Prod
                     │
                     └─ same image digest promoted through all stages
```

**Why:** Guarantees what you tested is what you ship. Eliminates "works in QA, breaks in prod" from build drift.

**Implementation:**
- Tag container images with the immutable Git SHA, not `latest`
- Store artifacts in a registry (ACR) with retention policies
- Environment-specific config comes from ConfigMaps/Key Vault, not the image

---

## Pattern 2: Progressive Delivery

Reduce blast radius by rolling out changes gradually.

| Strategy | Description | Best For |
|----------|-------------|----------|
| **Rolling** | Replace pods incrementally | Stateless services (default) |
| **Blue-Green** | Full parallel environment, switch traffic | Fast rollback, DB-compatible changes |
| **Canary** | Route small % of traffic to new version | High-risk changes, gradual validation |
| **Feature flags** | Decouple deploy from release | Runtime toggles, A/B testing |

**Canary example (Argo Rollouts):**
```yaml
strategy:
  canary:
    steps:
      - setWeight: 10
      - pause: { duration: 5m }
      - setWeight: 50
      - pause: { duration: 10m }
      - setWeight: 100
```

---

## Pattern 3: Pipeline Stages (Reference)

```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│   Validate  │──▶│    Build    │──▶│    Test     │──▶│   Deploy    │
└─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘
 - lint            - compile         - unit tests      - IaC plan/what-if
 - fmt check       - build image     - integration     - deploy
 - secret scan     - SBOM            - security scan   - smoke tests
                                     - coverage gate    - health checks
```

### Stage details

**Validate**
- Linting (ESLint, PSScriptAnalyzer, tflint)
- Format check (`terraform fmt -check`, `prettier`)
- Secret scanning (gitleaks, trufflehog)

**Build**
- Compile / build container image
- Generate SBOM (Software Bill of Materials)
- Sign artifacts (cosign, Notary)

**Test**
- Unit tests with coverage gate (fail below threshold)
- Integration tests against ephemeral environment
- Security scan (Trivy, Checkov, Snyk)

**Deploy**
- IaC dry-run (`terraform plan`, `az deployment what-if`)
- Deploy with approval gate for production
- Post-deploy smoke tests and health checks
- Automated rollback on failure

---

## Pattern 4: GitOps

Git is the single source of truth; a controller (Argo CD, Flux) reconciles cluster state to match the repo.

```
Developer → PR → main branch → Argo CD/Flux detects change → syncs cluster
```

**Benefits:**
- Declarative, auditable, self-healing
- Rollback = `git revert`
- No cluster credentials in CI (controller pulls, CI doesn't push)

**Repo structure:**
```
├── apps/            # application manifests
├── infrastructure/  # cluster add-ons (ingress, cert-manager)
└── environments/
    ├── dev/
    ├── qa/
    └── prod/        # separate overlays with Kustomize
```

---

## Pattern 5: Deployment Gates & Approvals

| Gate | Environment | Purpose |
|------|-------------|---------|
| Automated tests | All | Block on test/coverage failure |
| Security scan | All | Block on CRITICAL/HIGH findings |
| Manual approval | Prod | Human sign-off for production |
| Change window | Prod | Enforce deployment windows |
| SLO check | Prod | Block deploy if error budget exhausted |

---

## Anti-Patterns to Avoid

- **Rebuilding per environment** — introduces drift; build once instead
- **`latest` tags** — non-deterministic; use immutable SHA tags
- **Secrets in pipeline variables** — use OIDC + Key Vault references
- **Snowflake pipelines** — copy-pasted YAML; use reusable templates/workflows
- **No rollback plan** — every deploy must have a tested rollback path
- **Skipping staging** — never let prod be the first real test

---

## Reusable Workflow Example (GitHub Actions)

```yaml
# .github/workflows/reusable-deploy.yml
on:
  workflow_call:
    inputs:
      environment: { required: true, type: string }
    secrets:
      AZURE_CLIENT_ID: { required: true }

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    permissions:
      id-token: write   # OIDC
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          # ... tenant-id, subscription-id
      - run: ./deploy.sh ${{ inputs.environment }}
```

## Related

- [DevOps Best Practices](devops-best-practices.md)
- [Change Management](change-management.md)
- [SLO/SLI Error Budget](slo-sli-error-budget.md)
