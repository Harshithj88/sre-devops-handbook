# kubectl Cheat Sheet

## Cluster Info

kubectl cluster-info
kubectl version --short
kubectl config current-context
kubectl config get-contexts

Nodes
kubectl get nodes
kubectl describe node <node-name>
kubectl top nodes
Pods
kubectl get pods -A
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
Deployments
kubectl get deployments -n <namespace>
kubectl describe deployment <deployment-name> -n <namespace>
kubectl rollout status deployment/<deployment-name> -n <namespace>
kubectl rollout history deployment/<deployment-name> -n <namespace>
kubectl rollout undo deployment/<deployment-name> -n <namespace>
Services and Ingress
kubectl get svc -A
kubectl describe svc <service-name> -n <namespace>
kubectl get ingress -A
kubectl describe ingress <ingress-name> -n <namespace>
Events
kubectl get events -A --sort-by=.lastTimestamp
kubectl get events -n <namespace> --sort-by=.lastTimestamp
Troubleshooting
kubectl get pods -n <namespace> | grep -i crash
kubectl get pods -n <namespace> | grep -i pending
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous


---

## 8. Add useful runbook template

Put this in `templates/runbook-template.md`:

```markdown
# Runbook: <Issue Name>

## Purpose

Describe what this runbook is used for.

## Symptoms

- Symptom 1
- Symptom 2
- Symptom 3

## Impact

Describe customer, business, or system impact.

## Initial Checks

```bash
command goes here

Investigation Steps
Step 1: Check service health
command goes here
Step 2: Check logs
command goes here
Step 3: Check recent deployments
command goes here
Resolution Steps
Resolution step
Resolution step
Resolution step
Rollback Steps
Rollback step
Rollback step
Rollback step
Escalation

Escalate to:

Application owner:
Platform owner:
Database owner:
Network owner:
Post-Incident Actions
 Incident timeline documented
 Root cause identified
 Follow-up actions created
 Monitoring gaps identified
 Runbook updated

---

## 9. Add sample runbook: CrashLoopBackOff

Put this in `runbooks/pod-crashloopbackoff.md`:

```markdown
# Runbook: Kubernetes Pod CrashLoopBackOff

## Purpose

This runbook helps troubleshoot Kubernetes pods stuck in `CrashLoopBackOff`.

## Symptoms

- Pod repeatedly restarts
- Application is unavailable
- Deployment rollout does not complete
- Logs show application startup failure

## Initial Checks

```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
Common Causes
Application configuration issue
Missing secret or config map
Incorrect environment variable
Failed dependency connection
Application startup exception
Insufficient CPU or memory
Bad container image
Failing liveness probe
Investigation Steps
1. Check pod status
kubectl get pod <pod-name> -n <namespace> -o wide
2. Check events
kubectl describe pod <pod-name> -n <namespace>

Look for:

FailedMount
Back-off restarting failed container
ImagePullBackOff
OOMKilled
Unhealthy probe failures
3. Check previous logs
kubectl logs <pod-name> -n <namespace> --previous
4. Check environment variables
kubectl describe deployment <deployment-name> -n <namespace>
5. Check config maps and secrets
kubectl get configmap -n <namespace>
kubectl get secret -n <namespace>
6. Check resource usage
kubectl top pod <pod-name> -n <namespace>
Resolution

Depending on the root cause:

Fix missing configuration
Restore missing secret
Roll back deployment
Increase memory limit
Fix application startup issue
Correct health probe configuration
Redeploy known-good image
Rollback
kubectl rollout history deployment/<deployment-name> -n <namespace>
kubectl rollout undo deployment/<deployment-name> -n <namespace>
kubectl rollout status deployment/<deployment-name> -n <namespace>
Post-Incident Follow-Up
 Add alert for repeated pod restarts
 Improve startup logging
 Validate config before deployment
 Add deployment smoke test
 Update this runbook

---

## 10. Add architecture diagrams using Mermaid

GitHub supports Mermaid diagrams in Markdown, so you can create architecture diagrams without needing Visio.

Put this in `architecture/aks-platform-architecture.md`:

````markdown
# AKS Platform Architecture

## Overview

This diagram shows a reference AKS platform architecture with CI/CD, container registry, secrets management, observability, and application workloads.

```mermaid
flowchart TD
    Dev[Developer] --> GitHub[GitHub Repository]
    GitHub --> Actions[GitHub Actions Pipeline]
    Actions --> Bicep[Azure Bicep IaC]
    Bicep --> RG[Azure Resource Group]

    RG --> AKS[Azure Kubernetes Service]
    RG --> ACR[Azure Container Registry]
    RG --> KV[Azure Key Vault]
    RG --> LAW[Log Analytics Workspace]

    Actions --> ACR
    ACR --> AKS
    KV --> AKS
    AKS --> App[Application Workloads]
    AKS --> Monitor[Monitoring Agent]
    Monitor --> LAW

    User[End User] --> LB[Load Balancer / Ingress]
    LB --> App