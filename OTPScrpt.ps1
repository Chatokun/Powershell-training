# Load the OTP module 
Import-Module OTP 
# Your base32 TOTP secret from Google 
$totpSecret = "JBSWY3DPEHPK3PXP" 
# Generate the current TOTP code 
$code = Get-TOTPToken -Secret $totpSecret 
# Teams webhook URL 
$webhookUrl = "https://outlook.office.com/webhook/..."  
# Replace with your Teams webhook 
# Create the JSON body 
$body = @{     text = "Gmail MFA Code: $code" } | ConvertTo-Json 
# Send the code to Teams 
Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $body