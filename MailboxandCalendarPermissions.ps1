# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName savantadmin@huffpowellbailey.com -ShowProgress $true

# Get a list of all mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Initialize an array to store results
$delegatedAccessList = @()

# Loop through each mailbox to get the mailbox permissions
foreach ($mailbox in $mailboxes) {
    # Get Full Access permissions for each mailbox
    $permissions = Get-MailboxPermission -Identity $mailbox.Identity -ResultSize Unlimited


    # If there are permissions, add them to the list
    foreach ($permission in $permissions) {
        $delegatedAccessList += [PSCustomObject]@{
            Mailbox     = $mailbox.DisplayName
            User        = $permission.User
            AccessRights = $permission.AccessRights
            Inherited   = $permission.IsInherited
            Folder = $permission.FolderName
        }
    
    #Check the permissions of the calendar folder for each mailbox as well and add them to the array
    $calendarPermissions = Get-MailboxFolderPermission -Identity "$($mailbox.UserPrincipalName):\Calendar" -ResultSize Unlimited
    foreach ($permission in $calendarPermissions) {
        $delegatedAccessList += [PSCustomObject]@{
            Mailbox     = $mailbox.DisplayName
            User        = $permission.User
            AccessRights = $permission.AccessRights
            Inherited   = $permission.IsInherited
            Folder = $permission.FolderName
        }
    }
}
}
# Export results to a CSV file
$delegatedAccessList | Export-Csv -Path "C:\Users\chatoyer.huggins\OneDrive - savantcts.com\Clients\Antonini\FullAccessDelegates.csv" -NoTypeInformation