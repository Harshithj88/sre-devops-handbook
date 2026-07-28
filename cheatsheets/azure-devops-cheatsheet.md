# Azure DevOps Cheat Sheet

## Azure DevOps CLI Setup

```bash
# Install the extension
az extension add --name azure-devops

# Set default organization and project
az devops configure --defaults organization=https://dev.azure.com/MyOrg project=MyProject

# Login
az login
```

## Pipelines

```bash
# List pipelines
az pipelines list --output table

# Show pipeline details
az pipelines show --name "Build" --output table

# Run a pipeline
az pipelines run --name "Build" --branch main

# Run with parameters
az pipelines run --name "Deploy" --branch main --parameters "environment=qa1"

# List pipeline runs
az pipelines runs list --pipeline-name "Build" --top 10 --output table

# Show run details
az pipelines runs show --id 12345

# List pipeline variables
az pipelines variable list --pipeline-name "Build" --output table

# Set a pipeline variable
az pipelines variable create --name "MyVar" --value "MyValue" --pipeline-name "Build"
```

## Variable Groups

```bash
# List variable groups
az pipelines variable-group list --output table

# Show variable group details
az pipelines variable-group show --group-id 42 --output table

# Create a variable group
az pipelines variable-group create --name "MyApp-DV1" --variables "API_URL=https://api.dev.example.com" "ENV=dv1"

# Add a variable to a group
az pipelines variable-group variable create --group-id 42 --name "NEW_VAR" --value "new-value"

# Update a variable
az pipelines variable-group variable update --group-id 42 --name "API_URL" --value "https://api.new.example.com"

# Delete a variable
az pipelines variable-group variable delete --group-id 42 --name "OLD_VAR" --yes
```

## Service Connections

```bash
# List service connections
az devops service-endpoint list --output table

# Show details
az devops service-endpoint show --id <endpoint-id>
```

## Repositories

```bash
# List repos
az repos list --output table

# Show repo details
az repos show --repository MyRepo

# Create a repo
az repos create --name "NewRepo"

# List branches
az repos ref list --repository MyRepo --filter heads/ --output table

# Create a branch
az repos ref create --repository MyRepo --name "refs/heads/feature/my-feature" --object-id <commit-sha>
```

## Pull Requests

```bash
# List active PRs
az repos pr list --status active --output table

# Create a PR
az repos pr create --repository MyRepo --source-branch feature/my-feature --target-branch main --title "Add feature X"

# Show PR details
az repos pr show --id 123

# Approve a PR
az repos pr set-vote --id 123 --vote approve

# Complete a PR
az repos pr update --id 123 --status completed --merge-strategy squash --delete-source-branch true

# List PR reviewers
az repos pr reviewer list --id 123 --output table
```

## Work Items

```bash
# Show a work item
az boards work-item show --id 5678

# Create a work item
az boards work-item create --type "Task" --title "Investigate alert noise" --assigned-to "user@example.com"

# Update a work item
az boards work-item update --id 5678 --state "Active"

# List work items by query
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.AssignedTo] = @Me AND [System.State] = 'Active'"
```

## Artifacts

```bash
# List feeds
az artifacts feed list --output table

# List packages in a feed
az artifacts package list --feed MyFeed --output table

# Show package versions
az artifacts package show --feed MyFeed --package MyPackage --output table
```

## YAML Pipeline Syntax Quick Reference

### Trigger

```yaml
trigger:
  branches:
    include: [main, releases/*]
    exclude: [feature/*]
  paths:
    include: [src/**]
```

### Stage with Approval Gate

```yaml
stages:
  - stage: Deploy
    jobs:
      - job: Approval
        pool: server
        steps:
          - task: ManualValidation@1
            inputs:
              instructions: 'Approve deployment'
              onTimeout: reject
      - job: Run
        dependsOn: Approval
        condition: succeeded('Approval')
```

### Template Parameters

```yaml
parameters:
  - name: environment
    type: string
    default: dev
    values: [dev, qa, prod]

steps:
  - script: echo "Deploying to ${{ parameters.environment }}"
```

### Variable Groups

```yaml
variables:
  - group: MyApp-${{ parameters.environment }}
  - name: buildConfig
    value: Release
```

### Conditions

```yaml
# Run only on main
condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')

# Run if previous stage succeeded or was skipped
condition: in(dependencies.PrevStage.result, 'Succeeded', 'Skipped')

# Boolean AND
condition: and(succeeded(), eq(variables['Build.Reason'], 'Manual'))
```

### Common Tasks

```yaml
# .NET Build
- task: DotNetCoreCLI@2
  inputs:
    command: build
    projects: '**/*.csproj'

# Publish artifacts
- task: PublishBuildArtifacts@1
  inputs:
    PathtoPublish: $(Build.ArtifactStagingDirectory)
    ArtifactName: Artifacts

# Download artifacts from another pipeline
- download: build
  artifact: Artifacts

# Azure CLI
- task: AzureCLI@2
  inputs:
    azureSubscription: 'ServiceConnection'
    scriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      az webapp restart --name myapp --resource-group myrg
```
