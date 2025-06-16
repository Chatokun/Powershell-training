# Load the OTP module 
Import-Module OTPauth 
# Generate the current TOTP code 
$code = get-otpauthcredential -issuer "Google" | get-otpauthcode 
# Teams webhook URL 
$webhookUrl = "https://outlook.office.com/webhook/..."  
# Replace with your Teams webhook 
# Create the JSON body 
$body = @{     text = "Gmail MFA Code: $code" } | ConvertTo-Json 
# Send the code to Teams 
Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $body