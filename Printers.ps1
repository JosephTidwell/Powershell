Stop-Service -Name Spooler -Force

# To backup the files
Move-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*" -Destination 'C:\demo\new' -Force

# To delete the files
Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*"

Start-Service -Name Spooler