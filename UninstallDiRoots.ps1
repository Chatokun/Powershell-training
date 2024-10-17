#Establish the main directory
$maindir = "C:\programdata\Caphyon\Advanced Installer"

#Get all directories in order to match whichever version of the software is installed
$UninstallDIR = Get-ChildItem $maindir -Directory 

# Run uninstaller from each directory
foreach ($dir in $UninstallDIR) {
    $UninstallExe = Get-ChildItem $($dir.FullName)
    $uninstall = "$($dir.FullName)\$($UninstallExe.name)" 
    if (Test-Path $UninstallExe.FullName) {
        Start-Process $uninstall /x $($dir.Name) AI_UNINSTALLER_CTP=1 -Wait
    }
}  