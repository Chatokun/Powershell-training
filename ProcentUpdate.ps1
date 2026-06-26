$logFile = "$env:LOCALAPPDATA\ProcentLogonTest.log"

"[$(Get-Date)] Logon script STARTED" | Out-File $logFile -Append

# Check last logon time
$lastLogon = Get-WmiObject Win32_NetworkLoginProfile | 
    Where-Object { $_.Name -eq "$env:USERDOMAIN\$env:USERNAME" } | 
    Select-Object -ExpandProperty LastLogon

if ($lastLogon) {
    $lastLogonTime = [Management.ManagementDateTimeConverter]::ToDateTime($lastLogon)
    $timeSinceLogon = (Get-Date) - $lastLogonTime
    
    if ($timeSinceLogon.TotalMinutes -gt 5) {
        "[$(Get-Date)] User has not logged off from previous session (last logon: $lastLogonTime)" | Out-File $logFile -Append
        "[$(Get-Date)] Logon script FINISHED" | Out-File $logFile -Append
        exit
    }
}

$maxAttempts = 5
$attempt = 0
$driveExists = $false

while ($attempt -lt $maxAttempts) {
    $attempt++
    if (Test-Path "Q:\") {
        "[$(Get-Date)] Q drive EXISTS" | Out-File $logFile -Append
        $driveExists = $true
        break
    }
    else {
        "[$(Get-Date)] Q drive DOES NOT exist (attempt $attempt/$maxAttempts)" | Out-File $logFile -Append
        if ($attempt -lt $maxAttempts) {
            Start-Sleep -Seconds 15
        }
    }
}

if (-not $driveExists) {
    "[$(Get-Date)] Q drive not found after $maxAttempts attempts, continuing anyway" | Out-File $logFile -Append
}

"[$(Get-Date)] Logon script FINISHED" | Out-File $logFile -Append

$programPath = "Q:\Program Files\ProcentSQL\UpdateProcent_PMMgr.accdb"
$workingDir  = "Q:\Program Files\ProcentSQL"

$computerName = $env:COMPUTERNAME
if ($computerName -ne "CF-RDS01V") {
    exit
}

if (Test-Path $programPath) {
    Start-Process -FilePath $programPath -WorkingDirectory $workingDir
    "[$(Get-Date)] Update script FINISHED" | Out-file $logFile -Append
}