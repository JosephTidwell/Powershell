
Function Swap-TPM {

    #disable-bitlocker if volume is encrypted
    if ((Get-BitLockerVolume c:).volumestatus -eq 'FullyEncrypted ') {
         Suspend-BitLocker C: -RebootCount 3
    }      
        
    #Connect to the Lenovo_SetBiosSetting WMI class
    $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting
     
    #Set a specific BIOS setting when a BIOS password is not set
    $Interface.SetBiosSetting("TCG Security Device,Firmware TPM")
    
    #Connect to the Lenovo_SaveBiosSetting WMI class
    $SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings
     
    #Save any outstanding BIOS configuration changes
    $SaveSettings.SaveBiosSettings()
    
    #Reboot to swith to AMD TPM
    Shutdown -r -t 5
    
    }
    
    #Check TPM state before swapping
    $tpm =get-tpm
    if ($tpm.tpmpresent -eq $false){
        write-host 'TPM not present' -BackgroundColor Red -ForegroundColor Yellow
       
    }
    else { swap-tpm }
     
     #Check Bitlocker state before re-enabling
    
     if ((Get-BitLockerVolume c:).volumestatus -eq 'FullyDecrypted'-and $tpm.tpmpresent -eq $True ) {
        Enable-BitLocker C: -RecoveryPasswordProtector -UsedSpaceOnly -SkipHardwareTest
        $BLV = Get-BitLockerVolume -MountPoint "C:"
        Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    }
    else {
        Write-host 'Disabling Bitlocker' -BackgroundColor Red -ForegroundColor Yellow
        Disable-BitLocker C:
    }