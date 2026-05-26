# Runbook: Certificate Expiry

## Purpose

This runbook provides steps to identify, diagnose, and resolve issues related to expiring or expired TLS/SSL certificates.

## Symptoms

- Browser shows certificate warning or ERR_CERT_DATE_INVALID
- Application returns TLS handshake errors
- Monitoring alert for certificate expiry fired
- Clients report SSL errors when connecting to the service

## Impact

Expired certificates can cause complete service outage for HTTPS endpoints and break trust between services using mutual TLS.

## Initial Checks

### Check certificate expiry from external endpoint

```bash
echo | openssl s_client -servername <hostname> -connect <hostname>:443 2>/dev/null | openssl x509 -noout -dates -subject
```

### Check certificates in local store (Windows)

```powershell
Get-ChildItem Cert:\LocalMachine\My | Where-Object {
    $_.NotAfter -lt (Get-Date).AddDays(30)
} | Select-Object Subject, Thumbprint, NotAfter | Sort-Object NotAfter
```

### Check certificates in Kubernetes

```bash
kubectl get secret -n <namespace> -o json | jq -r '.items[] | select(.type=="kubernetes.io/tls") | .metadata.name'
kubectl get secret <secret-name> -n <namespace> -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -dates -subject
```

### Check certificates in Key Vault

```bash
az keyvault certificate list --vault-name <vault> --output table
az keyvault certificate show --vault-name <vault> --name <cert-name> --query "attributes.expires"
```

## Investigation Steps

### 1. Identify which certificate is affected

- Which hostname or service is impacted?
- Is it a wildcard cert or a single-domain cert?
- Where is the certificate stored (Key Vault, Kubernetes Secret, local cert store, ingress)?

### 2. Check certificate chain

```bash
echo | openssl s_client -servername <hostname> -connect <hostname>:443 -showcerts 2>/dev/null
```

Verify the full chain: leaf cert, intermediate cert(s), and root CA.

### 3. Check if auto-renewal is configured

- Is cert-manager configured in Kubernetes?
- Is Key Vault auto-renewal enabled?
- Is there a certificate renewal pipeline?

## Resolution Steps

### Renew via Azure Key Vault

```bash
az keyvault certificate create --vault-name <vault> --name <cert-name> --policy @policy.json
```

### Renew via cert-manager (Kubernetes)

```bash
# Check cert-manager certificate status
kubectl get certificate -n <namespace>
kubectl describe certificate <cert-name> -n <namespace>

# Force renewal
kubectl delete secret <tls-secret-name> -n <namespace>
# cert-manager will automatically recreate it
```

### Manual renewal (IIS / Windows)

1. Request new certificate from your CA
2. Import certificate to the local machine store
3. Update the IIS site binding to use the new certificate thumbprint
4. Restart the site

```powershell
# Update IIS binding
Import-Module WebAdministration
$newThumbprint = "<new-thumbprint>"
$siteName = "<site-name>"
Get-WebBinding -Name $siteName -Protocol https | ForEach-Object {
    $_.AddSslCertificate($newThumbprint, "My")
}
```

## Prevention

- Set up monitoring alerts for certificates expiring within 30, 14, and 7 days
- Use automated certificate management (cert-manager, Key Vault auto-renewal)
- Maintain a certificate inventory with expiry dates
- Include certificate checks in production readiness reviews

## Escalation

| Role | Contact |
|---|---|
| Certificate Authority Admin | [Team/Contact] |
| Platform/Infrastructure | [Team/Contact] |
| Security Team | [Team/Contact] |

## Post-Incident Follow-Up

- [ ] Certificate renewed and deployed
- [ ] Verify renewal is working end-to-end
- [ ] Add automated renewal if missing
- [ ] Add expiry alert if missing
- [ ] Update certificate inventory
- [ ] Update this runbook