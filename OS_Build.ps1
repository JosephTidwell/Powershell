$computers = "P1202D","P1241D","P1279D","P1364D","P1365D","P1392D","P1133D","P1227D","p1162d"

Get-WmiObject -ComputerName $computers -class win32_operatingsystem | select version, buildnumber

#Get-WmiObject -class win32_operatingsystem | select version, buildnumber