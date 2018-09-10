$creds = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://svrexch01.pierceatwood.com/PowerShell -Authentication Kerberos -Credential $creds
Import-PSSession $session
