#will remove rows where txt in list.txt is found in the column "ID" in staffdata.csv

$list = Get-Content 'C:\Temp\list.txt'

Import-Csv "C:\Temp\CSVs\staffdata.csv" | where {$_.'ID' -notin $list} | Export-Csv "C:\Temp\CSVs\export\staffdata.csv" -NoTypeInformation