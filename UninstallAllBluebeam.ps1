#Pull all GUIDs of any software starting with the name Bluebeam and put it into a variable called $BluebeamGUIDs
$BluebeamGUIDs = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "Bluebeam*"} | Select-Object -ExpandProperty IdentifyingNumber

#For each GUID in $BluebeamGUIDs, uninstall the software
if ($BluebeamGUIDs) | foreach ($GUID in $BluebeamGUIDs) {
    Start-Process -FilePath "C:\windows\system32\msiexec.exe" -ArgumentList "/x $GUID /qn /log C:\Savant\BluebeamUninstall.log" -Wait
}
