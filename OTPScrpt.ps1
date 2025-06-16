# Load the OTP module 
Import-Module OTPauth 
# Generate the current TOTP code 
$code = get-otpauthcredential -issuer "Google" | get-otpauthcode 
# Teams webhook URL 
$webhookUrl = "https://gregorydoylefirm.webhook.office.com/webhookb2/0f86d23b-abf8-434b-a213-732e4548bb28@a6af6802-14e3-45e2-8a7e-19167e90cf7a/IncomingWebhook/51889af3185948b2873d156d65d05475/f3e19ffa-b16c-4ba5-b293-5899dc37c596/V27J7G0DS8Tkm5jUjLcsGBRXO7x-Wb2_FJZWi53C11RKc1"  
# Replace with your Teams webhook 
# Create the JSON body 
$body = @{     text = "Gmail MFA Code: $code" } | ConvertTo-Json 
# Send the code to Teams 
Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $body