#This Script Aims to replace ACEN detect scripts for Confluence Sites

$Path1Test = Test-Path -Path "C:\Programdata\Acen Icons\Question (1).ico"

$Path2Test = Test-Path -Path "C:\Programdata\Acen Icons\User manual (1).ico"

$Path3test = Test-Path -Path "$Env:Public\Desktop\How To.lnk"

$Path4test = Test-Path -Path "$Env:Public\Desktop\ACEN-Policy & Procedure.lnk"

if ($path1test -and $Path2Test -and $Path3test -and $Path4test -eq "True"){Write-Output "0"}