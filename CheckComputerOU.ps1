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
    $computers = get-adcomputer -Filter * -SearchBase $ou.DistinguishedName | Select-Object Name, SamAccountName
    if ($computers) {
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
       # Add GPO information to each user entry
    foreach ($computer in $computerList) {
        $computer | Add-Member -MemberType NoteProperty -Name GroupPolicyLinks -Value ($gpoList -join "; ") -Force
    }
        Write-Output "Computers:"
        $computerList = $computers | ForEach-Object {
            # Create a custom object for each user
            [PSCustomObject]@{
                OUName             = $ou.Name
                OUDistinguishedName = $ou.DistinguishedName
                Computer           = $_.Name
                computersAM            = $_.SamAccountName
                GroupPolicyLinks   = $computers.GroupPolicyLinks
            }
        }
        $results += $computerList
    } else {
        Write-Output "  No computers found."
        # Add an entry for the OU with no computers
        $results += [PSCustomObject]@{
            OUName             = $ou.Name
            OUDistinguishedName = $ou.DistinguishedName
            ComputerName           = "No computers found"
            computersAM            = ""
            GroupPolicyLinks   = $computers.GroupPolicyLinks
        }
    }

 }
    
# Export results to CSV
$csvPath = "c:\savant\AD_OrganizationalUnits_computers.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Output "Data exported to $csvPath"
