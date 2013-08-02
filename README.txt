  _|_|                                  _|          _|  _|                     
_|    _|  _|_|_|      _|_|    _|_|_|    _|          _|      _|  _|_|    _|_|   
_|    _|  _|    _|  _|_|_|_|  _|    _|  _|    _|    _|  _|  _|_|      _|_|_|_| 
_|    _|  _|    _|  _|        _|    _|    _|  _|  _|    _|  _|        _|       
  _|_|    _|_|_|      _|_|_|  _|    _|      _|  _|      _|  _|          _|_|_| 
         _|                                                                    
         _|                                                                    
                                      OpenWire Project Kalista, v0.1-aplha  

Project Kalista Readme:

This is something I made for myself and decided to share as others kind of liked it. It's a lot of wrappers for common tasks done during auditing and pentesting. It has a main menu which you can navigate to any of the sub-menu's or in most cases you can run the arguments needed at run time to launch directly into the needed sub-menu of choice. It was originally designed to be used on the newer Kali Linux distro but I am slowly working on tweaking it here and there to try and make it work on other distros if you have the underlying dependencies and tools required to run. The installer.rb file is still in the works but is my first shot at helping somone get setup to use on another distro, no guarantees for the moment. Poke around, have fun & enjoy!
   
Usage:./kalista [OPTIONS]

Options: 
    -m, --main                       
	Main Menu
    -r, --recon                      
	Recon & Discovery Menu
    -b, --brute                      
	Logins & Bruteforce Menu
    -p, --payloads                   
	Payload Builder Menu
    -l, --listener                   
	Listner Builder Menu
    -x, --exploit                    
	Exploits Menu
    -w, --wifi                       
	WiFi Menu
    -M, --mitm                       
	MiTM Menu
    -u, --update                     
	Updates Menu
    -s, --smbfun                     
	SMB Tools Menu
    -h, --help                       
	Display Help Menu

MAIN MENU:
This allows you to navigate to any of the sub-menus as well as ability to run a few options which are not accessible elsewhere. It is setup to act like a typical command shell to keep you comfy. You can type HELP to see the list of options available, CLS or CLEAR to clear terminal, and EXIT to exit the framework completely - these all work thoughout the framework and sub-menus. From the Main Menu you can easily jump to the sub-menus which are all named by their respective categories. As you change menus within the framework you will notice the command prompt will change accordingly to keep you informed of where you are so you dont get lost. As options are enabled and tasks run the tasks are mostly run in separate x-term windows while keeping everything easy to track. Windows are titled and for all MSF wrappers the results are stored in the MSF database in addition to whatever is stored in the local Kalista results directory. 

(Kalista)> help
List of commands and description of usage: 
	clear     => Clear Screen
	exit      => Exit Completely
	help      => Display this Help Menu

	recon     => Recon & Discovery Shell
	login     => Logins & Bruteforcers Shell
	payload   => Payloads Builder Shell
	listener  => Listener & Connection Handler Setup
	snmp      => Windows SNMP Enumation Tools
	smb       => SMB Tools
	exploit   => Exploits Shell
	wifi      => WiFi Shell
	mitm      => MiTM Shell
	update    => Updater

	local     => Local OS Shell
	rb <code> => Evaluates Ruby Code

RB:
There is a built in option to evaluate raw ruby code. This allows you to do what you want on the fly as needed. If you know the framework you can also leverage any of the existing built-ins from here. Please refrain from using global variables as this is largely what the framework relies on and it may cause some issues if you do...

LOCAL:
This simple drops to a pseudo shell where you can execute local OS commands without having to exit the framework completely. You should be able to do most activities you would normally perform from the command line. I have not experienced any issues yet, but can't promise the world as I'm sure there is something I just haven't come across yet. If you break it you buy it, jk - please send me a note so I can try to fix!

RECON:
Recon as is it is named takes you to some options for performing common recon tasks. There are a few options for performing discovery via ARP scans, there are a few options for DNS enumeration as well as a few other discovery scanners which use various port scans to perform their particular function (MS-SQL, WinRM, NetBios, NMAP, etc). Below is a listing from the help menu to give you an idea, most options will be menu driven after selected and will run once the setup questions are finished (target, ip/range, etc).

(Recon)> help
List of available commands and general description: 
	arp         => ARP Discovery Scan using MSF
	netdiscover => ARP Discovery Scan using Netdiscover
	dnsrecon    => DNS Enumeration using DNSRECON
	subrecon    => Sub-Domain Enumeration using DNSRECON
	submap      => Sub-Domain Enumeration using DNSMAP
	nbtscan     => NBTSCAN NetBios Scan
	nmap        => NMAP Scan
	mssql_ping  => MS-SQL Ping Utility
	winrm       => WinRM Authentication Method Detection

LOGIN:
This is a menu for attacking various service logins. At the moment these all leverage MSF Auxiliary modules, some variance in the future is expected (i.e. Hydra + Ncrack alternatives). Once your option is selected you will be taken through wizard to setup attack configuration, once done it is launched in a new window with results stored in MSF database. 

(Logins)> help
List of available commands and general description: 
	ssh         => SSH Login Scanner
	ftp_login   => FTP Login Scanner
	ftp_anon    => Anonymous FTP Login Scanner
	mssql_login => MS-SQL Login Scanner
	pgsql_login => PostgreSQL Login Scanner
	mysql_login => MySQL Login Scanner
	mysql_auth  => MySQL Authentication Bypass Password Dumper
	telnet      => Telnet Login Scanner
	winrm       => WinRM Login Scanner

PAYLOAD:
This is the menu for the payload builder menu. From here you can configure and build all sorts of payloads leveraging MSF under the hood in most cases. You can find options for building payloads for Linux, Windows, Web Applications, PDFs and all with various formats or options available to you. As with the other menus once an option is selected the wizard will guide you through questions to get things setup and then point you at the final payload which should be stored somewhere in the results directory. 

NOTE: This uses basic MSF encoding when encoding so don't expect 100% FUD paylaods bypassing all sorts of AV but it gets job done in plenty of cases. CUSTOM::EXE Support coming soon in future editions where applicable. Shellcode generator also planned for future editions...

(Payloads)> help
List of available commands and general description: 
	elf         => Linux ELF Executable
	deb         => Linux DEB Installer Package, using: Tint (This is Not Tetris)
	web         => ASP, JSP & PHP Web Payloads
	exe         => Windows EXE Executable
	pdf         => Windows PDF Embedded Payload
	war         => WAR (Web-Archive) Payloads
	downloader  => Windows Download & Execute Payload
	vbs_down    => Windows VBScript Downloader, NO Execution
	powershell  => Windows PowerShell Payloads

LISTENER:
This will take you into a wizard driven guide to setup a local listener or to connect to bind shell you already have waiting. It uses the MSF multi-handler for most of the payload handlings but also has wrappers for NCAT and NetCat when you select the generic payload option. Fairly straight forward business here...

SNMP:
This is custom SNMP tool I wrote to perform some recon and enumeration against Windows systems. It is designed to be able to go after other systems and devices as well but you will have to figure out or enumerate the needed MiB for calls. Currently it is targeted at Windows and is capable of running login attack against community string. Once valid READ string is found against Windows box it can enumerate System Info (Uptime, System Name, etc), Valid User Account Usernames, Running Processes, Running Services, and Open Ports TCP/UDP. You can play around with what you can do if you have WRITE string access. I plan to add to this as time goes on and I learn and find more helpful references on SNMP. I would eventually like to have some Cisco and other more common devices added with a few built-in options...

(SNMP)> help
List of available commands and general description: 
	nmap        => Quick NMAP SNMP Scan Builder
	bruteforce  => Dictionary Attack SNMP Community String
	creds       => Initialize SNMP Connection Variables (for ease of use)
	basic       => Enumerate Basic Info
	dump        => Dump 'MGMT' Tree
	users       => Enumerate Windows Usernames
	netstat     => Enumerate Windows Currently Open TCP & UDP Ports
	process     => Enumerate Windows Running Processes
	services    => Enumerate Windows Running Services
	software    => Enumerate Windows Installed Software

	o2n <OID>   => Convert OID to Symbolic Name
	n2o <Name>  => Convert Symbolic Name to OID
	walk <OID>  => Walk Tree by OID or Symbolic Name
	set <OID> <String>  => Set Value for Specified OID to given String

SMB:
This is my favorite sub-menu and the one I use the most. It contains several helpful wrappers for performing SMB Recon and Attacks. This includes version scanning, password auditing, domain user enumeration and several options for payload delivery given valid credentials. The noshell_hell option is my own custom MSF module. It is included with Kalista in the extras directory but Kalista will copy into MSF directory if it doesnt find it. This leverages the smb_exec method to run a bunch of enumeration and attack commands without uploading binaries to target. MPX is another one i made and is mainly just a wrapper for the MSF standalone psexec tool to extend its value by allowing it to accept larger ranges and lists of passwords or password hashes. Keimpx is another tool which uses the impacket library for Core guys which is really awesome tool which can come in handy in lots of various occassions. Encourage you to poke around and find what works for you, let me know what doesnt :)

(SMBFun)> help
List of available commands and general description: 
	smb_version  => SMB Version Scanner
	smb_login    => SMB Login Scanner
	smb_pipe     => SMB Pipe Auditor
	smb_dcerpc   => SMB DCERPC Pipe Auditor
	smb_shares   => SMB Shares Enumerator
	smb_domains  => SMB Domain Users Enumerator
	smb_exec     => MSF PSEXEC_COMMAND (No Shell CMD Exec)
	noshell_hell => MSF PSEXEC_COMMAND (No Shell Hell)
	psexec       => MSF PSEXEC Payload Delivery
	keimpx       => KEIMPX SMB Tool
	mpx          => Multi-Scan PSEXEC Upload & Execute Wrapper


EXPLOIT:
This is the exploits menu and containts quick setups for some more common exploits I tend to come across. Contains several credential capturing options and several exploit options for both Windows and Linux. Don't forget about the SMB Section as some exploit options are only there but menu space was becoming an issue so they were broken off to their own category...

(Exploits)> help
List of available commands and general description: 
	smb_cap      => Windows SMB Authentication Capture
	nbns_spoof   => NetBIOS Name Service Spoofer (nbns_spoofer)
	http_ntlm    => Windows HTTP Client Credential Capture (http_ntlm)
	smb_relay    => Windows SMB Relay Exploit

	winrm        => WinRM Credentialed Payload Execution
	netapi       => Exploit Windows ms08_067 netapi
	trans2open   => Exploit Samba trans2open (*nix: Samba versions 2.2.0 to 2.2.8)
	usermap      => Exploit Samba 'username map script' (*nix: Samba versions 3.0.20 through 3.0.25rc3)

	mssql_rce    => MS-SQL Server Payload Execution (Credentials)
	mssqli_rce   => MS-SQL Server Payload Execution (via SQLi)
	mssql_ntlm   => MS-SQL Server NTLM Stealer
	mssqli_ntlm  => MS-SQL Server NTLM Stealer via SQLi
	mysql_udf    => Windows Oracle MySQL UDF Payload Execution
	mysql_mof    => Windows Oracle MySQL MOF Payload Execution
	pgsql_win    => Windows PostgreSQL Payload Execution (Credentials)
	pgsql_nix    => Linux PostgreSQL Payload Execution (Credentials)

MITM:
This is reserved for Man-In-The-Middle Attacks and Setup. I haven't coded this section yet but plan to soon. It wont be anything overly complicated, just some wrappers for basic setups and common attacks.

WiFi:
This is reserved for WiFi Scanning and Attacks. This section is still in the works, coming soon....

UPDATE:
This is a sub-menu for updating common tools. Currently it is only setup for MSF but will likely add to it with time, although since it was originally targeted as Kali it doesn't need a whole lot :)

QUESTIONS, SUGGESTIONS, OR FEEDBACK: 
Please feel free to message me with your questions, suggestions or feedback: hood3drob1n [ at ] gmail [ dot ] com
I am not great at using Github so message me and I will likely get back to you and fix the issue sooner this way.....

Hope you enjoy the new stuff!

Laters,
H.R.

