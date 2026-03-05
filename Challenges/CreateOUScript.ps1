$OUName="London"
$DomainDN="DC=Adatum,DC=com"
$OUPath="OU=$OUName,$DomainDN"
# if AD OU London doesn't exist, create it. Else 
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OUPath'"){
    Write-Host "$OUName OU already exists"
}   else {
    Write-Host "OU does not exist and has been created."
    New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
}
# Create a Global Security Group for the London OU named "London Users"
if (Get-ADGroup -Identity "London Users") {
    Write-Host "London Users Security Group is already created."
}
else {
    Write-Host "Creating London Users global security group."
    New-ADGroup -Name 'London Users' -GroupScope Global -GroupCategory Security -Path $OUPath -ErrorAction SilentlyContinue
}
# Variable with all users in the Sales OU with a city of London
$SalesUsers=Get-ADUser -Filter * -SearchBase "OU=Sales,DC=Adatum,DC=com" -Properties city | Where-Object {$_.city -eq "London"}
# Shows a list of Sales users with city of London
# $SalesUsers | Select Name, city
# For each user in sales OU, if they have an address in the city of London, move them into the London OU
if ($SalesUsers.count -gt 0) {
    Write-Host "Moving users from Sales OU with a city of London to the London OU."
    $SalesUsers | ForEach-Object{
        Move-ADObject -Identity $_.distinguishedName -TargetPath $OUPath
}}
else {
    Write-Host "No users in the Sales OU have city of London."
}
# Add the London OU users into the London Users security group
$LondonSecurityGroup=Get-ADGroupMember -Identity 'London Users' -Recursive | Select-Object -ExpandProperty distinguishedName
$LondonUsers=Get-ADUser -Filter * -SearchBase $OUPath
$LondonUsers | ForEach-Object {
    if ($LondonSecurityGroup -contains $_.distinguishedName) {
        Write-host "$($_.samaccountname) is already in the London Users security group." 
    }
    else {
        Add-ADGroupMember -Identity "London Users" -Members $_.distinguishedName
        Write-Host "ADDED: $($_.samaccountname) to the London Users security group."
}
}