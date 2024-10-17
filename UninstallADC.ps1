#Find the installed version of Autodesk Desktop Connector
$AutoDeskID = get-wmiobject Win32_Product | where-object {$_.name -eq "Autodesk Desktop Connector"}

#Uninstall the product
if ($AutoDeskID) { Start-Process "C:\windows\system32\msiexec.exe" -ArgumentList "/x $($AutoDeskID.identifyingnumber) /q  /l c:\savant\ADCUninstall.log" }