# Get the user we want to add 
$string = Read-Host -Prompt "What user do you want to add?" 

# Add user to the group
Add-ADGroupMember -Identity 'SEC-Fortigate FTP allowed' -members $string