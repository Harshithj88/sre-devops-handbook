# Runbook: DNS Resolution Failure

## Purpose

This runbook provides steps to diagnose and resolve DNS resolution failures that prevent applications from reaching their dependencies or prevent users from reaching the application.

## Symptoms

- Application logs show "Name or service not known" or "could not resolve host"
- HTTP requests to external services failing with DNS errors
- Users unable to reach the application by hostname
- Kubernetes pods failing to resolve service names or external hostnames
- Intermittent connectivity with DNS-related error patterns

## Impact

Partial or complete service failure depending on which DNS records are affected and whether cached records are still valid.

## Initial Checks

```bash
# Test DNS resolution from your machine
nslookup <hostname>
dig <hostname>
Resolve-DnsName <hostname>

# Test with a specific DNS server
nslookup <hostname> 8.8.8.8
dig @8.8.8.8 <hostname>

# Check DNS propagation
dig +trace <hostname>
```

## Investigation Steps

### 1. Determine scope of failure

```bash
# Can you resolve other hostnames?
nslookup google.com
nslookup <internal-hostname>
nslookup <affected-hostname>

# Is it affecting all pods or just some?
kubectl exec -it <pod-name> -n <namespace> -- nslookup <hostname>
kubectl exec -it <pod-name> -n <namespace> -- cat /etc/resolv.conf
```

### 2. Check Kubernetes DNS (CoreDNS)

```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50

# Check CoreDNS service
kubectl get svc -n kube-system kube-dns

# Check CoreDNS ConfigMap
kubectl get configmap -n kube-system coredns -o yaml

# Test DNS from inside the cluster
kubectl run dns-test --image=busybox:1.36 --rm -it --restart=Never -- nslookup kubernetes.default
kubectl run dns-test --image=busybox:1.36 --rm -it --restart=Never -- nslookup <external-hostname>
```

### 3. Check DNS configuration

```bash
# Linux: Check resolver config
cat /etc/resolv.conf

# Windows: Check DNS client settings
Get-DnsClientServerAddress
ipconfig /displaydns | Select-String -Pattern "<hostname>" -Context 0,5

# Check DNS cache
ipconfig /displaydns   # Windows
```

### 4. Check Azure DNS (if using Azure Private DNS)

```bash
# List private DNS zones
az network private-dns zone list -g <resource-group> -o table

# List records in a private zone
az network private-dns record-set list -z <zone-name> -g <resource-group> -o table

# Check virtual network links
az network private-dns link vnet list -z <zone-name> -g <resource-group> -o table

# Check public DNS zone records
az network dns record-set list -z <zone-name> -g <resource-group> -o table
```

### 5. Check for network-level DNS blocking

```bash
# Test connectivity to DNS server
Test-NetConnection -ComputerName 8.8.8.8 -Port 53
Test-NetConnection -ComputerName <dns-server-ip> -Port 53

# Check NSG rules that might block DNS (UDP/TCP 53)
az network nsg rule list --nsg-name <nsg-name> -g <resource-group> -o table
```

### 6. Check TTL and caching

```bash
# Check TTL of DNS record
dig <hostname> +noall +answer

# Flush DNS cache
# Windows
ipconfig /flushdns

# Linux (systemd-resolved)
sudo systemd-resolve --flush-caches

# macOS
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder
```

## Resolution Options

| Root Cause | Resolution |
|---|---|
| DNS record missing | Create the DNS record in the correct zone |
| DNS record incorrect | Update the DNS record with correct IP/CNAME |
| CoreDNS pod crash | Restart CoreDNS pods, check resource limits |
| Private DNS zone not linked | Link the private DNS zone to the VNet |
| NSG blocking port 53 | Add allow rule for UDP/TCP 53 to DNS server |
| DNS server unreachable | Check DNS server health, switch to backup DNS |
| Stale DNS cache | Flush DNS cache on affected machines/pods |
| DNS propagation delay | Wait for TTL expiry, verify at authoritative nameserver |
| /etc/resolv.conf misconfigured | Fix nameserver entries, check ndots setting |

## Kubernetes-Specific Fixes

```bash
# Restart CoreDNS
kubectl rollout restart deployment/coredns -n kube-system

# Fix pod DNS policy (if pod can't resolve external names)
# Ensure dnsPolicy is "ClusterFirst" (default) or "Default" for host DNS
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.dnsPolicy}'

# Scale up CoreDNS if under load
kubectl scale deployment/coredns -n kube-system --replicas=3
```

## Escalation

| Role | Contact |
|---|---|
| Platform/Infrastructure | [Team/Contact] |
| Network Team | [Team/Contact] |
| DNS Administrator | [Team/Contact] |

## Post-Incident Follow-Up

- [ ] Document incident timeline
- [ ] Verify DNS records are correctly configured
- [ ] Add DNS resolution monitoring
- [ ] Review DNS redundancy and failover
- [ ] Update this runbook
