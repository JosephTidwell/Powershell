
Invoke-Command -ComputerName p1210nx -ScriptBlock {
New-PSDrive -Name HU -PSProvider Registry -Root HKEY_USERS
Get-ItemProperty 'HU:\HKEY_USERS\S-1-5-21-661337618-1437300060-1552899311-7210\Control Panel\Desktop\' | select ForegroundLockTimeout
}


Invoke-Command -ComputerName p1208x -ScriptBlock {
New-PSDrive -Name HU -PSProvider Registry -Root HKEY_USERS
Get-ItemProperty 'HU:\HKEY_USERS\S-1-5-21-661337618-1437300060-1552899311-26278\Control Panel\Desktop\' | select ForegroundLockTimeout
}