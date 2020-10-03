################## METADATA ##################
# NAME: Daniel Johansson
# USERNAME: b18danjo
# COURSE: Scriptprogramming IT384G - Spring 2019
# ASSIGNMENT: Assignment 1 - Python, montoring
# DATE OF LAST CHANGE: 2019-04-05T09:39:45+02:00
##############################################
import systemd.login
import pwd
import subprocess

# returnar en lista på en dictionary 
def listuser():
    D = {}
    userdata = []
    
    def sortbyUID(e):
        return e['UID']
    
    for pw in pwd.getpwall():
        num = 0
        # Matar in allt i dictionary som kopiars in till en lista
        D["UID"] = pw.pw_uid
        D["User"] = pw.pw_name
        D["Shell"] = pw.pw_shell
        logins = systemd.login.uids()
        # om någpn användare är inloggade ska den lägga till den information i ordboken D
        if logins[num] == pw.pw_uid:
            D["Loggedin"] = True
        else:
            D["Loggedin"] = False
        # lägger till ordboken in i listan
        userdata.append(D.copy())
        userdata.sort(key=sortbyUID)
        num += 1

    return userdata
# returnera disk användning baserad på uid som matas in
def diskusageHome(uid):  
    pw = pwd.getpwuid(uid)
    path = pw.pw_dir
    return subprocess.check_output(['sudo','du','-sh', path]).split()[0].decode('utf-8')
    

