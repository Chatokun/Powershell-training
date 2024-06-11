#This file aims to consolidate the icon Intune programs for ACEN



#Installation Script: Install-file.ps1

$FileName1 = "Question (1).ico"

$FileName2 = "User manual (1).ico"

$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

if(-not(Test-Path "C:\Programdata\Acen Icons")){
    New-Item -Path "C:\Programdata\Acen Icons" -ItemType Directory -Force
}

Copy-Item -Path "$ScriptPath\$FileName1" -Destination "C:\Programdata\Acen Icons\$FileName1"

Copy-Item -Path "$ScriptPath\$FileName2" -Destination "C:\Programdata\Acen Icons\$FileName2"


#Installation Script: Install-file.ps1

$FileName = "How To.lnk"

$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

Copy-Item -Path "$ScriptPath\$FileName" -Destination "$Env:Public\Desktop"

#Detect File : Detect-file.ps1

$FileName = "How To.lnk"

if (Test-Path -Path "$Env:Public\Desktop\$FileName"){Write-Output "0"}

    

#Detect File : Detect-file.ps1

$FileName1 = "Question (1).ico"

$FileName2 = "User manual (1).ico"

$Path1Test = Test-Path -Path "C:\Programdata\Acen Icons\$FileName1"

$Path2Test = Test-Path -Path "C:\Programdata\Acen Icons\$FileName2"

if ($path1test -eq "True" -and $Path2Test -eq "True"){Write-Output "0"}

