#Find the installed version of DiRoots.One
$ID = get-wmiobject Win32_Product | where-object {$_.name -eq "DiRoots.One"}

#Uninstall the product
if ($id) { Start-Process "C:\windows\system32\msiexec.exe" -ArgumentList "/x $($id.identifyingnumber) /q  /l c:\savant\DiRootUninstall.log" }