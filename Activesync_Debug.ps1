Set-CASMailbox alias -ActiveSyncDebugLogging:$true

Get-MobileDeviceStatistics -Mailbox alias -GetMailboxLog:$true -NotificationEmailAddresses yourEmailAddress@contoso.com