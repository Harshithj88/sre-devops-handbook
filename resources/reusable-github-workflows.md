# Reusable GitHub Actions Workflows

Patterns for standardizing CI/CD across many repositories using `workflow_call` reusable workflows and composite actions. Centralizing this logic removes copy-pasted YAML and makes org-wide changes a single-PR operation.

## Why Reusable Workflows

- **DRY** — Define build/test/deploy logic once, call it from many repos
- **Governance** — Enforce security scans and approvals centrally
- **Maintainability** — Update one file instead of dozens of pipelines
- **Consistency** — Every service follows the same quality gates

---

## 1. Reusable Build + Test

Define a reusable workflow in a shared repo (e.g. `my-org/shared-workflows`). Key structure:

- Trigger on `workflow_call`
- Expose `inputs` for things that vary per repo (node version, working directory, coverage threshold)
- Expose an `outputs` block that surfaces the computed image tag so callers can promote it

Inside the single `build` job, the ordered steps are:

1. Checkout the repository
2. Set up the language toolchain with dependency caching
3. Install dependencies from the lockfile
4. Run the linter
5. Run tests with a coverage gate derived from the `coverage-threshold` input
6. Compute a short git-SHA tag and write it to the job output

The caller references the reusable workflow by tag:

```text
jobs:
  build-test:
    uses: my-org/shared-workflows/.github/workflows/reusable-build-test.yml@v1
    with:
      node-version: "20"
      coverage-threshold: 85
```

---

## 2. Reusable Deploy (OIDC to Azure)

A deploy reusable workflow should:

- Accept `environment` and `image-tag` as required `inputs`
- Accept the three Azure identifiers as required `secrets` (client, tenant, subscription)
- Request `id-token: write` permission so federated OIDC login works
- Bind the job to a GitHub `environment`, which enables protection rules and required reviewers

Step order inside the `deploy` job:

1. Checkout
2. Azure login via OIDC (no stored client secret)
3. Run the deploy script, passing the environment and the promoted image tag
4. Run a smoke test against the freshly deployed environment

---

## 3. Promotion: Build Once, Deploy Everywhere

A CD pipeline chains the reusable workflows and threads the **same** image tag through each environment:

```text
jobs:
  build-test:
    uses: my-org/shared-workflows/.github/workflows/reusable-build-test.yml@v1

  deploy-dev:
    needs: build-test
    uses: my-org/shared-workflows/.github/workflows/reusable-deploy.yml@v1
    with:
      environment: dev
      image-tag: ${{ needs.build-test.outputs.image-tag }}
    secrets: inherit

  deploy-prod:
    needs: [build-test, deploy-dev]
    uses: my-org/shared-workflows/.github/workflows/reusable-deploy.yml@v1
    with:
      environment: prod
      image-tag: ${{ needs.build-test.outputs.image-tag }}
    secrets: inherit
```

`deploy-prod` depends on `deploy-dev`, promoting the identical artifact tag rather than rebuilding — this guarantees what you tested is what ships.

---

## 4. Composite Action: Security Scan

For logic reused *within* a job (rather than a whole job), a composite action is lighter weight than a reusable workflow. A security-scan composite action typically:

- Declares `using: composite` with an input for the scan path
- Runs an IaC/filesystem scanner (Trivy, Checkov, or tfsec) producing SARIF output
- Uploads the SARIF to the GitHub Security tab via the CodeQL upload action

Consumers reference it as a single step:

```text
      - uses: my-org/shared-actions/security-scan@v1
        with:
          scan-path: ./src
```

---

## Versioning Reusable Workflows

- Tag the shared repo with semantic versions (`v1`, `v1.2.0`)
- Reference by tag (`@v1`) for stability, or by commit SHA for full immutability
- Maintain a moving major tag (`v1`) that you advance for backward-compatible updates
- Document breaking changes and bump the major tag deliberately

## Best Practices

- Pin third-party actions to a SHA or exact version, never `@main`
- Use `secrets: inherit` sparingly; prefer explicit secret passing for clarity
- Keep inputs minimal and well-defaulted
- Add least-privilege `permissions` blocks (default to `contents: read`)
- Gate production deploys with GitHub Environments and required reviewers

## Related

- [CI/CD Pipeline Patterns](../docs/cicd-pipeline-patterns.md)
- [CI/CD Architecture](../architecture/cicd-architecture.md)
