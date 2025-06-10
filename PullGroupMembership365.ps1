# Connect to Exchange Online
Connect-ExchangeOnline

# Prepare an array to hold results
$result = @()

# Get all Distribution Groups
$distGroups = Get-DistributionGroup -ResultSize Unlimited
foreach ($group in $distGroups) {
    $members = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited
    $entry = [PSCustomObject]@{
        GroupType         = "DistributionGroup"
        GroupName         = $group.DisplayName
        GroupObjectId     = $group.Guid
        GroupEmailAddress = $group.PrimarySmtpAddress
        LastDirSync       = $null
        Members           = if ($members) { $members.DisplayName -join '; ' } else { 'No Members' }
    }
    $result += $entry
}

# Get all Microsoft 365 Groups (Unified Groups)
$unifiedGroups = Get-UnifiedGroup -ResultSize Unlimited
foreach ($group in $unifiedGroups) {
    $members = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members
    $entry = [PSCustomObject]@{
        GroupType         = "UnifiedGroup"
        GroupName         = $group.DisplayName
        GroupObjectId     = $group.ExternalDirectoryObjectId
        GroupEmailAddress = $group.PrimarySmtpAddress
        LastDirSync       = $null
        Members           = if ($members) { $members.DisplayName -join '; ' } else { 'No Members' }
    }
    $result += $entry
}

# Export results to CSV
$result | Export-Csv -Path "C:\Savant\365GroupMemberships.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Export completed: 365GroupMemberships.csv"

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
