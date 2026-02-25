#Find the installed version of Element55 Time Capture Agent
$Element55 = get-wmiobject Win32_Product | where-object {$_.name -eq "Element55 Time Capture Agent"}

#Uninstall the product
if ($Element55) { Start-Process "C:\windows\system32\msiexec.exe" -ArgumentList "/x $($Element55.identifyingnumber) /q  /l c:\savant\Element55Uninstall.log" }