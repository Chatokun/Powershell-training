# Import the Active Directory module
Import-Module ActiveDirectory

# Create an array to hold the results
$results = @()

# Get all Organizational Units
$organizationalUnits = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

  
# Loop through each Organizational Unit
foreach ($ou in $organizationalUnits) {
    Write-Output "Organizational Unit: $($ou.Name)"
    Write-Output "Distinguished Name: $($ou.DistinguishedName)"
    
    # Get the user objects within the OU
    $users = Get-ADUser -Filter * -SearchBase $ou.DistinguishedName | Select-Object Name, SamAccountName
    if ($users) {
        # Get Group Policies linked to the OU
    $gpos = (Get-ADOrganizationalUnit -filter * | Get-GPInheritance).GpoLinks | Select-Object -Property Target,DisplayName,Enabled,Enforced,Order | Where-Object { $_.Target -eq $ou.DistinguishedName }
    $gpoList = @()
    if ($gpos) {
        Write-Output "Group Policies Linked:"
        foreach ($gpo in $gpos) {
            Write-Output "  - $($gpo.DisplayName)"
            $gpoList += $gpo.DisplayName
        }
    } else {
        Write-Output "  No Group Policies linked."
        $gpoList += "No Group Policies linked"
    }
        Write-Output "Users:"
        $userList = $users | ForEach-Object {
            # Create a custom object for each user
            [PSCustomObject]@{
                OUName             = $ou.Name
                OUDistinguishedName = $ou.DistinguishedName
                UserName           = $_.Name
                UserSAM            = $_.SamAccountName
                GroupPolicyLinks   = $users.GroupPolicyLinks
            }
        }
        $results += $userList
    } else {
        Write-Output "  No users found."
        # Add an entry for the OU with no users
        $results += [PSCustomObject]@{
            OUName             = $ou.Name
            OUDistinguishedName = $ou.DistinguishedName
            UserName           = "No users found"
            UserSAM            = ""
            GroupPolicyLinks   = $users.GroupPolicyLinks
        }
    }
       # Add GPO information to each user entry
       foreach ($user in $userList) {
        $user | Add-Member -MemberType NoteProperty -Name GroupPolicyLinks -Value ($gpoList -join "; ") -Force
    }
 }
    
# Export results to CSV
$csvPath = "c:\savant\AD_OrganizationalUnits_Users.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Output "Data exported to $csvPath"
