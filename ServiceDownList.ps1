#This is a script to get a list of services that are offline

# Get the list of services that are offline
$services = Get-Service | Where-Object {$_.Status -eq "Stopped"}

# Output the list of services that are offline
$services