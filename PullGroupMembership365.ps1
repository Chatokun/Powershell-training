# Connect to MSOnline
Connect-MsolService

# Get all groups
$groups = Get-MsolGroup -All

# Prepare an array to hold results
$result = @()

# Loop through each group and get its members
foreach ($group in $groups) {
    # Get group members
    $members = Get-MsolGroupMember -GroupObjectId $group.ObjectId -All

    # Create a structured entry for the group
    $entry = [PSCustomObject]@{
        GroupName    = $group.DisplayName
        GroupObjectId = $group.ObjectId
        GroupType     = $group.GroupType
        LastDirSync   = $group.LastDirSyncTime
        GroupEmailAddress    = $group.EmailAddress
        Members      = if ($members) { $members.DisplayName -join '; ' } else { 'No Members' }
    }
    
    # Add the entry to the results array
    $result += $entry
}

# Export results to CSV
$result | Export-Csv -Path "C:\Savant\365GroupMemberships.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Export completed: 365GoupMemberships.csv"
