Install-Module ExchangeOnlineManagement -force
Connect-ExchangeOnline
Get-EXOMailbox
New-Mailbox -Room -Name BoardRoom
Set-CalendarProcessing BoardRoom -AutomateProcessing AutoAccept