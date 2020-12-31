##################METADATA#################### 
#NAME: Daniel Johansson
#USERNAME: b18danjo
#COURSE: Script programmingIT384G –Spring 2019
#ASSIGNMENT: Assignment 2 -PowerShell#DATE OF LAST CHANGE: 2019-05-28T17:18:30+02:00
################################################

# den loopar tills den använder en break
do{

# hämtar IP adresser som används
$inuseIPs = Get-DhcpServerv4Lease -ComputerName "$env:COMPUTERNAME" -ScopeId 192.168.1.0 -AllLeases | Sort-Object -Property LeaseExpiryTime

# hämtar IP adresser som inte används
$freeIP = Get-DhcpServerv4FreeIPAddress -ScopeId 192.168.1.0 -StartAddress 192.168.1.150 -EndAddress 192.168.1.200 -NumAddress 50 -ErrorAction Continue -WarningAction SilentlyContinue

# hämtar IP adresser som 
$getReserv = Get-DhcpServerv4Scope -ComputerName "$env:COMPUTERNAME" | Get-DhcpServerv4Reservation -ComputerName "$env:COMPUTERNAME"

# inmatning
$userinput = Read-Host "(M)ake reservation, (F)ree IP addresses, (R)eservation, (I)Ps in use or click Enter to exit "

# skriver ut om användaren vill gör en resarvation på en de aktiva Leases
if($userinput -eq "M")
{
    $inuseIPs | Where-Object {$_.AddressState -like "Active"} | Format-Table -Property IPAddress,ScopeId,ClientId,HostName,AddressState,LeaseExpiryTime

    $quest = Read-Host "Do you still wanna make a Reservation? Y / N"
    if($quest -eq "Y")
    {
    $newIP = Read-Host "Write one of the active DHCP leases" 
    try
    {
        Get-DhcpServerv4Lease -ComputerName "$env:COMPUTERNAME" -IPAddress $newIP | Add-DhcpServerv4Reservation -ComputerName "$env:COMPUTERNAME"
        Write-Host "New IP has been added to the reservation" -ForegroundColor Green
    }
    catch
    {
        Write-Warning "Write a valid IP"
    }
    }
    else
    {
        continue
    }
}
# skriver ut IP adresser i användning
elseif($userinput -eq "I")
{
    Write-Host "IPs in use" -ForegroundColor Yellow -NoNewline
    $inuseIPs | Format-Table -Property IPAddress,ScopeId,ClientId,HostName,AddressState,LeaseExpiryTime
}
# skriver ut IP adresser som är resarverade
elseif($userinput -eq "R")
{
    

    Write-Host "IPs in reservation`n" -ForegroundColor Yellow -NoNewline
    if(!$getReserv)
    {
        echo "`nNo IPs are in Reservation" 
    }
    else
    {
        $getReserv | Format-Table -Property IPAddress,ScopeId,ClientId,Name,Type,Description
    }
}
# skriver ut fria IP adresser 
elseif($userinput -eq "F")
{
    Write-Host "`nFree IP address" -ForegroundColor Yellow
    $freeIP 
}
# bryter loopen
else
{
    break
}
}while($true)