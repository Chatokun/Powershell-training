$logFile = "$env:LOCALAPPDATA\ProcentLogonTest.log"
$tokenFile = "$env:LOCALAPPDATA\ProcentUpdate.token"
$today = (Get-Date).ToString("yyyy-MM-dd")

"[$(Get-Date)] Logon script STARTED" | Out-File $logFile -Append

# Check if token exists for today
if (Test-Path $tokenFile) {
    $tokenDate = Get-Content $tokenFile
    if ($tokenDate -eq $today) {
        "[$(Get-Date)] Token found for today, skipping execution" | Out-File $logFile -Append
        "[$(Get-Date)] Logon script FINISHED" | Out-File $logFile -Append
        exit
    }
    else {
        "[$(Get-Date)] Removing old token from $tokenDate" | Out-File $logFile -Append
        Remove-Item $tokenFile -Force
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
    "[$(Get-Date)] Q drive not found after $maxAttempts attempts, exiting" | Out-File $logFile -Append
    "[$(Get-Date)] Logon script FINISHED" | Out-File $logFile -Append
    exit
}

$programPath = "Q:\Program Files\ProcentSQL\UpdateProcent_PMMgr.accdb"
$workingDir  = "Q:\Program Files\ProcentSQL"
$computerName = $env:COMPUTERNAME

if ($computerName -ne "CF-RDS01V") {
    exit
}

if (Test-Path $programPath) {
    Start-Process -FilePath $programPath -WorkingDirectory $workingDir
    "[$(Get-Date)] Update script FINISHED" | Out-File $logFile -Append
    
    # Create token for today on success
    $today | Out-File $tokenFile -Force
    "[$(Get-Date)] Token created for $today" | Out-File $logFile -Append
}

"[$(Get-Date)] Logon script FINISHED" | Out-File $logFile -Append