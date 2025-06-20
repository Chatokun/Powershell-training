Import-Module ActiveDirectory

# Path to the CSV file
$csvPath = "C:\Savant\GemmsRDS2v-NewMembers.csv"

# Log file path
$logPath = "C:\Savant\GemmsGroupChange\GroupChangeLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
New-Item -ItemType Directory -Path (Split-Path $logPath) -Force | Out-Null

# Import users from CSV
$users = Import-Csv -Path $csvPath

# Define group names
$removeGroups = @("GEMMS RDS01", "GEMMS RDS03")
$addGroup = "GEMMS RDS02-new"

# Function to log messages
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp`t$Message" | Out-File -FilePath $logPath -Append
}

foreach ($user in $users) {
    $sam = $user.samaccountname
    Write-Log "Processing user: $sam"

    # Remove user from specified groups
    foreach ($group in $removeGroups) {
        try {
            Remove-ADGroupMember -Identity $group -Members $sam -Confirm:$false -ErrorAction Stop
            Write-Log "Removed $sam from group '$group' successfully."
        } catch {
            Write-Log "ERROR removing $sam from group '$group': $_"
        }
    }

    # Add user to the new group
    try {
        Add-ADGroupMember -Identity $addGroup -Members $sam -ErrorAction Stop
        Write-Log "Added $sam to group '$addGroup' successfully."
    } catch {
        Write-Log "ERROR adding $sam to group '$addGroup': $_"
    }
}
Write-Log "Script completed."