# Add Toshiba printer using IPP

# Setup logging
$logPath = "C:\Savant\ToshibaPrinterInstall.log"
$logDir = Split-Path -Path $logPath -Parent
if (-not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force 
}

# Start transcript to capture all output
Start-Transcript -Path $logPath -Append -Force
$printerName = "Toshiba e-STUDIO 4215AC"
$portName = "IP_192.168.2.250"
$ipAddress = "192.168.2.250"
$ScriptPath = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
$driverInfPath = "$ScriptPath\driver\eSf6u.inf"

#Register the printer driver using pnputil without install, and use both the 32 and 64 bit full paths of pnputil -a
C:\Windows\Sysnative\pnputil.exe /add-driver "$driverInfPath" | Out-Null
C:\Windows\system32\pnputil.exe /add-driver "$driverInfPath" | Out-Null

if (-not (Test-Path -Path $driverInfPath)) {
    Write-Error "Driver INF file not found at $driverInfPath"
    Stop-Transcript
    exit 1

# Install the printer driver
try {
    Add-PrinterDriver -Name $driverName -ErrorAction Stop
} catch {
    Write-Error "Failed to add printer driver: $_"
}

# Create IPP printer port
try {
    Add-PrinterPort -Name $portName -PrinterHostAddress $ipAddress -ErrorAction Stop
} catch {
    Write-Error "Failed to create printer port: $_"
}

# Add the printer
try {
    Add-Printer -Name $printerName -DriverName $driverName -PortName $portName -ErrorAction Stop
} catch {
    Write-Error "Failed to add printer: $_"
}

Write-Output "Printer installation completed successfully"
}

# Install the printer driver
Add-PrinterDriver -Name $driverName 

# Create IPP printer port
Add-PrinterPort -Name $portName -PrinterHostAddress $ipAddress

# Add the printer
Add-Printer -Name $printerName -DriverName $driverName -PortName $portName

# Verify printer installation
$installedPrinter = Get-Printer -Name $printerName -ErrorAction SilentlyContinue

if ($installedPrinter) {
    Write-Output "Printer '$printerName' is installed"
    $successFilePath = "C:\savant\ToshibaPrinterInstallSuccess"
    $successDir = Split-Path -Path $successFilePath -Parent
    
    if (-not (Test-Path -Path $successDir)) {
        New-Item -Path $successDir -ItemType Directory -Force | Out-Null
    }
    
    Set-Content -Path $successFilePath -Value "Installed" -Force
    Write-Output "Success file created at $successFilePath"
} else {
    Write-Error "Printer '$printerName' is not installed"
}

Stop-Transcript