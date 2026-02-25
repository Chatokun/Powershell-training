#This Script will uninstall all versions of CodeTwo Email Signatures

#Get all versions of CodeTwo and put their GUIDs in a variable named $CODETWO
$CODETWO = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "CodeTwo*" }

#Uninstall all versions of CodeTwo using msiexec /x and the GUIDs stored in $CODETWO and store result in $result
$result = $CODETWO | ForEach-Object { msiexec /x $_.IdentifyingNumber /qn } 

#Export the results to C:\Savant\Logs\UninstallCodeTwo.txt
$result | Out-File (  New-Item -Path "C:\Savant\Logs\UninstallCodeTwo.txt" -force) -Append