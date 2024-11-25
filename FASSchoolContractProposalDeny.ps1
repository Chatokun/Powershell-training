#This script is run on the Schools Folder. It will search for all folders with "contracts" or "proposals" in their names and deny access to the groups 'Processing' and 'Project Consultants".

# Define the groups to deny access
$groupsToDeny = @("Processing", "Project Consultants")

#Timestamp function
function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

# Define the log file path
$logFilePath = "C:\Savant\ACLResults.log"

# Initialize the log file
Write-Output "$(get-Timestamp) Starting ACL modification script" | Out-File -FilePath $logFilePath -Append

# Set the starting directory
Set-Location -Path "E:\Company\schools"

# Get all subfolders with "contracts" or "proposals" in their names
$folders = Get-ChildItem -Recurse -Directory | Where-Object { $_.Name -match "contracts|proposals" }

foreach ($folder in $folders) {
    # Get all subfolders and files within the folder
    $items = Get-ChildItem -Recurse -Path $folder.FullName

    foreach ($item in $items) {
        foreach ($group in $groupsToDeny) {
            try {
                # Create a deny access rule for the group
                $denyRule = New-Object System.Security.AccessControl.FileSystemAccessRule($group, "FullControl", "Deny")
                
                # Get the current ACL for the item
                $acl = Get-Acl $item.FullName
                
                # Add the deny rule to the ACL
                $acl.SetAccessRule($denyRule)
                
                # Apply the updated ACL to the item
                Set-Acl $item.FullName $acl

                # Log the success message
                "Successfully denied access to '$group' for item '$($item.FullName)'" | Out-File -FilePath $logFilePath -Append
            } catch {
                # Log the error message
                "Failed to deny access to '$group' for item '$($item.FullName)': $_" | Out-File -FilePath $logFilePath -Append
            }
        }
    }
}

"ACL modification script completed" | Out-File -FilePath $logFilePath -Append