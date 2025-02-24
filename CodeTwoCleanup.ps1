#This script will delete specific registry keys for Codetwo from the registry
#Full Key to delete - Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{295F3DF6-DD70-41E1-9D23-5070CB9B1089}
#Start a transcript log to C:\Savant\Logs\CodeTwoCleanup.log and create path if it doesn't exist

$transcriptPath = 'C:\Savant\Logs\CodeTwoCleanup.log' 

if (-not (Test-Path -Path 'C:\Savant\Logs')) {
    New-Item -Path 'C:\Savant\Logs' -ItemType Directory
}

Start-Transcript -Path $transcriptPath -Append

$regKeys = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{295F3DF6-DD70-41E1-9D23-5070CB9B1089}'

foreach ($key in $regKeys) {
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force
    }
}
 
#Search each user profile and delete any Codetwo folders under AppData\Local
$users = Get-ChildItem -Path 'C:\Users' -Directory 

foreach ($user in $users) {
    $path = Join-Path -Path $user.FullName -ChildPath 'AppData\Local'
    $codetwo = Get-ChildItem -Path $path -Recurse -Filter 'Codetwo'

    if ($codetwo) {
        Remove-Item -Path $codetwo.FullName -Recurse -Force
    }
}
