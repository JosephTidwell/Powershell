Get-Aduser -SearchBase "ou=employees,dc=pierceatwood,dc=com" -filter 'enabled -eq $True' -Properties * | 
    select displayname,mailnickname,givenname,surname,Title,company,telephonenumber,emailaddress,mobilephone,office,streetaddress| 
    export-csv c:\temp\users.csv

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

$users = Import-Csv C:\temp\usernames.csv

 foreach ($user in $users){

 $username =  $user.name

 get-aduser -Filter {displayname -eq $username} -properties * | select samaccountname
 }

 #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 $users = Import-Csv C:\temp\usernames.csv | select -ExpandProperty name

 foreach ($user in $users){

  get-aduser -Filter {displayname -eq $user} -properties * | select samaccountname
 }

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


 Get-Aduser -SearchBase "ou=employees,dc=pierceatwood,dc=com" -filter 'enabled -eq $True' -Properties whencreated |
where {$_.whencreated -ge '8/1/2018 1:00:00 AM'} | select samaccountname, whencreated

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


$When = ((Get-Date).AddDays(-30)).Date
Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated


#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

$ous = "ou=employees,dc=pierceatwood,dc=com","ou=former employees,dc=pierceatwood,dc=com"
 
$obj = $ous | foreach {

Get-ADUser -Filter {Enabled -eq $false} -SearchBase $_  }
