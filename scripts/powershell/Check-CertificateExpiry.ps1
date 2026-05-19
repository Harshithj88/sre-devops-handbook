<#
.SYNOPSIS
    Checks TLS certificates on the local machine for upcoming expiry.

.DESCRIPTION
    Scans the LocalMachine certificate store and reports certificates
    expiring within the specified number of days.

.PARAMETER DaysUntilExpiry
    Number of days to look ahead for expiring certificates. Default is 30.

.PARAMETER StorePath
    Certificate store path to check. Default is Cert:\LocalMachine\My.

.EXAMPLE
    .\Check-CertificateExpiry.ps1 -DaysUntilExpiry 60
#>

param(
    [int]$DaysUntilExpiry = 30,
    [string]$StorePath = "Cert:\LocalMachine\My"
)

$threshold = (Get-Date).AddDays($DaysUntilExpiry)

$certs = Get-ChildItem -Path $StorePath | Where-Object {
    $_.NotAfter -lt $threshold
} | Sort-Object NotAfter

if ($certs.Count -eq 0) {
    Write-Host "No certificates expiring within $DaysUntilExpiry days." -ForegroundColor Green
    exit 0
}

Write-Host "=== Certificates Expiring Within $DaysUntilExpiry Days ===" -ForegroundColor Yellow
Write-Host ""

$results = foreach ($cert in $certs) {
    $daysLeft = ($cert.NotAfter - (Get-Date)).Days
    $status = if ($daysLeft -lt 0) { "EXPIRED" }
              elseif ($daysLeft -lt 7) { "CRITICAL" }
              elseif ($daysLeft -lt 14) { "WARNING" }
              else { "UPCOMING" }

    [PSCustomObject]@{
        Subject    = $cert.Subject
        Thumbprint = $cert.Thumbprint
        ExpiryDate = $cert.NotAfter.ToString("yyyy-MM-dd")
        DaysLeft   = $daysLeft
        Status     = $status
    }
}

$results | Format-Table -AutoSize

$expired = $results | Where-Object { $_.Status -eq "EXPIRED" -or $_.Status -eq "CRITICAL" }
if ($expired.Count -gt 0) {
    Write-Host "$($expired.Count) certificate(s) expired or critically close to expiry!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "$($results.Count) certificate(s) expiring soon. Plan renewals." -ForegroundColor Yellow
    exit 0
}
