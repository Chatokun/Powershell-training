<#
.SYNOPSIS
  Creates and starts a PerfMon Data Collector Set that logs per-process CPU, memory, 
  and page writes to CSV for a fixed duration.

.PARAMETER SetName
  Name of the Data Collector Set.

.PARAMETER OutDir
  Directory where logs will be written.

.PARAMETER SampleIntervalSeconds
  Sampling interval (seconds). Default: 5

.PARAMETER DurationHours
  How long to run before auto-stopping. Default: 4 hours

.PARAMETER Wait
  If supplied, the script will wait for the duration and stop the set before exiting.
#>

[CmdletBinding()]
param(
    [string]$SetName = "ProcessMonitoring",
    [string]$OutDir = "C:\PerfLogs\ProcessMonitoring",
    [ValidateRange(1, 86400)]
    [int]$SampleIntervalSeconds = 5,
    [ValidateRange(1, 168)]
    [int]$DurationHours = 4,
    [switch]$Wait
)

function Assert-Admin {
    $curr = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($curr)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        throw "Please run this script in an elevated PowerShell session (Run as Administrator)."
    }
}

try {
    Assert-Admin

    # Ensure logman is available
    if (-not (Get-Command logman.exe -ErrorAction SilentlyContinue)) {
        throw "logman.exe not found. This script requires the built-in 'logman' utility."
    }

    # Prepare paths and times
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
    $outBase = Join-Path $OutDir $SetName

    $si = [TimeSpan]::FromSeconds([Math]::Max(1, $SampleIntervalSeconds))
    $rf = [TimeSpan]::FromHours([Math]::Max(1, $DurationHours))

    # Define counters (per-process)
    $counters = @(
        '\Process(*)\% Processor Time',
        '\Process(*)\Working Set',
        '\Process(*)\Working Set - Private',
        '\Process(*)\Private Bytes',
        '\Process(*)\Page Writes/sec'
    )

    Write-Host "Configuring Data Collector Set '$SetName'..." -ForegroundColor Cyan

    # Delete existing set with same name (if present)
    & logman query $SetName *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Existing set '$SetName' found. Stopping and deleting..." -ForegroundColor Yellow
        & logman stop $SetName *> $null
        & logman delete $SetName *> $null
    }

    # Build creation args
    $counterArgs = @()
    foreach ($c in $counters) { $counterArgs += @('-c', $c) }

    $createArgs = @('create','counter',$SetName) + $counterArgs + @(
        '-si', $si.ToString(),          # hh:mm:ss
        '-o', $outBase,                 # base file path (timestamp suffix applied)
        '-f', 'csv',                    # CSV file format
        '-v', 'mmddhhmm',               # timestamp format in file name
        '-rf', $rf.ToString()           # run for (auto-stop)
        # Optional: '-cnf','00:30:00'   # create new file every 30 minutes
    )

    # Create the Data Collector Set
    $null = & logman @createArgs
    if ($LASTEXITCODE -ne 0) { throw "Failed to create Data Collector Set '$SetName'." }

    # Start it
    $null = & logman start $SetName
    if ($LASTEXITCODE -ne 0) { throw "Failed to start Data Collector Set '$SetName'." }

    Write-Host ""
    Write-Host "✅ Started: $SetName" -ForegroundColor Green
    Write-Host "   Sample interval : $([int]$si.TotalSeconds) second(s)"
    Write-Host "   Run duration    : $rf (auto-stop)"
    Write-Host "   Output folder   : $OutDir"
    Write-Host "   Files will be named like: $SetName_*.csv" 

    if ($Wait.IsPresent) {
        Write-Host ""
        Write-Host "⏳ Waiting for $rf to complete..." -ForegroundColor Cyan
        Start-Sleep -Seconds [int]$rf.TotalSeconds

        Write-Host "Stopping '$SetName'..." -ForegroundColor Yellow
        & logman stop $SetName *> $null

        Write-Host "Done. Recent log files:" -ForegroundColor Green
        Get-ChildItem -Path $OutDir -Filter "$SetName*.csv" |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 5 FullName, Length, LastWriteTime |
            Format-Table -AutoSize
    } else {
        Write-Host ""
        Write-Host "ℹ️  This collector will auto-stop after the duration." -ForegroundColor Cyan
        Write-Host "   Stop early:  logman stop `"$SetName`""
        Write-Host "   Delete set:  logman delete `"$SetName`""
    }
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
