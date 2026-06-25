# Get all AD users and their password expiration dates
$users = Get-ADUser -Filter * -Properties PasswordLastSet | Where-Object { $_.PasswordLastSet -ne $null -and $_.SamAccountName -notlike '$*' }
$expiringPasswords = @()
$today = Get-Date
$daysUntilExpiration = 5

foreach ($user in $users) {
    $passwordLastSet = $user.PasswordLastSet
    $expirationDate = $passwordLastSet.AddDays(120)
    $daysRemaining = ($expirationDate - $today).Days
    
    if ($daysRemaining -le $daysUntilExpiration -and $daysRemaining -ge 0) {
        $expiringPasswords += [PSCustomObject]@{
            Username = $user.SamAccountName
            PasswordLastSet = $passwordLastSet
            ExpirationDate = $expirationDate
            DaysRemaining = $daysRemaining
        }
    }
}

# Ensure directory exists
if (-not (Test-Path "C:\Savant\Expiration")) {
    New-Item -ItemType Directory -Path "C:\Savant\Expiration" -Force | Out-Null
}

# Export to CSV
$expiringPasswords | Export-Csv -Path "C:\Savant\Expiration\PasswordExpiration_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

Write-Host "Export complete. Found $($expiringPasswords.Count) users with passwords expiring within 5 days."
# Send email notifications to expiring users
foreach ($user in $expiringPasswords) {
    $adUser = Get-ADUser -Identity $user.Username -Properties mail
    if ($adUser.mail) {
        $smtpParams = @{
            SmtpServer  = "carlockcopeland-com.mail.protection.outlook.com"
            Port        = 25
            From        = "da-savant@csvl.law"
            To          = $adUser.mail
            Subject     = "Action Required: Your Password Expires in $($user.DaysRemaining) Day(s)"
            Body        = @"
Dear $($adUser.GivenName),

Your network password will expire in $($user.DaysRemaining) day(s) on $($user.ExpirationDate.ToString('MM/dd/yyyy')).

Please change your password before it expires to avoid any disruption to your access.

If you need assistance, please contact the IT Help Desk.

Thank you,
IT Department
"@
        }
        try {
            Send-MailMessage @smtpParams
            Write-Host "Email sent to $($adUser.mail) for user $($user.Username)"
        } catch {
            Write-Warning "Failed to send email to $($adUser.mail) for user $($user.Username): $_"
        }
    } else {
        Write-Warning "No email address found for user $($user.Username), skipping."
    }
}
