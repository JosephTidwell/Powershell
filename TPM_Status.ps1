$computers = (Get-ADComputer -SearchBase 'OU=4th Floor,OU=Portland Win7,OU=Workstations,DC=pierceatwood,DC=com' -filter *).name

$TPMstatus= @()

foreach ($computer in $computers){

$TPM = Get-CimInstance -ComputerName $computer -namespace root\cimv2\security\microsofttpm -Class win32_tpm -ErrorAction SilentlyContinue
 
$TPMstatus += [PScustomobject]@{name=$computer; enabled=$TPM.IsEnabled_InitialValue ; activated=$TPM.IsActivated_InitialValue; owned=$TPM.IsOwned_InitialValue}

}

$TPMstatus | Export-Csv c:\temp\TPMstatus.csv -NoTypeInformation



#WMI query

gwmi -Namespace root\cimv2\security\microsofttpm -Class win32_tpm

#TPM enabled

 $Tpm.IsEnabled().isenabled

#TPM activation

 $Tpm.IsActivated().isactivated

#TPM owned

 $Tpm.IsOwned().isOwned

 #TPM enable     
 
 $Tpm.Enable()

 #Don't need to be physically presence to set the TPM

  $Tpm.SetPhysicalPresenceRequest(10)