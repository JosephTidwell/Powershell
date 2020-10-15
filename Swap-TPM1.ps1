
Function Swap-TPM {
    
        
    #Connect to the Lenovo_SetBiosSetting WMI class
    $Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting
     
    #Set a specific BIOS setting when a BIOS password is not set
    $Interface.SetBiosSetting("TCG Security Device,Firmware TPM")
    
    #Connect to the Lenovo_SaveBiosSetting WMI class
    $SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings
     
    #Save any outstanding BIOS configuration changes
    $SaveSettings.SaveBiosSettings()
    
        
    }
    
    #Check TPM state before swapping
    $tpm =get-tpm
    if ($tpm.tpmpresent -eq $false){
        write-host 'TPM not present' -BackgroundColor Red -ForegroundColor Yellow
        swap-tpm
    } else {  
        write-host 'TPM is present' -BackgroundColor Red -ForegroundColor Yellow 
        }
     
     #Check Bitlocker state before re-enabling
    
     if ((Get-BitLockerVolume c:).volumestatus -eq 'FullyDecrypted'-and $tpm.tpmpresent -eq $True ) {
        Write-host 'Enabling Bitlocker' -BackgroundColor Red -ForegroundColor Yellow
        Enable-BitLocker C: -RecoveryPasswordProtector -UsedSpaceOnly -SkipHardwareTest
        $BLV = Get-BitLockerVolume -MountPoint "C:"
        Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    }
    else {
        Write-host 'Disabling Bitlocker' -BackgroundColor Red -ForegroundColor Yellow
        Disable-BitLocker C:
    }