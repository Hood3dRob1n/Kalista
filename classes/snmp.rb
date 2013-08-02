# This is our SNMPWinStalker Class
# This should house anything related to SNMP Reconn & Attacks
# Mostly a Windows focus, but not limited to....
# If you add, just update the usage and snmp_shell function to make available

class SNMPShell
	def show_snmp_usage
		puts "List of available commands and general description".light_yellow + ": ".white
		puts "\tcls".light_yellow + "         => ".white + "Clear Screen".light_yellow
		puts "\thelp ".light_yellow + "       => ".white + "Display this Help Menu".light_yellow
		puts "\tback ".light_yellow + "       => ".white + "Return to Main Menu".light_yellow
		puts "\texit ".light_yellow + "       => ".white + "Exit Completely".light_yellow
		print_line("")
		puts "\tnmap ".light_yellow + "       => ".white + "Quick NMAP SNMP Scan Builder".light_yellow
		puts "\tbruteforce ".light_yellow + " => ".white + "Dictionary Attack SNMP Community String".light_yellow
		puts "\tcreds ".light_yellow + "      => ".white + "Initialize SNMP Connection Variables (for ease of use)".light_yellow
		puts "\tbasic ".light_yellow + "      => ".white + "Enumerate Basic Info".light_yellow
		puts "\tdump ".light_yellow + "       => ".white + "Dump 'MGMT' Tree".light_yellow
		puts "\tusers ".light_yellow + "      => ".white + "Enumerate Windows Usernames".light_yellow
		puts "\tnetstat ".light_yellow + "    => ".white + "Enumerate Windows Currently Open TCP & UDP Ports".light_yellow
		puts "\tprocess ".light_yellow + "    => ".white + "Enumerate Windows Running Processes".light_yellow
		puts "\tservices ".light_yellow + "   => ".white + "Enumerate Windows Running Services".light_yellow
		puts "\tsoftware ".light_yellow + "   => ".white + "Enumerate Windows Installed Software".light_yellow
		print_line("")
		puts "\to2n <OID> ".light_yellow + "  => ".white + "Convert OID to Symbolic Name".light_yellow
		puts "\tn2o <Name> ".light_yellow + " => ".white + "Convert Symbolic Name to OID".light_yellow
		puts "\twalk <OID> ".light_yellow + " => ".white + "Walk Tree by OID or Symbolic Name".light_yellow
		puts "\tset <OID> <String> ".light_yellow + " => ".white + "Set Value for Specified OID to given String".light_yellow
		print_line("")
	end

	def snmp_shell
		prompt = "(SNMP)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^clear|^cls|^banner/i
					cls
					banner
					snmp_shell
				when /^help|^h$|^ls$/i
					show_snmp_usage
					snmp_shell
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
				when /^nmap|^snmp_nmap/i
					print_line("")
					nmap_snmp
					snmp_shell
				when /^bruteforce|^snmp_brute|^bruter/i
					print_line("")
					snmp_brute
					snmp_shell
				when /^creds|^credz|^credential/i
					print_line("")
					snmp_creds
					snmp_shell
				when /^o2n (.+)/i
					print_line("")
					oid=$1
					o2n(oid)
					print_line("")
					snmp_shell
				when /^n2o (.+)/i
					print_line("")
					name=$1
					n2o(name)
					print_line("")
					snmp_shell
				when /^walk (.+)|^snmp_walk (.+)/i
					print_line("")
					oidname=$1
					snmap_walk(oidname)
					print_line("")
					snmp_shell
				when /^set (.+) (.+)|^snmp_set (.+) (.+)/i
					print_line("")
					oid=$1
					string=$2
					snmap_set(oid, string)
					snmp_shell
				when /^basic|^info/i
					print_line("")
					snmp_basic
					print_line("")
					snmp_shell
				when /^dump/i
					print_line("")
					snmp_dump
					print_line("")
					snmp_shell
				when /^users|^usernames/i
					print_line("")
					snmp_users
					print_line("")
					snmp_shell
				when /^software|^sw$/i
					print_line("")
					snmp_software
					print_line("")
					snmp_shell
				when /^services/i
					print_line("")
					snmp_services
					print_line("")
					snmp_shell
				when /^process|^ps$/i
					print_line("")
					snmp_processes
					print_line("")
					snmp_shell
				when /^netstat/i
					print_line("")
					snmp_netstat
					print_line("")
					snmp_shell
				else
					cls
					print_line("")
					print_error("Oops, Didn't quite understand that one")
					print_error("Please Choose a Valid Option From Menu Below Next Time.....")
					print_line("")
					show_snmp_usage
					snmp_shell
				end
		end
	end

	#Convert OID 2 Symbolic Name
	def o2n(oid)
		if not @snmp_target
			print_caution("Target IP: ")
			snmp_target = gets.chomp
			print_caution("Use Standard SNMP Port of 161 (Y/N)?")
			answer=gets.chomp
			if answer.upcase == 'N' or answer.upcase == 'NO'
				print_caution("SNMP Port: ")
				snmp_port=gets.chomp
			else
				snmp_port='161'
			end
			print_caution("Community String: ")
			snmp_cstring = gets.chomp
			base = SNMPStalker.new(snmp_target,snmp_port.to_i,snmp_cstring)
		else
			base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		end
		base.can_we_connect
		if $fail == 0
			base.oid2name(oid)
			base.close
		else
			$fail=0
		end
	end

	#Convert Symbolic Name to OID
	def n2o(name)
		if not @snmp_target
			print_caution("Target IP: ")
			snmp_target = gets.chomp
			print_caution("Use Standard SNMP Port of 161 (Y/N)?")
			answer=gets.chomp
			if answer.upcase == 'N' or answer.upcase == 'NO'
				print_caution("SNMP Port: ")
				snmp_port=gets.chomp
			else
				snmp_port='161'
			end
			print_caution("Community String: ")
			snmp_cstring = gets.chomp
			base = SNMPStalker.new(snmp_target,snmp_port.to_i,snmp_cstring)
		else
			base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		end
		base.can_we_connect
		if $fail == 0
			base.name2oid(name)
			base.close
		else
			$fail=0
		end
	end

	# SET value for specified OID with given string
	def snmap_set(oid, string)
		if not @snmp_target
			print_caution("Target IP: ")
			snmp_target = gets.chomp
			print_caution("Use Standard SNMP Port of 161 (Y/N)?")
			answer=gets.chomp
			if answer.upcase == 'N' or answer.upcase == 'NO'
				print_caution("SNMP Port: ")
				snmp_port=gets.chomp
			else
				snmp_port='161'
			end
			print_caution("Community String: ")
			snmp_cstring = gets.chomp
			base = SNMPStalker.new(snmp_target,snmp_port.to_i,snmp_cstring)
		else
			base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		end
		base.can_we_connect
		if $fail == 0
			base.set(oid, string)
			base.close
		else
			$fail=0
		end
	end

	# Walk the target OID or OID Symbolic Name tree if available....
	def snmap_walk(oidname)
		if not @snmp_target
			print_caution("Target IP: ")
			snmp_target = gets.chomp
			print_caution("Use Standard SNMP Port of 161 (Y/N)?")
			answer=gets.chomp
			if answer.upcase == 'N' or answer.upcase == 'NO'
				print_caution("SNMP Port: ")
				snmp_port=gets.chomp
			else
				snmp_port='161'
			end
			print_caution("Community String: ")
			snmp_cstring = gets.chomp
			base = SNMPStalker.new(snmp_target,snmp_port.to_i,snmp_cstring)
		else
			base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		end
		base.can_we_connect
		if $fail == 0
			base.walk(oidname)
			base.close
		else
			$fail=0
		end
	end

	# A Pseudo initialize function to set some credentials
	# This will allow re-use to save time while staying in this class module
	def snmp_creds
		print_status("SNMP Connection Datastore")
		print_caution("Target IP: ")
		@snmp_target = gets.chomp
		print_caution("Use Standard SNMP Port of 161 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("SNMP Port: ")
			@snmp_port=gets.chomp
		else
			@snmp_port='161'
		end
		print_caution("Community String: ")
		@snmp_cstring = gets.chomp
		$fail=0
		print_status("SNMP Connection Datastore Complete!")
		print_good("Target: #{@snmp_target}")
		print_good("Port: #{@snmp_port}")
		print_good("Community String: #{@snmp_cstring}")
		base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		base.can_we_connect
		if $fail == 0
			base.close
		else
			$fail=0
			print_error("")
			print_error("The provided details don't seem to be working!")
			print_error("")
		end
		print_caution("Re-run to change and re-set the SNMP connection datastore....")
		print_line("")
	end

	#NMAP SNMP Quick Scan Builder
	def nmap_snmp
		print_status("NMAP SNMP Quick Scan Builder")
		print_caution("Target IP: ")
		target = gets.chomp
		scan="xterm -title 'NMAP SNMP Quick Scan' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c 'nmap -sU -p 161 -sV "
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

	# Dictionary attack to find Community String
	# say something gay about using the word bruteforce and you will instantly be banished!
	# use your brain power, google and small lists with targeted strings
	# Bad Connections and faulty credentials end up causing time-out error
	# Simple use this to judge, moving on to next string in list if failed....not overly complex, sorry
	def snmp_brute
		print_status("SNMP Community String Bruteforcer")
		print_caution("Target IP: ")
		target = gets.chomp
		print_caution("Use Standard SNMP Port of 161 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Provide SNMP Port: ")
			zPORT=gets.chomp
		else
			zPORT='161'
		end

		print_caution("Select Wordlist for Attack: ")
		print_caution("1) Built-in Wordlist")
		print_caution("2) Custom Wordlist")
		answer=gets.chomp
		if answer == '2'
			print_caution("Path to Wordlist: ")
			zlist=gets.chomp
			if File.exists?(zlist)
				zWordlist = File.open(zlist).readlines
				print_good("Loaded #{zWordlist.size} strings from wordlist.....")
			else
				print_error("Can't find provided file!")
				print_caution("Proceeding with default built-in wordlist.....")
				zWordlist = [ 'public', 'public123', 'private', 'private123', 'internal', 'internet', 'secret', 'write', 'read', 'MyPublicCommunityName', 'MyPrivateCommunityName', 'snmp', 'snmpd', 'all private' ]
			end
		else
			zWordlist = [ 'public', 'public123', 'private', 'private123', 'internal', 'internet', 'secret', 'write', 'read', 'MyPublicCommunityName', 'MyPrivateCommunityName' ]
			print_good("Loaded #{zWordlist.size} strings from default wordlist.....")
		end

		print_caution("Stop on Firt Success (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			stop=true
		else
			stop=false
		end

		$fail=0
		while(true)
			print_status("Starting SNMP Bruteforce Attack, hang tight....")
			zWordlist.each do |cs|
				base = SNMPStalker.new(target,zPORT.to_i,cs.chomp)
				base.can_we_connect
				if $fail == 0
					base.close if base
					print_good("Connection Success!")
					print_good("Success using '#{cs.chomp}'")
					if stop == true
						print_status("Stop on Success Selected!")
						break
					end
				else
					$fail=0
				end
			end
			break
		end
		print_line("")
	end

	# Enumerate some basic info
	def snmp_basic
		if not @snmp_target
			snmp_creds
		end
		base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		base.can_we_connect
		if $fail == 0
			base.basic_info
			base.close
		else
			$fail=0
		end
	end

	# Enumerate Valid Windows User Accounts
	def snmp_users
		if not @snmp_target
			snmp_creds
		end
		base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		base.can_we_connect
		if $fail == 0
			base.users_walk
			base.close
		else
			$fail=0
		end
	end

	# Enumerate Installed Software on Windows box
	def snmp_software
		if not @snmp_target
			snmp_creds
		end
		base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		base.can_we_connect
		if $fail == 0
			base.sw_walk
			base.close
		else
			$fail=0
		end
	end

	#Enumerate Windows Running Services
	def snmp_services
		if not @snmp_target
			snmp_creds
		end
		base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		base.can_we_connect
		if $fail == 0
			base.services_walk
			base.close
		else
			$fail=0
		end
	end

	# Enumerate Windows Running Processes (Process, PID, & PATH)
	def snmp_processes
		if not @snmp_target
			snmp_creds
		end
		base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		base.can_we_connect
		if $fail == 0
			base.process_walk
			base.close
		else
			$fail=0
		end
	end

	# Enumerate Open TCP & UDP Ports, like Netstat
	def snmp_netstat
		if not @snmp_target
			snmp_creds
		end
		base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		base.can_we_connect
		if $fail == 0
			base.netstat_tcp
			print_line("")
			base.netstat_udp
			base.close
		else
			$fail=0
		end
	end

	def snmp_dump
		if not @snmp_target
			snmp_creds
		end
		base = SNMPStalker.new(@snmp_target,@snmp_port.to_i,@snmp_cstring)
		base.can_we_connect
		if $fail == 0
			base.dump
			base.close
		else
			$fail=0
		end
	end
end
