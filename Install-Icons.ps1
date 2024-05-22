#Installation Script: Install-file.ps1

$FileName1 = "Question (1).ico"

$FileName2 = "User manual (1).ico"

$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

if(-not(Test-Path "C:\Programdata\Acen Icons")){
    New-Item -Path "C:\Programdata\Acen Icons" -ItemType Directory -Force
}

Copy-Item -Path "$ScriptPath\$FileName1" -Destination "C:\Programdata\Acen Icons\$FileName1"

Copy-Item -Path "$ScriptPath\$FileName2" -Destination "C:\Programdata\Acen Icons\$FileName2"