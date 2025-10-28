<#
.SYNOPSIS
    Check domain secure channel and attempt repair if broken (no credentials requested or stored).
    Log output to C:\savant\Domaintest.log (create folder/file if needed).

.NOTES
    Must be run elevated to perform a repair and to create C:\savant.
#>

# Ensure running as Administrator
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "ERROR: This script must be run as Administrator."
    exit 1
}

# Prepare log
$logPath = 'C:\savant\Domaintest.log'
$logDir  = Split-Path $logPath -Parent

try {
    if (-not (Test-Path -Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path -Path $logPath)) {
        New-Item -Path $logPath -ItemType File -Force | Out-Null
    }
} catch {
    Write-Output "ERROR: Unable to create log path '$logPath': $($_.Exception.Message)"
    exit 6
}

function Log {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [string]$Level = 'INFO'
    )
    $entry = "{0} [{1}] {2}" -f (Get-Date).ToString('s'), $Level, $Message
    Write-Output $entry
    Add-Content -Path $logPath -Value $entry
}

# Check domain membership
try {
    $comp = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
} catch {
    Log "Unable to determine domain membership: $($_.Exception.Message)" 'ERROR'
    exit 2
}

if (-not $comp.PartOfDomain) {
    Log "Computer is not domain-joined. Nothing to check." 'INFO'
    exit 0
}

# Test secure channel
Log "Testing computer secure channel..." 'INFO'
try {
    $healthy = Test-ComputerSecureChannel -ErrorAction Stop
} catch {
    Log "Test-ComputerSecureChannel failed: $($_.Exception.Message)" 'ERROR'
    exit 3
}

if ($healthy) {
    Log "Secure channel is healthy." 'OK'
    exit 0
}

# Attempt repair (no credentials provided or stored)
Log "Secure channel appears broken. Attempting repair..." 'WARN'
try {
    $repaired = Test-ComputerSecureChannel -Repair -ErrorAction Stop
} catch {
    Log "Repair attempt failed: $($_.Exception.Message)" 'ERROR'
    exit 4
}

if ($repaired) {
    Log "Repair succeeded." 'OK'
    exit 0
} else {
    Log "Repair attempt did not succeed." 'ERROR'
    exit 5
}