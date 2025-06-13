# This script removes the default calendar permissions for all mailboxes in Exchange Online, excluding certain mailboxes.

#List of mailboxes to exclude from the permission change
$excludedMailboxes = @("nkconfidential@antoniniandcohen.com","khconfidential@antoniniandcohen.com","confidential@antoniniandcohen.com","DiscoverySearchMailbox{D919BA05-46A6-415f-80AD-7E09334BB852}@antoniniandcohen.onmicrosoft.com", "savantadmin@antoniniandcohen.com")

#Connect to Exchange Online (if not already connected) 
Connect-ExchangeOnline

# Loop through all mailboxes, excluding the ones from the list
$mailboxes = Get-Mailbox -ResultSize Unlimited 

$mailboxesAllowed = $mailboxes | Where-Object { $excludedMailboxes -notcontains $_.PrimarySmtpAddress.ToString() }

ForEach ($mailbox in $mailboxesAllowed) {
    # Convert the mailbox's PrimarySmtpAddress to string for comparison
    $mailboxAddress = $mailbox.PrimarySmtpAddress.ToString()
 
    # Construct the calendar folder identity
    $calendarFolder = "${mailboxAddress}:\Calendar"
 
    try {
        # Try adding the default Editor rights if not already set
        Write-Output "Removing default calendar permissions for $calendarFolder."
         Remove-MailboxFolderPermission -Identity $calendarFolder -User Default -AccessRights Editor -ErrorAction Stop
    }
    catch {
        # If the permission already exists or another error occurs, update the permission accordingly
        Write-Output "An error occurred for $calendarFolder. Updating to AvailabilityOnly."
        Set-MailboxFolderPermission -Identity $calendarFolder -User Default -AccessRights AvailabilityOnly
    }
}