#This file aims to consolidate the icon Intune programs for ACEN


#Installation Script: Icons

$Icon1 = "Question (1).ico"

$Icon2 = "User manual (1).ico"

$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

if(-not(Test-Path "C:\Programdata\Acen Icons")){
    New-Item -Path "C:\Programdata\Acen Icons" -ItemType Directory -Force
}

Copy-Item -Path "$ScriptPath\$Icon1" -Destination "C:\Programdata\Acen Icons\$Icon1"

Copy-Item -Path "$ScriptPath\$Icon2" -Destination "C:\Programdata\Acen Icons\$Icon2"


#Installation Script: How to Link

if (Test-path -Path "C:\Program Files\Google\Chrome\Application"){$Howto = "How To.lnk"}
elseif (Test-path -Path "C:\Program Files (x86)\Google\Chrome\Application"){$Howto = "How Tox86.lnk"}
else {Write-Output "Chrome not installed"
exit} 

$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

Copy-Item -Path "$ScriptPath\$Howto" -Destination "$Env:Public\Desktop\How To.lnk"


#Installation Script: Policy and Procedure Link

if (Test-path -Path "C:\Program Files\Google\Chrome\Application"){$Policy = "ACEN-Policy & Procedure.lnk"}
elseif (Test-path -Path "C:\Program Files (x86)\Google\Chrome\Application"){$Policy = "ACEN-Policy & Procedurex86.lnk"}
else {Write-Output "Chrome not installed"
exit} 

$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

Copy-Item -Path "$ScriptPath\$Policy" -Destination "$Env:Public\Desktop"
