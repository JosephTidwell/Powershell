$users = Get-Aduser -SearchBase "ou=employees,dc=pierceatwood,dc=com" -filter 'enabled -eq $True' |
foreach-object {
Add-ADGroupMember -Identity 'claromentis users' -members $_ }


 #>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


$users = get-content C:\temp\usernames.csv |
foreach-object {
Add-ADGroupMember -Identity 'claromentis users' -members $_ }



