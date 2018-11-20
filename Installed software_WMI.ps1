get-wmiobject Win32_Product | Format-Table IdentifyingNumber, Name, LocalPackage, installlocation -AutoSize

gci -path hklm:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match "Google Chrome" } | Select-Object -Property DisplayName, UninstallString


##############################################################################################################################################


$computers = (Get-ADComputer -SearchBase 'OU=desktops,OU=boston win7,OU=Workstations,DC=pierceatwood,DC=com' -filter *).name

$Workstations=@()

foreach ($computer in $computers) {
$comp = gwmi win32_computersystem -ComputerName $computer -ErrorAction SilentlyContinue
$chrome = get-wmiobject Win32_Product -ComputerName $computer -Filter "name = 'Google Chrome'" -ErrorAction SilentlyContinue

$Workstations += [PScustomobject]@{Name=$comp.Name; Version=$chrome.version}
}


#############################################################################################################################################


$computers = (Get-ADComputer -SearchBase 'OU=desktops,OU=portsmouth win7,OU=Workstations,DC=pierceatwood,DC=com' -filter *).name

foreach ($computer in $computers) {


$firefox = invoke-command -computername $computer -scriptblock { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox 61.0.1 (x64 en-US)"} -ErrorAction SilentlyContinue | select comments
"$($computer) has' $($firefox)"

}