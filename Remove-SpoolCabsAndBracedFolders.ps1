# Remove-SpoolCabsAndBracedFolders.ps1
param(
    [switch]$WhatIf,            # run in dry-run (do not delete)
    [switch]$ForceNoPrompt      # skip confirmation
)

$spool = 'C:\Windows\System32\spool'

# require admin
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

if (-not (Test-Path $spool)) {
    Write-Error "Spool folder not found: $spool"
    exit 1
}

# find non-recursive .cab files and top-level braced folders {....}
$cabFiles = Get-ChildItem -Path $spool -File -Filter '*.cab' -Force -ErrorAction SilentlyContinue
$bracedFolders = Get-ChildItem -Path $spool -Directory -Force -ErrorAction SilentlyContinue |
                 Where-Object { $_.Name -match '^\{.*\}$' }

Write-Output "Found $($cabFiles.Count) .cab file(s) in $spool (not searching subfolders)."
Write-Output "Found $($bracedFolders.Count) folder(s) matching { ... } in $spool."

if (-not $ForceNoPrompt) {
    $answer = Read-Host "Proceed with deletion? (Y/N)"
    if ($answer -notin @('Y','y','Yes','yes')) {
        Write-Output "Aborted by user."
        exit 0
    }
}

# delete .cab files (only top-level files)
foreach ($f in $cabFiles) {
    if ($WhatIf) {
        Write-Output "Would remove file: $($f.FullName)"
    } else {
        try {
            Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop
            Write-Output "Removed file: $($f.FullName)"
        } catch {
            Write-Warning "Failed to remove file: $($f.FullName) - $($_.Exception.Message)"
        }
    }
}

# delete braced folders (and their contents)
foreach ($d in $bracedFolders) {
    if ($WhatIf) {
        Write-Output "Would remove folder (recursively): $($d.FullName)"
    } else {
        try {
            Remove-Item -LiteralPath $d.FullName -Recurse -Force -ErrorAction Stop
            Write-Output "Removed folder: $($d.FullName)"
        } catch {
            Write-Warning "Failed to remove folder: $($d.FullName) - $($_.Exception.Message)"
        }
    }
}

Write-Output "Done."