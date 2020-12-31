##################METADATA#################### 
#NAME: Daniel Johansson
#USERNAME: b18danjo
#COURSE: Script programmingIT384G –Spring 2019
#ASSIGNMENT: Assignment 2 -PowerShell#DATE OF LAST CHANGE: 2019-05-28T17:18:30+02:00
################################################

# AD användare
$ADUSERS = Get-Aduser -Filter * -Searchbase "DC=script, DC=local" | Select SamAccountName

#Tid
$begin = '17:00:00'
$end = '05:30:00'


# Hämtar lyckade inloggnigar mellan 05:30 til 17:00
$TimedsuccessLogins = get-eventlog -LogName Security -InstanceId 4768 -after $begin -before $end | select timewritten,machinename,@{n='Username';e={$_.replacementstrings[0]}}

# Hämtar lyckade inloggnigar
$successLogins = get-eventlog -LogName Security -InstanceId 4768 | select timewritten,machinename,@{n='Username';e={$_.replacementstrings[0]}} | Sort-Object -Property TimeWritten -Descending

# Hämtar misslyckade inloggningar för en dag sen(-After (Get-Date).AddDays(-1))
$failedLogins = get-eventlog -LogName Security -EntryType FailureAudit -InstanceId 4771 | select timewritten,machinename,@{n='Username';e={$_.replacementstrings[0]}} | Sort-Object -Property TimeWritten -Descending

# arrrays
$filter = @{
suck = @{
        user=@{}
        }
fail = @{
        user=@{}
        
        }
}


# skapar listor
foreach($user in $ADUSERS)
{
    foreach($suck in $successLogins)
    {
        if($suck.Username -eq $user.SamAccountName)
        {
            $filter.suck.user.Values += $suck.Username
            $filter.suck.user.Keys += $suck.TimeWritten
        }        
}
    foreach($fail in $failedLogins)
    {
        if($fail.Username -eq $user.SamAccountName)
        {
            $filter.fail.user.Values += $fail.Username
            $filter.fail.user.Keys += $fail.TimeWritten
        }
     }
    
}

 
# skriver ut de lyckade och misslyckade inloggnigar 
Write-Host "`nLyckade inloggningar per användare" -ForegroundColor Green
$filter.suck.user.Values |Group-Object -Property $_.Group | Format-Table -Property Name, Count
        
Write-Host "`nMisslyckade inloggningar per dag" -ForegroundColor Red
echo $failedLogins | group {$_.TimeWritten.Date.ToString('yyyy-MM-dd')} -NoElement | sort Count -Descending |Format-Table -Property @{L='Date'; E={$_.Name}},Count 

# Variablerna för beräkning
$getallfailedlogins = $filter.fail.user.Values |Group-Object -Property $_.Group 
$allFailedLogins = $filter.fail.user.Values+$filter.suck.user.Values | Measure-Object 

# skriver ut "Andel misslyckade inlogging per användare" 
Write-Host "Andel misslyckade inlogging per användare" -ForegroundColor Yellow
foreach($line in $getallfailedlogins)
{

    Write-Host $line.Name -NoNewline | Select-Object -Property AccountName 
    Write-Host " : "($line.Count/$allFailedLogins.Count).ToString("P")
    
}

