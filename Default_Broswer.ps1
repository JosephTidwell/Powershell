$Browser = Get-ItemProperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' -Name 'ProgID' | select progid
$Computer = $env:COMPUTERNAME
$User = $env:USERNAME
$Program = $browser.ProgID

if ( $browser.ProgId -eq 'IE.HTTP' ) { "IE is default for $User on $Computer " | out-file '\\svrapps\IETracking\IE.csv' -Append }
else { "$program is default for $User on $Computer" | out-file '\\svrapps\IETracking\IE.csv' -Append }