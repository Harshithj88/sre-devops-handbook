<#
.SYNOPSIS
    Checks the health of web service endpoints and reports status.

.DESCRIPTION
    This script checks a list of service URLs by sending HTTP requests
    and reports whether each service is healthy or unhealthy.

.PARAMETER Urls
    An array of URLs to check.

.PARAMETER TimeoutSeconds
    Timeout in seconds for each request. Default is 10.

.EXAMPLE
    .\Check-ServiceHealth.ps1 -Urls @("https://api.example.com/health", "https://web.example.com/health")
#>

param(
    [Parameter(Mandatory = $true)]
    [string[]]$Urls,

    [int]$TimeoutSeconds = 10
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$timestamp [$Level] $Message" -ForegroundColor $(
        switch ($Level) {
            "ERROR" { "Red" }
            "WARN"  { "Yellow" }
            "OK"    { "Green" }
            default { "White" }
        }
    )
}

$results = @()

foreach ($url in $Urls) {
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec $TimeoutSeconds -ErrorAction Stop
        $statusCode = $response.StatusCode

        if ($statusCode -eq 200) {
            Write-Log -Message "$url - HTTP $statusCode - Healthy" -Level "OK"
            $results += [PSCustomObject]@{
                Url        = $url
                StatusCode = $statusCode
                Status     = "Healthy"
                Error      = $null
            }
        } else {
            Write-Log -Message "$url - HTTP $statusCode - Unhealthy" -Level "WARN"
            $results += [PSCustomObject]@{
                Url        = $url
                StatusCode = $statusCode
                Status     = "Unhealthy"
                Error      = "Non-200 status code"
            }
        }
    } catch {
        Write-Log -Message "$url - FAILED - $($_.Exception.Message)" -Level "ERROR"
        $results += [PSCustomObject]@{
            Url        = $url
            StatusCode = $null
            Status     = "Unreachable"
            Error      = $_.Exception.Message
        }
    }
}

Write-Host ""
Write-Host "=== Health Check Summary ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

$unhealthy = $results | Where-Object { $_.Status -ne "Healthy" }
if ($unhealthy.Count -gt 0) {
    Write-Log -Message "$($unhealthy.Count) service(s) unhealthy or unreachable" -Level "ERROR"
    exit 1
} else {
    Write-Log -Message "All services healthy" -Level "OK"
    exit 0
}
