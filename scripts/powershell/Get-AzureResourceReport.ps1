<#
.SYNOPSIS
    Generates an inventory report of Azure resources across one or more subscriptions.

.DESCRIPTION
    Uses the Az PowerShell module to enumerate resources, summarize counts by
    type and location, and flag resources missing required governance tags.
    Supports optional CSV export for further analysis.

.PARAMETER SubscriptionId
    Optional array of subscription IDs to report on. Defaults to the current context.

.PARAMETER RequiredTags
    Tags that every resource should have. Resources missing any are flagged.
    Default: environment, owner, costCenter.

.PARAMETER ExportPath
    Optional path to export the full resource list as CSV.

.EXAMPLE
    .\Get-AzureResourceReport.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000"

.EXAMPLE
    .\Get-AzureResourceReport.ps1 -RequiredTags @('environment','owner') -ExportPath ".\resources.csv"
#>

param(
    [string[]]$SubscriptionId,
    [string[]]$RequiredTags = @('environment', 'owner', 'costCenter'),
    [string]$ExportPath
)

if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    Write-Error "The Az PowerShell module is required. Install with: Install-Module Az -Scope CurrentUser"
    exit 1
}

if (-not (Get-AzContext -ErrorAction SilentlyContinue)) {
    Write-Host "Not connected to Azure. Running Connect-AzAccount..." -ForegroundColor Yellow
    Connect-AzAccount | Out-Null
}

# Resolve target subscriptions
if (-not $SubscriptionId) {
    $SubscriptionId = @((Get-AzContext).Subscription.Id)
}

$allResources = foreach ($sub in $SubscriptionId) {
    try {
        Set-AzContext -SubscriptionId $sub -ErrorAction Stop | Out-Null
        $subName = (Get-AzContext).Subscription.Name
        Write-Host "Scanning subscription: $subName ($sub)" -ForegroundColor Cyan

        Get-AzResource | ForEach-Object {
            $missingTags = @()
            foreach ($tag in $RequiredTags) {
                if (-not $_.Tags -or -not $_.Tags.ContainsKey($tag)) {
                    $missingTags += $tag
                }
            }

            [PSCustomObject]@{
                Subscription = $subName
                Name         = $_.Name
                Type         = $_.ResourceType
                ResourceGroup = $_.ResourceGroupName
                Location     = $_.Location
                MissingTags  = ($missingTags -join ', ')
                Compliant    = ($missingTags.Count -eq 0)
            }
        }
    } catch {
        Write-Warning "Failed to scan subscription $sub : $($_.Exception.Message)"
    }
}

if (-not $allResources) {
    Write-Host "No resources found." -ForegroundColor Yellow
    exit 0
}

# --- Summary by type ---
Write-Host "`n=== Resource Count by Type ===" -ForegroundColor Cyan
$allResources | Group-Object Type |
    Sort-Object Count -Descending |
    Select-Object @{N = 'ResourceType'; E = { $_.Name } }, Count |
    Format-Table -AutoSize

# --- Summary by location ---
Write-Host "=== Resource Count by Location ===" -ForegroundColor Cyan
$allResources | Group-Object Location |
    Sort-Object Count -Descending |
    Select-Object @{N = 'Location'; E = { $_.Name } }, Count |
    Format-Table -AutoSize

# --- Tag compliance ---
$nonCompliant = $allResources | Where-Object { -not $_.Compliant }
Write-Host "=== Tag Compliance ===" -ForegroundColor Cyan
Write-Host "Total resources:   $($allResources.Count)"
Write-Host "Compliant:         $($allResources.Count - $nonCompliant.Count)" -ForegroundColor Green
Write-Host "Missing tags:      $($nonCompliant.Count)" -ForegroundColor $(if ($nonCompliant.Count -gt 0) { 'Red' } else { 'Green' })

if ($nonCompliant.Count -gt 0) {
    Write-Host "`nResources missing required tags:" -ForegroundColor Yellow
    $nonCompliant | Select-Object Name, Type, ResourceGroup, MissingTags | Format-Table -AutoSize
}

# --- Optional CSV export ---
if ($ExportPath) {
    $allResources | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "`nFull report exported to: $ExportPath" -ForegroundColor Green
}

# Exit non-zero if any resources are non-compliant (useful for CI governance gates)
if ($nonCompliant.Count -gt 0) { exit 1 } else { exit 0 }
