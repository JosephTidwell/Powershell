$computers = (Get-ADComputer -SearchBase 'OU=training,OU=portland Win7,OU=Workstations,DC=pierceatwood,DC=com' -filter *).name

$bitlockerstatus = Get-CimInstance -ComputerName $computers -Namespace "root\cimv2\security\microsoftvolumeEncryption" -classname win32_encryptablevolume -filter "driveletter = 'c:'" -erroraction silentlycontinue |
select pscomputername, conversionstatus

$bitlockerstatus | Where-Object -Property conversionstatus -eq "0" |
invoke-command -ComputerName $bitlockerstatus.pscomputername -scriptblock  {

    Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector 
    Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes128 –UsedSpaceOnly -TpmProtector
}
 
  

  





<# $TPM = Get-WmiObject win32_tpm -Namespace root\cimv2\security\microsofttpm | where {$_.IsEnabled().Isenabled -eq 'True'} -ErrorAction SilentlyContinue
$WindowsVer = Get-WmiObject -Query 'select * from Win32_OperatingSystem where (Version like "6.2%" or Version like "6.3%" or Version like "10.0%") and ProductType = "1"' -ErrorAction SilentlyContinue
$SystemDriveBitLockerRDY = Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue

if ($WindowsVer -and $tpm -and !$SystemDriveBitLockerRDY) {
    Get-Service -Name defragsvc -ErrorAction SilentlyContinue | Set-Service -Status Running -ErrorAction SilentlyContinue
    BdeHdCfg -target $env:SystemDrive shrink -quiet
    Restart-Computer}




$TPM = Get-WmiObject win32_tpm -Namespace root\cimv2\security\microsofttpm | where {$_.IsEnabled().Isenabled -eq 'True'} -ErrorAction SilentlyContinue
$WindowsVer = Get-WmiObject -Query 'select * from Win32_OperatingSystem where (Version like "6.2%" or Version like "6.3%" or Version like "10.0%") and ProductType = "1"' -ErrorAction SilentlyContinue
$BitLockerReadyDrive = Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue

 
#If all of the above prequisites are met, then create the key protectors, then enable BitLocker and backup the Recovery key to AD.
if ($WindowsVer -and $TPM -and $BitLockerReadyDrive) {
 
#Creating the recovery key
Start-Process 'manage-bde.exe' -ArgumentList " -protectors -add $env:SystemDrive -recoverypassword" -Verb runas -Wait
 
#Adding TPM key
Start-Process 'manage-bde.exe' -ArgumentList " -protectors -add $env:SystemDrive  -tpm" -Verb runas -Wait
sleep -Seconds 15 #This is to give sufficient time for the protectors to fully take effect.
 
#Enabling Encryption
Start-Process 'manage-bde.exe' -ArgumentList " -on $env:SystemDrive -em aes256" -Verb runas -Wait
 
#Getting Recovery Key GUID
$RecoveryKeyGUID = (Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | where {$_.Keyprotectortype -eq 'RecoveryPassword'} | Select-Object -ExpandProperty KeyProtectorID
 
#Backing up the Recovery to AD.
manage-bde.exe  -protectors $env:SystemDrive -adbackup -id $RecoveryKeyGUID
 
#Restarting the computer, to begin the encryption process
Restart-Computer}

#>