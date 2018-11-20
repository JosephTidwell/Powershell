$array = @(1,2,3,5,7,11)

foreach($item in $array)
{
    Write-Output $item
}

Write-Output $array[3]




#format>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

Subject = '{0} has logged onto {1} at {2}' -f $logon.username, $logon.computername, $logon.time
Body = '{0} has logged onto {1} at {2}' -f $logon.username, $logon.computername, $logon.time



#Stuff>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


$stuff =@()

$process = get-process
$handle = $process.handle
$name = $process.processname



foreach ($h in $handle) {

"The process name is $N"

$stuff += [pscustomobject]@{Handle=

}

$Workstations += [PScustomobject]@{Name=$computer


$output = $handle, $name

