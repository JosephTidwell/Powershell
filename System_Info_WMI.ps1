$computers = (Get-ADComputer -SearchBase 'OU=desktops,OU=portsmouth win7,OU=Workstations,DC=pierceatwood,DC=com' -filter *).name

$Workstations=@()

foreach ($computer in $computers) {

$comp = gwmi win32_computersystem -computer $computer -ErrorAction SilentlyContinue
$Bios = gwmi win32_bios -computername $computer -ErrorAction SilentlyContinue
$IMEversion = gwmi Win32_PnPSignedDriver -ComputerName $computer -ErrorAction SilentlyContinue | Where-Object {$_.DeviceName -like "*Intel(R) Management Engine Interface*"}
$IMEFirmware= invoke-command -computername $computer -scriptblock { Get-ItemProperty "HKLM:\SOFTWARE\Intel\Setup and Configuration Software\INTEL-SA-00086 Discovery Tool\ME Firmware Information"} -ErrorAction SilentlyContinue

$Workstations += [PScustomobject]@{Name=$computer; Version = $bios.smbiosbiosversion; IMEversion=$IMEversion.driverversion; IMEFirmware=$IMEFirmware.'ME Version' ;Model=$comp.model}

}


$Workstations | Export-Csv c:\temp\pnh_workstation.csv -NoTypeInformation


