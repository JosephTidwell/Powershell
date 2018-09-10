Param(
	[Parameter(Mandatory = $true)]
	[array] $Mailboxes,
	[Parameter(Mandatory = $true)]
	[string] $TempPSTLocation,
	[Parameter(Mandatory = $false)]
	[string] $ExportStatusCheckInterval,
	[Parameter(Mandatory = $false)]
	[string] $ExportOnly,
	[Parameter(Mandatory = $false)]
	[string] $ExchangeServer
)
	
#Default password is password1
$password = "Password1"


#Set default value for exportonly
if(!$ExportOnly)
    {
        $ExportOnly = $false
    }

#Set default value for ExchangeServer
if(!$ExchangeServer)
    {
        $ExchangeServer = "localhost"
    }

#Set default value for ExchangeServer
if(!$ExportStatusCheckInterval)
    {
        $ExportStatusCheckInterval = 450
    }

Import-Module ActiveDirectory
$connectionUri = "http://" + $ExchangeServer + "/PowerShell/"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $connectionUri -Authentication Kerberos
Import-PSSession $Session -AllowClobber -WarningAction SilentlyContinue | Out-Null

foreach ($mailbox in $mailboxes)
    {
        Write-Host Processing $mailbox -ForegroundColor Green
        $mailbox = Get-Mailbox $mailbox

        #Get user details
        $ADUser = Get-ADUser $mailbox.SamAccountName

        #Export user groups
        Write-Host Getting group membership
        $groups = (Get-ADUser $mailbox.SamAccountName -Properties MemberOf).MemberOf

        #Get user OU
        Write-Host Getting user OU
        $DistinguishedName = (Get-ADUser $mailbox.SamAccountName).DistinguishedName
        $string = ($DistinguishedName -split ",")[0] + ","
        $OU = $DistinguishedName -replace $string,""

        #Get mailbox database
        Write-Host Getting mailbox database for user
        $MailboxDatabase = $mailbox.Database

        #Export calendar permissions
        Write-Host Getting calendar permissions
        $folder = $mailbox.alias + ":\Calendar"
        $calendarPermissions = Get-MailboxFolderPermission -Identity $folder

        #Export mailbox permissions
        Write-Host Getting mailbox permissions
        $mailboxPermissions = Get-MailboxPermission -Identity $mailbox.Name | ? {$_.IsInherited -eq $false}

        #Export send as permissions
        Write-Host Getting SendAs permissions
        $sendAsPermissions = Get-ADPermission $mailbox.Name | ? {$_.ExtendedRights -match "send-as" -and $_.IsInherited -eq $false}

        #Get mailbox email addresses and whether hidden from address lists
        Write-Host Getting email addresses and email address policy settings
        $EmailAddressPolicyEnabled = $mailbox.EmailAddressPolicyEnabled
        $emailAddresses = $mailbox.EmailAddresses

        #Get list of all mailboxes
        $AllMailboxes = Get-Mailbox -ResultSize Unlimited

        #Get permissions on other mailboxes
        Write-Host Getting permissions on other mailboxes
        $PermissionsOnOtherMailboxes = $AllMailboxes | Get-MailboxPermission -User $mailbox.SamAccountName

        #Get Send As permissions on other mailboxes
        Write-Host Getting Send As permissions on other mailboxes
        $SendAsPermissionsOnOtherMailboxes = $AllMailboxes | Get-ADPermission -User $mailbox.SamAccountName | ? {$_.ExtendedRights -match "send-as" -and $_.IsInherited -eq $false}

        #Get calendars the user has access to
        Write-Host Getting calendar permissions on other calendars
        $CalendarPermissionsOnOtherMailboxes = @()
        $AllMailboxes | % {
                $identity = $_.Alias + ":\Calendar"
                $mailboxFolderPermission = Get-MailboxFolderPermission -Identity $identity -User $mailbox.SamAccountName -ErrorAction SilentlyContinue
                if ($mailboxFolderPermission)
                    {
                        $CalendarPermissionsOnOtherMailbox = New-Object System.Object
                        $CalendarPermissionsOnOtherMailbox | Add-Member -Type NoteProperty -Name Identity -Value $identity
                        $CalendarPermissionsOnOtherMailbox | Add-Member -Type NoteProperty -Name AccessRights -Value $mailboxFolderPermission.AccessRights
                        $CalendarPermissionsOnOtherMailboxes += $CalendarPermissionsOnOtherMailbox
                    }
            }



        #Clean up previous export requests for the mailbox and export email to pst
        Write-Host Cleaning up previous export requests for $mailbox.Name
        Get-MailboxExportRequest -Mailbox $mailbox.Name | Remove-MailboxExportRequest -Confirm:$false
        $filePath = $tempPSTLocation + "\" + $mailbox.SamAccountName + ".pst"
        Write-Host Exporting Mailbox $mailbox.Name
        New-MailboxExportRequest -Mailbox $mailbox.SamAccountName -FilePath $filePath -BadItemLimit 10000 -AcceptLargeDataLoss -WarningAction SilentlyContinue -Confirm:$false | Out-Null

        #Check mailbox export request completed without errors every configured interval for 12hrs
        $NumberOfTimesToCheckExportRequest = 12*3600 / $ExportStatusCheckInterval
        For ($i = 1 ; $i -lt $NumberOfTimesToCheckExportRequest ; $i++)
	        {
                $mailboxExportStatus = (Get-MailboxExportRequest -Mailbox $mailbox.Name).Status
                #if not completed, wait and check again in after configured export status check interval
                if($mailboxExportStatus -match "InProgress" -or $mailboxExportStatus -eq "Queued")
                    {
                        $mailboxExportProgressPercentage = (Get-MailboxExportRequest -Mailbox $mailbox.Name | Get-MailboxExportRequestStatistics).PercentComplete
                        Write-Host Waiting for export to complete. Currently at $mailboxExportProgressPercentage%
                        sleep $ExportStatusCheckInterval
                    }

                #if error then report and stop script
                if($mailboxExportStatus -match "Failed")
                    {
                        Write-Host Mailbox Export Failed for $mailbox.Name -ForegroundColor Red
                    }

		        #if completed without issues, remove user and mailbox, recreate user and mailbox, import email, assign email addresses, calendar folder permissions, 
                #mailbox permissions, AD group memberships,
                if($mailboxExportStatus -match "Completed" -and $ExportOnly -ne $true)
                    {
                        Write-Host Mailbox Export Completed
                        #Stop checking mailbox export request
                        $i = $NumberOfTimesToCheckExportRequest
                        
                        #Remove mailbox and user account
                        Write-Host Deleting mailbox $mailbox.Name
                        Remove-Mailbox $mailbox.SamAccountName -Confirm:$false

                        #Recreate user account
                        Write-Host Recreating user account
                        $password = ConvertTo-SecureString $password -AsPlainText -Force
                        New-ADUser -Path $OU -SamAccountName $mailbox.SamAccountName -Name $mailbox.Name -GivenName $ADUser.GivenName -Surname $ADUser.Surname
                        Write-Host Resetting password on user account
                        Set-ADAccountPassword -Identity $mailbox.SamAccountName -Reset -NewPassword $password
                        Write-Host Enabling user account
                        Enable-ADAccount $mailbox.SamAccountName

                        #Add user to correct groups
                        Write-Host Adding user to groups
                        $groups | % {Add-ADGroupMember -Identity $_ -Members $mailbox.SamAccountName}

                        #Create new mailbox and attach to user account
                        Write-Host Creating new mailbox
                        Enable-Mailbox $mailbox.Alias -Database $MailboxDatabase | Out-Null

                        #Import email
                        Write-Host Starting Import of mailbox $mailbox.Name
                        New-MailboxImportRequest $mailbox.SamAccountName -FilePath $filePath | Out-Null

                        #Add email addresses to user
                        Write-Host Setting email addresses on mailbox and setting email address policy settings
                        Set-Mailbox $mailbox.Name -EmailAddresses $emailAddresses -EmailAddressPolicyEnabled $EmailAddressPolicyEnabled
        
                        #Set calendar permissions
                        Write-Host Setting calendar permissions for default and anonymous users
                        $calendarPermissions | ? {$_.User -match "Default" -or $_.User -match "Anonymous"} | % {Set-MailboxFolderPermission -Identity $folder -User $_.User -AccessRights $_.AccessRights -WarningAction SilentlyContinue | Out-Null}
                        Write-Host Setting calendar permissions for other users
                        $calendarPermissions | ? {$_.User -notmatch "Default" -and $_.User -notmatch "Anonymous"} | % {Add-MailboxFolderPermission -Identity $folder -User $_.User -AccessRights $_.AccessRights -WarningAction SilentlyContinue | Out-Null}
                        
                        #Set mailbox permissions
                        Write-Host Setting mailbox permissions
                        $mailboxPermissions | ? {$_.User -notmatch "NT AUTHORITY\\SELF"} | % {Add-MailboxPermission -Identity $mailbox.Name -User $_.User -AccessRights $_.AccessRights -WarningAction SilentlyContinue | Out-Null}

                        #Set Send As permissions
                        Write-Host Setting Send As permissions
                        $sendAsPermissions | ? {$_.User -notmatch "NT AUTHORITY\\SELF"} |  % {Add-ADPermission -Identity $mailbox.Name -User $_.User -ExtendedRights $_.ExtendedRights -WarningAction SilentlyContinue | Out-Null}

                        #Set permissions on other mailboxes
                        Write-Host Setting mailbox permissions on other mailboxes
                        $PermissionsOnOtherMailboxes | % {Add-MailboxPermission -Identity $_.Identity -AccessRights $_.AccessRights -User $mailbox.SamAccountName -WarningAction SilentlyContinue | Out-Null}

                        #Set Send As permissions on other mailboxes
                        Write-Host Setting Send As permissions on other mailboxes
                        $SendAsPermissionsOnOtherMailboxes | % {Add-ADPermission -Identity $_.Identity -ExtendedRights $_.ExtendedRights -User $mailbox.SamAccountName -WarningAction SilentlyContinue | Out-Null}

                        #Set Send As permissions on other mailboxes
                        Write-Host Setting Send As permissions on other mailboxes
                        $CalendarPermissionsOnOtherMailboxes | % {Add-MailboxFolderPermission -Identity $_.Identity -AccessRights $_.AccessRights -User $mailbox.SamAccountName -WarningAction SilentlyContinue | Out-Null}
                        
                    }
                if($mailboxExportStatus -match "Completed" -and $ExportOnly -eq $true)
                    {
                        #Stop checking mailbox export request
                        $i = $NumberOfTimesToCheckExportRequest
                        Write-Host Mailbox Export Completed. End of script. 
                    }
	        }
        Write-Host Finished processing $mailbox.SamAccountName
    }


