# Helm Cheat Sheet

## Repository Management

```bash
# Add a chart repository
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repository index
helm repo update

# List configured repositories
helm repo list

# Search for charts in repositories
helm search repo nginx
helm search repo bitnami/postgresql --versions

# Search Artifact Hub
helm search hub prometheus
```

## Chart Information

```bash
# Show chart metadata
helm show chart bitnami/nginx

# Show default values
helm show values bitnami/nginx

# Show all chart info (README, values, chart.yaml)
helm show all bitnami/nginx

# Download chart without installing
helm pull bitnami/nginx
helm pull bitnami/nginx --untar
helm pull bitnami/nginx --version 15.0.0
```

## Install and Upgrade

```bash
# Install a chart
helm install my-release bitnami/nginx -n my-namespace

# Install with custom values file
helm install my-release bitnami/nginx -f custom-values.yaml

# Install with inline value overrides
helm install my-release bitnami/nginx --set replicaCount=3 --set service.type=ClusterIP

# Install and wait for pods to be ready
helm install my-release bitnami/nginx --wait --timeout 5m

# Install in dry-run mode (preview without applying)
helm install my-release bitnami/nginx --dry-run

# Upgrade an existing release
helm upgrade my-release bitnami/nginx -f updated-values.yaml

# Upgrade or install if not present
helm upgrade --install my-release bitnami/nginx -f values.yaml

# Upgrade with atomic (auto-rollback on failure)
helm upgrade my-release bitnami/nginx --atomic --timeout 5m
```

## Release Management

```bash
# List all releases
helm list -n my-namespace
helm list --all-namespaces

# List all releases including failed/pending
helm list --all

# Get release status
helm status my-release -n my-namespace

# Get release history
helm history my-release -n my-namespace

# Get computed values for a release
helm get values my-release -n my-namespace

# Get all release information
helm get all my-release -n my-namespace

# Get rendered manifests
helm get manifest my-release -n my-namespace
```

## Rollback

```bash
# Rollback to previous revision
helm rollback my-release -n my-namespace

# Rollback to a specific revision
helm rollback my-release 3 -n my-namespace

# Rollback and wait for completion
helm rollback my-release 3 --wait --timeout 5m
```

## Uninstall

```bash
# Uninstall a release
helm uninstall my-release -n my-namespace

# Uninstall but keep release history
helm uninstall my-release --keep-history
```

## Chart Development

```bash
# Create a new chart scaffold
helm create my-chart

# Lint a chart for issues
helm lint ./my-chart

# Render templates locally (without cluster)
helm template my-release ./my-chart -f values.yaml

# Render and show a specific template
helm template my-release ./my-chart -s templates/deployment.yaml

# Package a chart into a .tgz archive
helm package ./my-chart

# Validate chart against a cluster (dry-run server-side)
helm install my-release ./my-chart --dry-run --debug
```

## Chart Structure

```text
my-chart/
├── Chart.yaml          # Chart metadata (name, version, dependencies)
├── Chart.lock          # Locked dependency versions
├── values.yaml         # Default configuration values
├── values.schema.json  # JSON schema for values validation (optional)
├── templates/          # Kubernetes manifest templates
│   ├── _helpers.tpl    # Template helper functions
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── serviceaccount.yaml
│   ├── NOTES.txt       # Post-install usage notes
│   └── tests/
│       └── test-connection.yaml
├── charts/             # Dependency charts
└── .helmignore         # Files to exclude from packaging
```

## Dependencies

```bash
# List chart dependencies
helm dependency list ./my-chart

# Download dependencies into charts/ directory
helm dependency update ./my-chart

# Rebuild the charts/ directory from Chart.lock
helm dependency build ./my-chart
```

## Plugins

```bash
# List installed plugins
helm plugin list

# Install a plugin
helm plugin install https://github.com/databus23/helm-diff

# Diff between current and proposed upgrade
helm diff upgrade my-release bitnami/nginx -f values.yaml
```

## Common Patterns

### Override nested values

```bash
helm install my-release bitnami/nginx \
  --set ingress.enabled=true \
  --set ingress.hostname=app.example.com \
  --set resources.requests.memory=256Mi \
  --set resources.requests.cpu=100m
```

### Multiple values files (later files take precedence)

```bash
helm install my-release bitnami/nginx \
  -f values-base.yaml \
  -f values-production.yaml
```

### Install from OCI registry

```bash
helm install my-release oci://registry.example.com/charts/my-chart --version 1.0.0
```

## References

- [Helm Documentation](https://helm.sh/docs/)
- [Artifact Hub](https://artifacthub.io/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
