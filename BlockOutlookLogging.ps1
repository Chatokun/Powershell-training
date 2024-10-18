# Get all Users

$Users = Get-ChildItem -Path "$($ENV:SystemDrive)\Users"

# Process all the Users

$Users | ForEach-Object {

      Write-Host "Processing user: $($_.Name)" -ForegroundColor Cyan

      $path = "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Local\Temp\Outlook Logging\"

      $path2 = "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Local\Temp\"

      If (Test-Path $path) {

        Write-host "Removing log files from $path" -ForegroundColor Cyan

        Remove-Item -Path $path -Recurse

        Write-host "Creating dummy file to prevent log files" -ForegroundColor Cyan

        New-Item -Path "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Local\Temp" -Name "Outlook Logging" -ItemType File

      }
        Remove-Item -Path $path2 -Recurse

        Write-host "Deleting temp files" -ForegroundColor Cyan

}
#Delete all logs in the C:\programdata\teradici\PcoipClient\logs folder older than 7 days 
$Path = "C:\ProgramData\Teradici\PcoipAgent\logs"
$Days = "-7"
$CurrentDate = Get-Date
$DateToDelete = $CurrentDate.AddDays($Days)
Get-ChildItem -Path $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DateToDelete } | Remove-Item -Force