# Connect to Microsoft Entra ID
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Install-Module Microsoft.Graph -Scope CurrentUser
Get-InstalledModule Microsoft.Graph
Get-MgUser

# Create a new administrative user
$verifiedDomain = (Get-MgOrganization).VerifiedDomains[0].Name
$PasswordProfile = @{  
    "Password"="<123qwe!@#QWE>";  
    "ForceChangePasswordNextSignIn"=$true  
}  
New-MgUser -DisplayName "Noreen Riggs" -UserPrincipalName "Noreen@$verifiedDomain" -AccountEnabled -PasswordProfile $PasswordProfile -MailNickName "Noreen"
$user = Get-MgUser -UserId "Noreen@$verifiedDomain"
$role = Get-MgDirectoryRole | Where {$_.displayName -eq 'Global Administrator'}
$OdataId = "https://graph.microsoft.com/v1.0/directoryObjects/" + $user.id  
New-MgDirectoryRoleMemberByRef -DirectoryRoleId $role.id -OdataId $OdataId    
Get-MgDirectoryRoleMember -DirectoryRoleId $role.id

# Create and license a new user
New-MgUser -DisplayName "Allan Yoo" -UserPrincipalName Allan@$verifiedDomain -AccountEnabled -PasswordProfile $PasswordProfile -MailNickName "Allan"
Update-MgUser -UserId Allan@$verifiedDomain -UsageLocation US
Get-MgSubscribedSku | FL
$SkuId = (Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Office_365_E5_(no_Teams)" }).SkuId
Set-MgUserLicense -UserId Allan@$verifiedDomain -AddLicenses @{SkuId = $SkuId} -RemoveLicenses @()

# Create and populate a group
Get-MgGroup
New-MgGroup -DisplayName "Sales Security Group" -MailEnabled:$False  -MailNickName "SalesSecurityGroup" -SecurityEnabled
$group = Get-MgGroup -ConsistencyLevel eventual -Count groupCount -Search '"DisplayName:Sales Security"'
$user = Get-MgUser -UserId Allan@$verifiedDomain
New-MgGroupMember -GroupId $group.id -DirectoryObjectId $user.id
Get-MgGroupMember -GroupId $group.id