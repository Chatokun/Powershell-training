#Powershell Script to check if ring central is installed using get-wmiobject
#If not installed, install using c:\savant\RingCentral-x64.msi
#Export all results, host writes, and errors to a log file at C:\Savant\RingCentralinstall.log

Start-Transcript -Path "C:\Savant\RingCentralinstall.log" -Append

try {
    $RingCentral = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq "RingCentral"}

    if ($RingCentral -eq $null) {
        Write-Host "RingCentral is not installed"
        Start-Process -FilePath "c:\savant\RingCentral-x64.msi" -ArgumentList "/quiet" -Wait
        Write-Host "RingCentral installation initiated"
    } else {
        Write-Host "RingCentral is installed"
    }
} catch {
    Write-Error "An error occurred: $_"
}

Stop-Transcript


