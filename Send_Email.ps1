$username= 'sccmclient'
$password= ConvertTo-SecureString -String "C0nnectMe" -AsPlainText -Force
$EmailCredentials= New-Object System.Management.Automation.PSCredential($username, $password)


$EmailParameters = @{
    TO = $To
    Subject = "Stuff here"
    Body = "Stuff here"
    BodyAsHtml = $True
    Priority = "High"
    UseSSL = $True
    Port = "587"
    SmtpServer = "smtp.office365.com"
    Credential = $EmailCredentials
    From = $From }

Send-MailMessage @EmailParameters