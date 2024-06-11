#This file aims to consolidate the icon Intune programs for ACEN



#Installation Script: Icons

$Icon1 = "Question (1).ico"

$Icon2 = "User manual (1).ico"

$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

if(-not(Test-Path "C:\Programdata\Acen Icons")){
    New-Item -Path "C:\Programdata\Acen Icons" -ItemType Directory -Force
}

Copy-Item -Path "$ScriptPath\$FileName1" -Destination "C:\Programdata\Acen Icons\$Icon1"

Copy-Item -Path "$ScriptPath\$FileName2" -Destination "C:\Programdata\Acen Icons\$Icon2"


#Installation Script: How to Link

if (Test-path -Path "C:\Program Files\Google\Chrome\Application"){$Howto = "How To.lnk"}
elseif (Test-path -Path "C:\Program Files (x86)\Google\Chrome\Application"){$How Tox86.lnk"}

$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

Copy-Item -Path "$ScriptPath\$Howto" -Destination "$Env:Public\Desktop\How To.lnk"


#Installation Script:  


