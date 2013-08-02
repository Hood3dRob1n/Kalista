# This is our Recon & Discovery Class, inherits all from CoreShell to make all support stuff available
# This should house anything related to Recon & Discovery operations 
# target/host information gathering wrappers and such
# If you add, just update the usage and r_shell function to make available

class Recon
	def show_recon_usage
		puts "List of available commands and general description".light_yellow + ": ".white
		puts "\tcls".light_yellow + "         => ".white + "Clear Screen".light_yellow
		puts "\thelp ".light_yellow + "       => ".white + "Display this Help Menu".light_yellow
		puts "\tback ".light_yellow + "       => ".white + "Return to Main Menu".light_yellow
		puts "\texit ".light_yellow + "       => ".white + "Exit Completely".light_yellow
		print_line("")
		puts "\tarp".light_yellow + "         => ".white + "ARP Discovery Scan using MSF".light_yellow
		puts "\tnetdiscover".light_yellow + " => ".white + "ARP Discovery Scan using Netdiscover".light_yellow
		puts "\tdnsrecon".light_yellow + "    => ".white + "DNS Enumeration using DNSRECON".light_yellow
		puts "\tsubrecon".light_yellow + "    => ".white + "Sub-Domain Enumeration using DNSRECON".light_yellow
		puts "\tsubmap".light_yellow + "      => ".white + "Sub-Domain Enumeration using DNSMAP".light_yellow
		puts "\tnbtscan".light_yellow + "     => ".white + "NBTSCAN NetBios Scan".light_yellow
		puts "\tnmap".light_yellow + "        => ".white + "NMAP Scan".light_yellow
		puts "\tmssql_ping".light_yellow + "  => ".white + "MS-SQL Ping Utility".light_yellow
		puts "\twinrm".light_yellow + "       => ".white + "WinRM Authentication Method Detection".light_yellow
		print_line("")
	end

	#Recon & Discovery Main Menu
	def r_shell
		prompt = "(Recon)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^clear|^cls|^banner/i
					cls
					banner
					r_shell
				when /^help|^h$|^ls$/i
					show_recon_usage
					r_shell
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
				when /^arp/i
					print_line("")
					arp_msf
					r_shell
				when /^netdiscover/i
					print_line("")
					arp_netdiscover
					r_shell
				when /^dnsrecon/i
					print_line("")
					dnsrecon_wrapper
					r_shell
				when /^subrecon/i
					print_line("")
					dnsrecon_sub_wrapper
					r_shell
				when /^submap/i
					print_line("")
					dnsmap_wrapper
					r_shell
				when /^nbtscan|^nbt$|^netbios/i
					print_line("")
					nbtscan_wrapper
					r_shell
				when /^nmap/i
					print_line("")
					nmap_builder
					r_shell
				when /^mssql_ping|^msping|^ms_ping|^sql_ping/i
					print_line("")
					mssql_ping
					r_shell
				when /^winrm/i
					print_line("")
					winrm_auth_check
					r_shell
				else
					cls
					print_line("")
					print_error("Oops, Didn't quite understand that one")
					print_error("Please Choose a Valid Option From Menu Below Next Time.....")
					print_line("")
					show_recon_usage
					r_shell
				end
		end
	end

	# ARP Scanning with Metasploit
	def arp_msf
		print_status("MSF ARP Discovery Scan Builder")
		print_caution("Target IP: ")
		zIP=gets.chomp

		print_caution("Source IP to use in requests: ")
		sIP=gets.chomp

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts 'use auxiliary/scanner/discovery/arp_sweep'
		f.puts "set RHOSTS #{zIP}"
		f.puts "set SHOST #{sIP}"
		f.puts 'set SMAC 00:11:22:AA:BB:CC'
		f.puts "set THREADS 10"
		f.puts 'run'
		f.close

		arp="xterm -title 'MSF ARP Scan #{zIP}' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		print_status("Launching MSF based ARP Scan in new window, hang tight.....")
		fireNforget(arp)
		print_line("")
	end

	# ARP Scanning with NetDiscover
	def arp_netdiscover
		print_status("Netdiscover ARP Scan Builder")
		netd = `which netdiscover`.chomp
		count = 1
		i = `/sbin/ifconfig -a | cut -d' ' -f1 | sed '/^$/d'`.split("\n")

		print_caution("Interface to Use: ")
		i.each do |x|
			print_status("#{count}) #{x}")
			count = count.to_i + 1
		end
		answ=gets.chomp
		zINTERFACE=i[answ.to_i - 1]

		scan="#{netd} -i #{zINTERFACE}"
		print_caution("Do you want to run an active Scan (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == "YES"
			print_caution("Target IP: ")
			zIP=gets.chomp
			scan += " -r #{zIP}"
		end

		scan += "' && echo && echo '-- Press ENTER to close window --' && read"
		print_status("Launching Netdiscover based ARP Scan in new window, hang tight.....")
		netdscan="xterm -title 'Netdiscover #{zIP}' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{scan}\""
		fireNforget(netdscan)
		print_line("")
	end

	#Simple DNSRECON Wrapper for basic DNS Enumeration. Output in XML & CSV so you can import to other tools (MSF=>XML)
	#If using outside of Kali, need to make sure gems are installed: gem install pNet-DNS && gem install ip
	def dnsrecon_wrapper
		print_status("DNSRECON Scan Builder")
		dns='dnsrecon '
		print_caution("Target Domain: ")
		zDOMAIN=gets.chomp
		dns += "-d #{zDOMAIN}"

		print_caution("Use custom Domain Server (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Domain Server to use: ")
			zDomServer=gets.chomp
			dns += " -n #{zDomServer}"
		end
		dns += " -a -w -z --threads 10 --lifetime 120 "

		print_caution("Output File Name: ")
		zOut=gets.chomp
		Dir.mkdir("#{$results}dnsrecon/") unless File.exists?("#{$results}dnsrecon/")
		dns += "--xml #{$results}dnsrecon/#{zOut}.xml --csv #{$results}dnsrecon/#{zOut}.csv"

		dns += "' && echo && echo '-- Press ENTER to close window --' && read"
		print_status("Launching DNSRECON Enumeration Scan in new window, hang tight.....")
		netdscan="xterm -title 'DNSRECON #{zDOMAIN}' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{dns}\""
		fireNforget(netdscan)
		print_line("")
	end

	#Bruteforcing of Sub-Domains using DNSRECON -D nameslist.txt
	def dnsrecon_sub_wrapper
		print_status("DNSRECON Sub-Domain Bruteforcer")
		dns='dnsrecon '
		print_caution("Target Domain: ")
		zDOMAIN=gets.chomp
		dns += "-d #{zDOMAIN} -t brt"

		print_caution("Use custom wordlist for sub-domains (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Path to Wordlist: ")
			zWordlist=gets.chomp
			if File.exists?(zWordlist)
				dns += " -D #{zWordlist}"
			else
				print_error("Can't find provided file!")
				print_caution("Proceeding with default: #{DNSRECON}namelist.txt")
				print_status("....")
				dns += " -D #{DNSRECON}namelist.txt"
			end
		else
			dns += " -D #{DNSRECON}namelist.txt"
		end

		print_caution("Output File Name: ")
		zOut=gets.chomp
		Dir.mkdir("#{$results}dnsrecon/") unless File.exists?("#{$results}dnsrecon/")
		dns += " --threads 10 --lifetime 120 --xml #{$results}dnsrecon/#{zOut}.xml --csv #{$results}dnsrecon/#{zOut}.csv"

		dns += "' && echo && echo '-- Press ENTER to close window --' && read"
		print_status("Launching DNSRECON Sub-Domain Bruteforcer in new window, hang tight.....")
		subscan="xterm -title 'DNSRECON Sub-Domain Bruteforcer' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{dns}\""
		fireNforget(subscan)
		print_line("")
	end

	#Bruteforcing of Sub-Domains using DNSMAP and a user-provided wordlist
	def dnsmap_wrapper
		print_status("DNSMAP Sub-Domain Bruteforcer")
		print_caution("Target Domain: ")
		zDOMAIN=gets.chomp
		subs = "dnsmap #{zDOMAIN}"

		print_caution("Use custom wordlist for sub-domains (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Path to Wordlist: ")
			zWordlist=gets.chomp
			if File.exists?(zWordlist)
				subs += " -w #{zWordlist}"
			else
				print_error("Can't find provided file!")
				print_caution("Proceeding with default: #{DNSRECON}namelist.txt")
				print_status("....")
				subs += " -w #{DNSMAP}wordlist_TLAs.txt"
			end
		end

		print_caution("If Logging is Enabled, NO output will be printed to terminal while running!")
		print_caution("Enable Logging of Output (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Output File Name: ")
			zOut=gets.chomp
			Dir.mkdir("#{$results}dnsmap/") unless File.exists?("#{$results}dnsmap/")
			subs += " -r #{$results}dnsmap/#{zDOMAIN}.txt"
		else
			print_status("OK, leaving logging disabled.....")
		end
		subs += "' && echo && echo '-- Press ENTER to close window --' && read"
		print_status("Launching DNSMAP Sub-Domain Bruteforcer in new window, hang tight.....")
		submap="xterm -title 'DNSMAP Sub-Domain Bruteforcer' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{subs}\""
		fireNforget(submap)
		print_line("")
	end

	#NBTSCAN Wrapper
	def nbtscan_wrapper
		print_status("NBTSCAN NetBios Scan Builder")
		while(true)
			print_caution("Select Targeting Method: ")
			print_caution("1) Single IP/Range")
			print_caution("2) List with Targets")
			answer=gets.chomp
			print_line("")
			if answer == '1'
				print_caution("Please Provide Target IP: ")
				t=gets.chomp
				zIP=t
				print_line("")
				break
			elsif answer == '2'
				print_caution("Please Provide Path to Target List: ")
				dfile=gets.chomp
				print_line("")
				if File.exists?(dfile)
					zIP="-f #{dfile}"
					print_line("")
					break
				else
					print_error("Can't seem to find provided target list!")
					print_error("Check the permissions or the path and try again.....")
					print_line("")
				end
			end
		end
		print_status("Launching NBTSCAN in new window, hang tight.....")
		nbt = "nbtscan #{zIP}' && echo && echo '-- Press ENTER to close window --' && read"
		nbtscan="xterm -title 'NBTSCAN #{zIP}' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{nbt}\""
		fireNforget(nbtscan)
		print_line("")
	end

	#NMAP Scan Builder
	def nmap_builder
		print_status("NMAP Scan Builder")
		print_caution("Please provide target IP or Host to Scan: ")
		target = gets.chomp
		scan="xterm -title 'NMAP Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c 'nmap -sS -A -T3 -PN "
		print_caution("Enable NSE Scripts (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'YES' or answer.upcase == 'Y'
			scan += '-sC '
		end
		Dir.mkdir("#{$results}nmap/") unless File.exists?("#{$results}nmap/")
		scan += "#{target} -oX #{$results}nmap/#{target}.xml' && echo && echo '-- Press ENTER to close window --' && read\""
		print_status("Launching NMAP Scan in new xterm window, hope you find something interesting....")
		fireNforget(scan)
		print_line("")
	end

	# MS-SQL Pint Utility - It helps find MS-SQL Servers and the ports they are listening on (Standard Port is 1433)
	# Very helpful as MS-SQL can be the way in
	def mssql_ping
		print_status("")
		print_status("MS-SQL Ping Utility")
		print_status("It finds MS-SQL Servers & listening port!")
		print_status("")
		print_caution("Provide Target IP or IP Range: ")
		zIP=gets.chomp

		print_caution("Thread Count (1,5,25..): ")
		zTHREADS=gets.chomp

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts 'use auxiliary/scanner/mssql/mssql_ping'
		f.puts "set RHOSTS #{zIP}"
		f.puts "set THREADS #{zTHREADS}"

		print_caution("Username & Password are optional")
		print_caution("Do you want to use Credentials (Y/N)?")
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Provide Username: ")
			zUSER=gets.chomp

			print_caution("Provide Password: ") 
			zPASS=gets.chomp
			f.puts "set USERNAME #{zUSER}"
			f.puts "set PASSWORD #{zPASS}"
		end
		f.puts "run"
		f.close
		msping="xterm -title 'MS-SQL Ping' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		print_status("Launching MSF MS-SQL Ping Utility in new window, hang tight.....")
		fireNforget(msping)
		print_line("")
	end

	# MSF WinRM Authentication Method Detection
	# This module sends a request to an HTTP/HTTPS service to see if it is a WinRM service. 
	# If it is a WinRM service, it also gathers the Authentication Methods supported.
	def winrm_auth_check
		print_status("")
		print_status("WinRM Authentication Method Detection")
		print_status("")
		print_caution("Target IP or IP Range: ")
		zIP=gets.chomp

		print_caution("Set Domain (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			print_caution("Domain to use: ")
			zDOMAIN=gets.chomp
		else
			zDOMAIN='WORKSTATION'
		end

		print_caution("Use Standard Port of 5985 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Port to use: ")
			zPORT=gets.chomp
		else
			zPORT=5985
		end

		print_caution("Use standard URI /wsman (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("URI to use: ")
			zURI=gets.chomp
		else
			zURI='/wsman'
		end

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/scanner/winrm/winrm_auth_methods"
		f.puts "set DOMAIN #{zDOMAIN}"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"
		f.puts "set URI #{zURI}"
		f.puts "run"
		f.close

		print_status("Launching WinRM Auth Detection Scan in new window, hang tight.....")
		winrm="xterm -title 'WinRM Auth Scan' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(winrm)
		print_line("")
	end
end
