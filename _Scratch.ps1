$array = @(1,2,3,5,7,11)

foreach($item in $array)
{
    Write-Output $item
}

Write-Output $array[3]





param ($COMPUTERNAME ='localhost')
gwmi win32_logicaldisk -ComputerName $COMPUTERNAME