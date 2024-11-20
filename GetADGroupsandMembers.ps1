#This script aims to pull all groups from active directory, get their type and membership, then export that information to a CSV file.

#Import the Active Directory module
Import-Module ActiveDirectory

#Get all groups in the domain
$groups = Get-ADGroup -Filter * -Properties Name, GroupCategory, GroupScope 

#Create an empty array to store the group membership information
$groupMembership = @()

#Loop through each group
foreach ($group in $groups) {
    #Get the group membership
    $members = Get-ADGroupMember -Identity $group.Name -Recursive | Select-Object Name, ObjectClass

    #Create an custom object to store the group information
    # Create a structured entry for the group
    $entry = [PSCustomObject]@{
        GroupName    = $group.name
        GroupType     = $group.GroupCategory
        GroupDescription   = $group.GroupDescription
        Members      = if ($members) { $members.Name -join '; ' } else { 'No Members' }
    }
    
    #Add the group information to the array
    $groupMembership += $entry
}

#Export the group membership information to a CSV file
$groupMembership | Export-Csv -Path "C:\savant\group_membership.csv" -NoTypeInformation