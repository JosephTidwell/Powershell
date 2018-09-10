$computers = (Get-ADComputer -SearchBase 'OU=training,OU=portland Win7,OU=Workstations,DC=pierceatwood,DC=com' -filter *).name

Get-CimInstance -ComputerName $computers -Namespace "root\cimv2\security\microsoftvolumeEncryption" -classname win32_encryptablevolume -filter "driveletter = 'c:'" -ErrorAction SilentlyContinue |
select  pscomputername, protectionstatus, conversionstatus

