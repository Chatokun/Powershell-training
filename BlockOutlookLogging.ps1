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