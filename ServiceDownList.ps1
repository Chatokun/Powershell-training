#This is a script to get a list of services that are offline

#Make a function to get the list of services that are offline
function Get-ServiceDownList {
    # Get the list of services that are offline
    $services = Get-Service | Where-Object {$_.Status -eq "Stopped"}

    # Output the list of services that are offline
    $services
}
