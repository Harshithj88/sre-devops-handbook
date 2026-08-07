# GitHub Actions Cheat Sheet

## Workflow Basics

```yaml
# .github/workflows/ci.yml
name: CI Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:        # manual trigger

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: echo "Building..."
```

## Triggers

```yaml
# Push to specific branches
on:
  push:
    branches: [main, release/*]
    paths: ['src/**', '!docs/**']

# Scheduled (cron)
on:
  schedule:
    - cron: '0 6 * * 1'    # every Monday at 06:00 UTC

# Manual with inputs
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options: [dev, staging, production]

# On tag creation
on:
  push:
    tags: ['v*']
```

## Job Configuration

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm test

  deploy:
    needs: test               # depends on test job
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production   # requires approval
    steps:
      - uses: actions/checkout@v4
      - run: echo "Deploying..."
```

## Environment Variables and Secrets

```yaml
env:
  GLOBAL_VAR: "available to all steps"

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      JOB_VAR: "available to all steps in this job"
    steps:
      - name: Use secrets
        env:
          API_KEY: ${{ secrets.API_KEY }}
          TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: echo "Using secrets safely"

      - name: Set output
        id: step1
        run: echo "version=1.2.3" >> "$GITHUB_OUTPUT"

      - name: Use output
        run: echo "Version is ${{ steps.step1.outputs.version }}"
```

## Caching

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-

# Built-in caching with setup actions
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: 'npm'
```

## Artifacts

```yaml
# Upload artifact
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/
    retention-days: 5

# Download artifact (in another job)
- uses: actions/download-artifact@v4
  with:
    name: build-output
    path: dist/
```

## Reusable Workflows

```yaml
# .github/workflows/reusable-deploy.yml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      deploy-key:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - run: echo "Deploying to ${{ inputs.environment }}"

# Calling workflow
jobs:
  deploy-staging:
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
    secrets:
      deploy-key: ${{ secrets.DEPLOY_KEY }}
```

## Composite Actions

```yaml
# .github/actions/setup-project/action.yml
name: Setup Project
description: Install dependencies and build
runs:
  using: composite
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: 20
        cache: 'npm'
    - run: npm ci
      shell: bash
    - run: npm run build
      shell: bash
```

## Conditional Execution

```yaml
steps:
  - name: Only on main
    if: github.ref == 'refs/heads/main'
    run: echo "Main branch"

  - name: Only on PR
    if: github.event_name == 'pull_request'
    run: echo "Pull request"

  - name: Only on success
    if: success()
    run: echo "Previous steps passed"

  - name: Always run (cleanup)
    if: always()
    run: echo "Runs even if previous steps fail"

  - name: Only on failure
    if: failure()
    run: echo "Something failed"
```

## Container Jobs

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: node:20-alpine
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: testpass
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

## Common Patterns

### Docker Build and Push

```yaml
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
```

### Azure Login

```yaml
- uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

### Status Checks and Concurrency

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true    # cancel previous runs on same branch
```

## Useful Expressions

| Expression | Description |
|---|---|
| `${{ github.sha }}` | Full commit SHA |
| `${{ github.ref_name }}` | Branch or tag name |
| `${{ github.run_number }}` | Auto-incrementing run number |
| `${{ github.actor }}` | User who triggered the workflow |
| `${{ github.repository }}` | Owner/repo name |
| `${{ runner.os }}` | Runner OS (Linux, Windows, macOS) |
| `${{ job.status }}` | Current job status |
| `${{ github.event.pull_request.number }}` | PR number |

## Debugging

```yaml
# Enable debug logging (set as repo secret)
# ACTIONS_RUNNER_DEBUG = true
# ACTIONS_STEP_DEBUG = true

# Or pass via workflow
env:
  ACTIONS_STEP_DEBUG: true
```

```bash
# Download workflow logs via CLI
gh run view <run-id> --log
gh run list --workflow=ci.yml --limit=5
gh run rerun <run-id>
```

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)
- [Reusable Workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows)
- [Security Hardening](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
