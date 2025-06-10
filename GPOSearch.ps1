#Search all GPOs to find any reference to "Windows Module Installer"
#This is a PowerShell script that searches all Group Policy Objects (GPOs) in the domain for any reference to "Trustedinstaller"

#It retrieves the GPOs, checks their settings, and outputs any GPOs that contain the specified reference.
#Import the GroupPolicy module to access GPO cmdlets    

Import-Module GroupPolicy
#Get all GPOs in the domain
$gpos = Get-GPO -All
#Initialize an array to store GPOs with the specified reference 
$matchingGPOs = @()
#Loop through each GPO and check its settings for the specified reference
foreach ($gpo in $gpos) {
    #Get the GPO settings
    $settings = Get-GPOReport -Guid $gpo.Id -ReportType Xml | Select-Xml -XPath "//*[contains(., 'usosvc') or contains(., 'TrustedInstaller') or contains(., 'Windows Modules Installer')]"
    #If any settings match, add the GPO to the array
    if ($settings) {
        $matchingGPOs += $gpo
    }
}
#Output the GPOs that contain the specified reference   
if ($matchingGPOs.Count -gt 0) {
    Write-Host "The following GPOs contain a reference to 'Windows Modules Installer':"
    foreach ($gpo in $matchingGPOs) {
        Write-Host "- $($gpo.DisplayName) (ID: $($gpo.Id))"
    }
} else {
    Write-Host "No GPOs found with a reference to 'Windows Module Installer'."
}
#This script is useful for administrators who want to audit their GPOs for specific references or settings related to the Windows Module Installer.