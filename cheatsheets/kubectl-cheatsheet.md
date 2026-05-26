# kubectl Cheat Sheet

## Cluster Info

```bash
kubectl cluster-info
kubectl version --short
kubectl config current-context
kubectl config get-contexts
kubectl config use-context <context-name>
```

## Nodes

```bash
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node <node-name>
kubectl top nodes
kubectl cordon <node-name>
kubectl uncordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

## Namespaces

```bash
kubectl get namespaces
kubectl create namespace <namespace>
kubectl delete namespace <namespace>
```

## Pods

```bash
kubectl get pods -A
kubectl get pods -n <namespace>
kubectl get pods -n <namespace> -o wide
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl logs <pod-name> -n <namespace> -f
kubectl logs <pod-name> -n <namespace> -c <container-name>
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
kubectl delete pod <pod-name> -n <namespace>
kubectl top pod -n <namespace>
```

## Deployments

```bash
kubectl get deployments -n <namespace>
kubectl describe deployment <deployment-name> -n <namespace>
kubectl scale deployment <deployment-name> --replicas=<count> -n <namespace>
kubectl rollout status deployment/<deployment-name> -n <namespace>
kubectl rollout history deployment/<deployment-name> -n <namespace>
kubectl rollout undo deployment/<deployment-name> -n <namespace>
kubectl rollout restart deployment/<deployment-name> -n <namespace>
```

## Services and Ingress

```bash
kubectl get svc -A
kubectl get svc -n <namespace>
kubectl describe svc <service-name> -n <namespace>
kubectl get ingress -A
kubectl describe ingress <ingress-name> -n <namespace>
kubectl get endpoints -n <namespace>
```

## ConfigMaps and Secrets

```bash
kubectl get configmap -n <namespace>
kubectl describe configmap <name> -n <namespace>
kubectl get secret -n <namespace>
kubectl describe secret <name> -n <namespace>
kubectl get secret <name> -n <namespace> -o jsonpath='{.data}'
```

## Events

```bash
kubectl get events -A --sort-by=.lastTimestamp
kubectl get events -n <namespace> --sort-by=.lastTimestamp
kubectl get events -n <namespace> --field-selector type=Warning
```

## Resource Usage

```bash
kubectl top nodes
kubectl top pods -n <namespace>
kubectl top pods -A --sort-by=memory
kubectl top pods -A --sort-by=cpu
```

## Troubleshooting

```bash
kubectl get pods -n <namespace> | grep -i crash
kubectl get pods -n <namespace> | grep -i pending
kubectl get pods -n <namespace> | grep -i error
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl get events -n <namespace> --sort-by=.lastTimestamp
kubectl run debug --image=busybox -it --rm -- /bin/sh
```

## RBAC

```bash
kubectl get clusterroles
kubectl get clusterrolebindings
kubectl get roles -n <namespace>
kubectl get rolebindings -n <namespace>
kubectl auth can-i <verb> <resource> -n <namespace>
```

## Labels and Selectors

```bash
kubectl get pods -n <namespace> -l app=<label>
kubectl label pod <pod-name> <key>=<value> -n <namespace>
kubectl get pods -n <namespace> --show-labels
```

## Output Formatting

```bash
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods --sort-by=.status.startTime
```