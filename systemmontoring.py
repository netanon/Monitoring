################## METADATA ##################
# NAME: Daniel Johansson
# USERNAME: b18danjo
# COURSE: Scriptprogramming IT384G - Spring 2019
# ASSIGNMENT: Assignment 1 - Python
# DATE OF LAST CHANGE: 2019-05-02T07:22:14+02:00 
##############################################
from systemd import journal
import datetime
import socket
import time

def recentlogmessages(service, priorty=journal.LOG_WARNING):
    j = journal.Reader()
    j.this_boot()
    data = []
    try:
        j.log_level(priorty)
    except:
        j.log_level(6)
    #
    j.seek_realtime(time.time()-24*60*60+30*60)
    j.add_match(_SYSTEMD_UNIT=service)
    try:
        for entry in j:
            if entry['MESSAGE'] is None:
                break
            data.append(entry['MESSAGE'])
        return data          
    except TypeError:
        return print("none")
    
    
def probetcpport(address, portnumber):
    try:
        socket.create_connection((address, portnumber))
        return True
    except OSError:
        pass
    return False

#print(probetcpport(test, test2))
    
