<#
.SYNOPSIS
    Generates a disk space report for local or remote servers.

.DESCRIPTION
    Retrieves disk space information and highlights drives
    that exceed the specified usage threshold.

.PARAMETER ComputerName
    Array of computer names to check. Default is the local machine.

.PARAMETER ThresholdPercent
    Usage percentage threshold to flag as warning. Default is 80.

.EXAMPLE
    .\Get-DiskSpaceReport.ps1 -ComputerName "Server01", "Server02" -ThresholdPercent 85
#>

param(
    [string[]]$ComputerName = @($env:COMPUTERNAME),
    [int]$ThresholdPercent = 80
)

$results = foreach ($computer in $ComputerName) {
    try {
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $computer -Filter "DriveType=3" -ErrorAction Stop

        foreach ($disk in $disks) {
            $totalGB = [math]::Round($disk.Size / 1GB, 2)
            $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
            $usedGB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
            $usedPercent = if ($disk.Size -gt 0) { [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 1) } else { 0 }

            $status = if ($usedPercent -ge 95) { "CRITICAL" }
                      elseif ($usedPercent -ge $ThresholdPercent) { "WARNING" }
                      else { "OK" }

            [PSCustomObject]@{
                Computer    = $computer
                Drive       = $disk.DeviceID
                TotalGB     = $totalGB
                UsedGB      = $usedGB
                FreeGB      = $freeGB
                UsedPercent = "$usedPercent%"
                Status      = $status
            }
        }
    } catch {
        [PSCustomObject]@{
            Computer    = $computer
            Drive       = "N/A"
            TotalGB     = "N/A"
            UsedGB      = "N/A"
            FreeGB      = "N/A"
            UsedPercent = "N/A"
            Status      = "ERROR: $($_.Exception.Message)"
        }
    }
}

Write-Host "=== Disk Space Report ===" -ForegroundColor Cyan
Write-Host "Threshold: $ThresholdPercent%" -ForegroundColor Cyan
Write-Host ""

$results | Format-Table -AutoSize

$warnings = $results | Where-Object { $_.Status -eq "WARNING" -or $_.Status -eq "CRITICAL" }
if ($warnings.Count -gt 0) {
    Write-Host "$($warnings.Count) drive(s) above threshold!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All drives within acceptable range." -ForegroundColor Green
    exit 0
}
