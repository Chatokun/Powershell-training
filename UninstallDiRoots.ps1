#Establish the main directory
$maindir = "C:\programdata\Caphyon\Advanced Installer"

#Get all directories in order to match whichever version of the software is installed
$UninstallDIR = Get-ChildItem $maindir -Directory 

# Run uninstaller from each directory
foreach ($dir in $UninstallDIR) {
    $uninstall = "$($dir.FullName)\DiRoots.One-1.9.1.exe /x $($dir.FullName) AI_UNINSTALLER_CTP=1"
    if (Test-Path $uninstall) {
        Start-Process $uninstall -Wait
    }
}  