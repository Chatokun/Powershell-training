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