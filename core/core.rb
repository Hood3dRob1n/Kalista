#Our Core Shell housing just our core functions needed to keep the party going
# See the libs and plugins directory for details on how things are broken out
# Libs files should be for core functions shared throughout
# plugins should be used for classes to house the specifics and functions/wrappers for various tools and what not
#
class CoreShell
	trap('INT', 'SIG_IGN') #Trap interupts and force user to exit via core_shell menu option! Prevents errors with readline...

	def initialize
		#Load up any lib files found in the ./lib/ dir so available in core from start
		$libs=[]
		Dir.glob("#{HOME}/core/*.rb").each do |core|
			require "#{core}"
			$libs << "#{core}"
		end

		#Load all of the found plugins from /plugions/ dir so we can offer as options to use for loading later.....
		$modules=[]
		Dir.glob("#{HOME}/classes/*.rb").each do |classes|
			require "#{classes}"
			$modules << "#{classes}"
		end

		#Initialize a results directory if one does not exist
		$results="#{Dir.pwd}/results/"
		Dir.mkdir($results) unless File.exists?($results)

		#Initialize a results directory if one does not exist
		$temp="#{Dir.pwd}/classes/temp/"
		Dir.mkdir($temp) unless File.exists?($temp)
	end

	#Clear Terminal
	def cls
		system('clear')
	end

	#Simple Banner
	def banner
		print_line("")
		puts "  _|_|                                  _|          _|  _|                     ".light_green
		puts "_|    _|  _|_|_|      _|_|    _|_|_|    _|          _|      _|  _|_|    _|_|   ".light_green
		puts "_|    _|  _|    _|  _|_|_|_|  _|    _|  _|    _|    _|  _|  _|_|      _|_|_|_| ".light_green
		puts "_|    _|  _|    _|  _|        _|    _|    _|  _|  _|    _|  _|        _|       ".light_green
		puts "  _|_|    _|_|_|      _|_|_|  _|    _|      _|  _|      _|  _|          _|_|_| ".light_green
		puts "         _|                                                                    ".light_green
		puts "         _|                                                                    ".light_green
		puts "                                      OpenWire Project Kalista, v0.1-aplha     ".light_red
		print_line("")
	end

	#Main Menu Help Options
	def show_usage
		puts "List of commands and description of usage".light_yellow + ": ".white
		puts "\tclear".light_yellow + "     => ".white + "Clear Screen".light_yellow
		puts "\texit".light_yellow + "      => ".white + "Exit Completely".light_yellow
		puts "\thelp ".light_yellow + "     => ".white + "Display this Help Menu".light_yellow
		print_line("")
		puts "\trecon".light_yellow + "     => ".white + "Recon & Discovery Shell".light_yellow
		puts "\tlogin".light_yellow + "     => ".white + "Logins & Bruteforcers Shell".light_yellow
		puts "\tpayload".light_yellow + "   => ".white + "Payloads Builder Shell".light_yellow
		puts "\tlistener".light_yellow + "  => ".white + "Listener & Connection Handler Setup".light_yellow
		puts "\tsnmp".light_yellow + "      => ".white + "Windows SNMP Enumation Tools".light_yellow
		puts "\tsmb".light_yellow + "       => ".white + "SMB Tools".light_yellow
		puts "\texploit".light_yellow + "   => ".white + "Exploits Shell".light_yellow
		puts "\twifi".light_yellow + "      => ".white + "WiFi Shell".light_yellow
		puts "\tmitm".light_yellow + "      => ".white + "MiTM Shell".light_yellow
		puts "\tupdate ".light_yellow + "   => ".white + "Updater".light_yellow
		print_line("")
		puts "\tlocal".light_yellow + "     => ".white + "Local OS Shell".light_yellow
		puts "\trb <code>".light_yellow + " => ".white + "Evaluates Ruby Code".light_yellow
		print_line("")
	end

	#Core/Main Menu
	def core_shell
		#Use readline module to keep history of commands while in sudo shell
		prompt = "(Kalista)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^clear|^cls|^banner/i
					cls
					banner
					core_shell
				when /^help|^h$|^ls$/i
					show_usage
					core_shell
				when /^exit|^quit/i
					print_line("")
					print_error("OK, exiting Kalista....")
					print_line("")
					exit 69;
				when /^recon|^discover/i
					recon_shell
					puts
					core_shell
				when /^brute|^login|^creds/i
					logins_shell
					print_line("")
					core_shell
				when /^build|^payload/i
					payloads_shell
					print_line("")
					core_shell
				when /^listen/i
					cls
					banner
					listener_shell
					print_line("")
					core_shell
				when /^exploit|^x$/i
					exploits_shell
					print_line("")
					core_shell
				when /^smbfun|^smb/i
					smbfun_shell
					print_line("")
					core_shell
				when /^wifi|^x$/i
					wifi_shell
					print_line("")
					core_shell
				when /^mitm|^middle|^x$/i
					mitm_shell
					print_line("")
					core_shell
				when /^snmp/i
					snmp_shell
					print_line("")
					core_shell
				when /^update/i
					updates_shell
					print_line("")
					core_shell
				when /^rb (.+)/i
					code=$1.chomp
					rubyme("#{code}")
					print_line("")
					core_shell
				when /^local/i
					local_shell
					print_line("")
					core_shell
				else
					cls
					print_line("")
					print_error("Oops, Didn't quite understand that one")
					print_error("Please Choose a Valid Option From Menu Below Next Time.....")
					print_line("")
					show_usage
					core_shell
				end
		end    
	end

	#Recon & Discovery Menu
	def recon_shell
		if not $recon
			$recon = Recon.new
		end
		$recon.r_shell
	end

	#Login & Bruteforcer Menu
	def logins_shell
		if not $logins
			$logins = LoginBrute.new
		end
		$logins.l_shell
	end

	#Payload Builder Menu
	def payloads_shell
		if not $payloads
			$payloads = PayloadBuilder.new
		end
		$payloads.p_shell
	end

	#Listener Setup
	def listener_shell
		if not $listener
			$listener = Listener.new
		end
		$listener.listener_builder
	end

	#Common SMB Fun Made Easy
	def smbfun_shell
		if not $smbfun
			$smbfun = SMBWrap.new
		end
		$smbfun.s_shell
	end

	#Common Exploit Made Easy
	def exploits_shell
		if not $exploit
			$exploit = Exploit.new
		end
		$exploit.e_shell
	end

	#WiFi Attacks I am able to code :p
	def wifi_shell
		if not $wifi
			$wifi = WiFiSploit.new
		end
		$wifi.w_shell
	end

	#MiTM LAN Attacks I can code up :p
	def mitm_shell
		if not $mitm
			$mitm = TMiddler.new
		end
		$mitm.m_shell
	end

	# SNMP Recon, Enumeration, and Attacks
	def snmp_shell
		if not $snmp
			$snmp = SNMPShell.new
		end
		$snmp.snmp_shell
	end

	#Updates Shell Menu
	def updates_shell
		if not $updater
			$updater = Updater.new
		end
		$updater.u_shell
	end

	#Local OS Command Shell for on the fly shit.....
	def local_shell
		cls
		banner
		prompt = "(localOS)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^exit$|^quit$|^back$/i
					print_error("OK, Returning to Main Menu....")
					break
				else
					begin
						rez = `#{cmd}` #Run command passed
						puts "#{rez}".cyan #print results nicely for user....
					rescue Errno::ENOENT => e
						print_error("#{e}")
					rescue => e
						print_caution("#{e}")
					end
				end
		end
	end

	#Ruby Eval() Console for testing ruby shit on the fly.....
	def rubyme(code)
		begin
			print_line("#{eval("#{code}")}")
		rescue NoMethodError => e
			print_error("#{e}")
		rescue NameError => e
			print_error("#{e}")
		rescue SyntaxError => e
			print_error("#{e}")
		rescue TypeError => e
			print_error("#{e}")
		end
	end
end
