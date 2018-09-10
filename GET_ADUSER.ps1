Get-Aduser -SearchBase "ou=employees,dc=pierceatwood,dc=com" -filter 'enabled -eq $True' -Properties * | 
    select displayname,mailnickname,givenname,surname,Title,company,telephonenumber,emailaddress,mobilephone,office,streetaddress| 
    export-csv c:\temp\users.csv



$users = Import-Csv C:\temp\usernames.csv

 foreach ($user in $users){

 $username =  $user.name

 get-aduser -Filter {displayname -eq $username} -properties * | select samaccountname
 }



 $users = Import-Csv C:\temp\usernames.csv | select -ExpandProperty name

 foreach ($user in $users){

  get-aduser -Filter {displayname -eq $user} -properties * | select samaccountname
 }