#This Script will disable the VMWare SVGA Device

Start-Transcript C:\savant\VMWareSVGA.log -Append

$VMWAreSVGA = get-pnpdevice | where-object {$_.friendlyname -eq "VMware SVGA 3D"}

Disable-PnpDevice -InstanceId $VMWAreSVGA.InstanceId -Confirm:$false
$VMWAreSVGA = get-pnpdevice | where-object {$_.friendlyname -eq "VMware SVGA 3D"}

if ($VMWAreSVGA.Status -eq "Disabled") {
    Write-Host "VMWare SVGA 3D is disabled"
} else {
    Write-Host "VMWare SVGA 3D is not disabled"
}