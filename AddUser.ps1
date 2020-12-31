##################METADATA#################### 
#NAME: Daniel Johansson
#USERNAME: b18danjo
#COURSE: Script programmingIT384G –Spring 2019
#ASSIGNMENT: Assignment 2 -PowerShell#DATE OF LAST CHANGE: 2019-05-28T17:18:30+02:00
################################################

Add-Type -AssemblyName System.web
Add-Type -AssemblyName System.Windows.Forms

# öppnar upp ett fönster och sparar den valda filen
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = 'Documents (*.csv)|*.csv'
    
}

$FileBrowser.ShowDialog() | Out-Null
$Global:SelectedFile = $FileBrowser.FileName

$file = Import-Csv $Global:SelectedFile -Delimiter ";" -Encoding Default 


# loopar igenom file
foreach($user in $file)
{
        $namn = $user.Name
        $email = $user.Email
        $des = $user.Description
        $dep = $user.Department
        $passcard = $user.PassCardNumber
        # 
        $password = [system.web.security.membership]::GeneratePassword(8,0)
        $OU = "OU=$dep, DC=script, DC=local"
        
        # byter bort åäö med aao
        $namn = ($namn -creplace "Å", "A")
        $namn = ($namn -creplace "Ä", "A")
        $namn = ($namn -creplace "Ö", "O")
        $namn = ($namn -creplace "é", "e")
        $namn = ($namn -creplace "ö", "o")
        $namn = ($namn -creplace "ä", "a")
        $namn = ($namn -creplace "å", "a")
        
        
        

        $getmatch = $namn -match "(?<fnamn>.[A-Z][a-z]*)\s(?<enamn>.[A-Z][a-z]*)"
    
        # skapar unika namn
        $SAN = $Matches.fnamn.Substring(0,2)+$Matches.enamn.Substring(0,2)
        $SAN=$SAN.ToLower()
        $newname = $SAN+$passcard

        # den försöker skapa en användare men om den misslyckas/error så skriver den ut att användaren redan finns
        try
        {
            try
            {
                $alreadyExists = Get-ADUser -Identity $SAN -ErrorAction SilentlyContinue
            # Om en användare som redan finns med samma namn, skapar en användare med ett användarnamn ihop med sitt passkort
            if ($alreadyExists)
            {
                
                New-ADuser -UserPrincipalName "$newname@script.local" -Name $namn -DisplayName $namn -SamAccountName $newname -Description $des -Path $OU -OtherAttributes @{'comment'=$passcard} -EmailAddress $email -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -ChangePasswordAtLogon $True -Enabled $True
                New-Item -Path "C:\SHARES\IT\useraccount\$newname.txt" -Value "Username: $newnamn  Password: $password"
            }
            
            }
            # skapar en ny användare som inte finns
            catch
            {
                New-ADuser -UserPrincipalName "$newname@script.local" -Name $namn -DisplayName $namn -SamAccountName $SAN -Description $des -Path $OU -OtherAttributes @{'comment'=$passcard} -EmailAddress $email -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -ChangePasswordAtLogon $True -Enabled $True
                Write-Host "User: $SAN is added to the AD" -ForegroundColor Green
            }
            # testar att lägga till en användare i en group 
            try
            {
                Add-ADGroupMember -Identity $dep -Members $SAN
            }
            catch
            {
               Write-Host "User '$SAN' already exists in this group" -ForegroundColor Cyan
            }
            # kollar om en fil finns redan, annars skapa en fil annars
            if(![System.IO.File]::Exists("C:\SHARES\IT\useraccount\$SAN.txt"))
            {
                # en simpel avcheckning om en fil redan finns
               New-Item -Path "C:\SHARES\IT\useraccount\$SAN.txt" -Value "Username: $SAN  Password: $password"
            }
            else
            {
                Write-Host "User '$SAN' already have a loginpaper" -ForegroundColor Cyan
            }
        }
        catch
        {
            Write-Warning "$namn already exists"
        }
}
        
    
Write-Host "Done" -ForegroundColor Green -NoNewline
