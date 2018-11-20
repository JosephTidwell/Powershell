Start-Process msiexec.exe -Wait -ArgumentList '/I C:\installers\SQLIO.msi /quiet'


$file = get-item C:\temp\jre1.8.0_181_64.msi

$DataStamp = get-date -Format yyyyMMddTHHmmss
$logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f $file.fullname)
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)

Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow