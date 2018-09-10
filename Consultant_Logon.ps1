$logon = [PScustomobject]@{
Username = $env:USERNAME
Computername = $env:COMPUTERNAME
Time = Get-Date
Description = (net user /domain $env:USERNAME | select-string Comment | select -first 1).line.substring(29)
} 

$logon | export-csv c:\temp\logons2.csv -NoTypeInformation -append


$username= 'sccmclient'
$password= ConvertTo-SecureString -String "C0nnectMe" -AsPlainText -Force
$EmailCredentials= New-Object System.Management.Automation.PSCredential($username, $password)
  

$EmailParameters = @{
    TO = "jtidwell@pierceatwood.com"
    Subject = '{0} has logged onto {1} at {2}' -f $logon.username, $logon.computername, $logon.time
    Body = '{0} has logged onto {1} at {2}' -f $logon.username, $logon.computername, $logon.time
    BodyAsHtml = $True
    Priority = "High"
    Port = "587"
    SmtpServer = "relay.pierceatwood.com"
    Credential = $EmailCredentials
    From = "jtidwell@pierceatwood.com" }

Send-MailMessage @EmailParameters