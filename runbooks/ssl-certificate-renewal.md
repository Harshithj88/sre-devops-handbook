# SSL Certificate Renewal Runbook

## Overview

Step-by-step procedure for renewing SSL/TLS certificates on Windows servers and Azure resources. Covers internal wildcard certificates, public certificates, and Azure-managed certificates.

## When to Use

- Certificate expiry alert fires (< 30 days remaining)
- Planned certificate rotation
- Post-incident certificate replacement

## Prerequisites

- Access to the certificate authority (internal CA or public CA portal)
- Admin access to target servers
- PowerShell remoting enabled on target hosts
- Azure CLI / Portal access for Azure-managed certs

---

## Procedure

### 1. Identify Expiring Certificates

```powershell
# Scan a server for certificates expiring within 30 days
Invoke-Command -ComputerName $server -ScriptBlock {
    Get-ChildItem Cert:\LocalMachine\My |
        Where-Object { $_.NotAfter -lt (Get-Date).AddDays(30) } |
        Select-Object Subject, Thumbprint, NotAfter,
            @{N='DaysLeft';E={($_.NotAfter - (Get-Date)).Days}} |
        Sort-Object NotAfter
}
```

### 2. Generate Certificate Signing Request (CSR)

For internal certificates:
```powershell
# Create CSR using certreq
$inf = @"
[NewRequest]
Subject = "CN=*.example.com"
KeyLength = 2048
KeySpec = 1
KeyUsage = 0xa0
MachineKeySet = True
RequestType = PKCS10
[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1
"@

$inf | Out-File -FilePath "C:\temp\cert.inf" -Encoding ASCII
certreq -new "C:\temp\cert.inf" "C:\temp\cert.csr"
```

### 3. Submit CSR to Certificate Authority

- **Internal CA**: Submit via web enrollment portal or `certreq -submit`
- **Public CA**: Upload CSR to vendor portal (DigiCert, Let's Encrypt, etc.)

```powershell
# Submit to internal AD CS
certreq -submit -config "CA-SERVER\IssuingCA" "C:\temp\cert.csr" "C:\temp\cert.cer"
```

### 4. Install New Certificate

```powershell
# Import the issued certificate
certreq -accept "C:\temp\cert.cer"

# Verify installation
Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -like "*example.com*" } |
    Select-Object Subject, Thumbprint, NotAfter
```

### 5. Bind Certificate to IIS

```powershell
$newThumbprint = "NEW_THUMBPRINT_HERE"
$siteName = "Default Web Site"

# Update HTTPS binding
Import-Module WebAdministration
$binding = Get-WebBinding -Name $siteName -Protocol https
$binding.AddSslCertificate($newThumbprint, "My")

Write-Host "Certificate bound to $siteName"
```

### 6. Bind Certificate to Azure Resources

```bash
# App Service
az webapp config ssl bind \
  --name myapp \
  --resource-group rg-myapp \
  --certificate-thumbprint $THUMBPRINT \
  --ssl-type SNI

# Application Gateway
az network application-gateway ssl-cert update \
  --gateway-name agw-myapp \
  --resource-group rg-myapp \
  --name cert-myapp \
  --cert-file cert.pfx \
  --cert-password $PFX_PASSWORD
```

### 7. Validate

```powershell
# Test HTTPS connectivity
$uri = "https://myapp.example.com"
$request = [System.Net.HttpWebRequest]::Create($uri)
$request.GetResponse() | Out-Null
$cert = $request.ServicePoint.Certificate
Write-Host "Subject: $($cert.Subject)"
Write-Host "Expires: $($cert.GetExpirationDateString())"
Write-Host "Issuer:  $($cert.Issuer)"
```

```bash
# OpenSSL check
openssl s_client -connect myapp.example.com:443 -servername myapp.example.com 2>/dev/null | \
  openssl x509 -noout -dates -subject
```

### 8. Clean Up Old Certificate

```powershell
# Remove expired cert (verify thumbprint first!)
$oldThumbprint = "OLD_THUMBPRINT_HERE"
Get-ChildItem Cert:\LocalMachine\My\$oldThumbprint | Remove-Item
```

---

## Rollback

If the new certificate causes issues:

1. Re-bind the old certificate thumbprint in IIS / Azure
2. Restart the affected service
3. Verify HTTPS connectivity
4. Investigate root cause before retrying

## Automation

Consider automating with:
- **Azure Key Vault** auto-rotation for Azure-managed certs
- **Let's Encrypt + certbot** for public certificates
- **Scheduled task** running `Get-ExpiringCertificates.ps1` weekly
- **Azure Policy** to audit certificates nearing expiry

## Related

- [Get-ExpiringCertificates.ps1](https://github.com/Harshithj88/devops-sre-operations-toolkit/blob/main/automation/certificate-management/Get-ExpiringCertificates.ps1)
- [Azure CLI cheatsheet](../cheatsheets/azure-cli-cheatsheet.md)
