#Start a transcript at c:\savant\PrinterInstall.log and create a new log file if necessary
Start-Transcript -Path "C:\savant\PrinterInstall.log" -Append

#Set the execution policy to allow the script to run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Output "This script must be run as an administrator."
    Stop-Transcript
    exit
}

# Set variables
$printerIP = "172.20.11.86"
$infPath = "\\CVG-LAW-APP01v\MEDINFO\Print Drivers\Bizhub C450i\WIN 11\KM_v4UPD_UniversalDriver_PCL_2.6.0.3\KM_v4UPD_UniversalDriver_PCL_2.6.0.3\Driver\x64\PCL6\KOBxxK__01.inf"
$printerName = "Pod D"
$portName = "IP_$printerIP"
$driverName = "KONICA MINOLTA Universal V4 PCL"

# Create the TCP/IP port for the printer
if (-not (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
    Write-Output "Creating printer port $portName..."
    Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP
} else {
    Write-Output "Printer port $portName already exists."
}

# Install the printer driver from the INF file
Write-Output "Installing printer driver..."
pnputil.exe /add-driver $infPath /install

Add-PrinterDriver -Name $driverName

# Get the driver name from the INF file (optional: replace with known name if necessary)
# You might need to replace $driverName manually if the actual driver name differs.

# Add the printer
if (-not (Get-Printer -Name $printerName -ErrorAction SilentlyContinue)) {
    Write-Output "Adding printer $printerName..."
    Add-Printer -Name $printerName -PortName $portName -DriverName $driverName
} else {
    Write-Output "Printer $printerName already exists."
}