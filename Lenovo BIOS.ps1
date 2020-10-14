
#Connect to the Lenovo_SetBiosSetting WMI class
$Interface = Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting
 
#Set a specific BIOS setting when a BIOS password is not set
$Interface.SetBiosSetting("TCG Security Device,Firmware TPM")
 
#Set a specific BIOS setting when a BIOS password is set
#$Interface.SetBiosSetting("SettingName,SettingValue,Password,ascii,us")

#Connect to the Lenovo_BiosSetting WMI class
#$SettingList = Get-WmiObject -Namespace root\wmi -Class Lenovo_BiosSetting
 
#Return a list of all configurable settings
#$SettingList | Select-Object CurrentSetting
 
#Return a specific setting and value
#$SettingList | Where-Object CurrentSetting -Like "*Firmware TPM*" | Select-Object -ExpandProperty CurrentSetting

#Connect to the Lenovo_SaveBiosSetting WMI class
$SaveSettings = Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings
 
#Save any outstanding BIOS configuration changes
$SaveSettings.SaveBiosSettings()