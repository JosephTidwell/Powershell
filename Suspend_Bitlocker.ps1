$computers = (Get-ADComputer -SearchBase 'OU=training,OU=portland Win7,OU=Workstations,DC=pierceatwood,DC=com' -filter *).name

$bitlockerstatus = Get-CimInstance -ComputerName $computers -Namespace "root\cimv2\security\microsoftvolumeEncryption" -classname win32_encryptablevolume -filter "driveletter = 'c:'" -ErrorAction SilentlyContinue |
select pscomputername, protectionstatus, conversionstatus 

$bitlockerstatus | Where-Object -Property ProtectionStatus -eq "1"
invoke-command -ComputerName $bitlockerstatus.pscomputername -scriptblock  {disable-BitLocker -MountPoint "C:"}

$bitlockerstatus | Where-Object -Property ProtectionStatus -eq "1"
invoke-command -ComputerName $bitlockerstatus.pscomputername -scriptblock  {resume-BitLocker -MountPoint "C:" -RebootCount 0}