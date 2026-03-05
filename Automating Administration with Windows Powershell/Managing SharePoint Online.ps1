# Connect to SharePoint Online
$verifiedDomain = "LODSA230445.onmicrosoft.com"
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser
$verifiedDomainShort = $verifiedDomain.Split(".")[0]
Import-Module -Name Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url "https://LODSA230445-admin.sharepoint.com"