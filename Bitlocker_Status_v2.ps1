$BitLocker = Get-WmiObject -ComputerName 'p1165lx' -Namespace "Root\cimv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume" -Filter "DriveLetter = 'C:'"

                $ProtectorIds = $BitLocker.GetKeyProtectors("0").volumekeyprotectorID       

                $return = @()

                foreach ($ProtectorID in $ProtectorIds){

                $KeyProtectorType = $BitLocker.GetKeyProtectorType($ProtectorID).KeyProtectorType

                $keyType = ""

                    switch($KeyProtectorType){

                        "0"{$Keytype = "Unknown or other protector type";break}

                        "1"{$Keytype = "Trusted Platform Module (TPM)";break}

                        "2"{$Keytype = "External key";break}

                        "3"{$Keytype = "Numerical password";break}

                        "4"{$Keytype = "TPM And PIN";break}

                        "5"{$Keytype = "TPM And Startup Key";break}

                        "6"{$Keytype = "TPM And PIN And Startup Key";break}

                        "7"{$Keytype = "Public Key";break}

                        "8"{$Keytype = "Passphrase";break}

                        "9"{$Keytype = "TPM Certificate";break}

                        "10"{$Keytype = "CryptoAPI Next Generation (CNG) Protector";break}

                    }#endSwitch

 $Properties = @{"KeyProtectorID"=$ProtectorID;"KeyProtectorType"=$Keytype}

  $Return += New-Object -TypeName psobject -Property $Properties

                }#EndForeach

Return $Return