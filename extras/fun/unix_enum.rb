#!/usr/bin/env ruby
#
# Unix System Enumeration Ruby Script
# By: MrGreen & Hood3dRob1n
#

#Add some color without colorize gem since we sticking to std libs for this one :)
RS="\033[0m"    # reset
HC="\033[1m"    # hicolor
FRED="\033[31m" # foreground red
FGRN="\033[32m" # foreground green
FWHT="\033[37m" # foreground white

#Trap System interupts so we can exit clean....
trap("SIGINT") { puts "\n\n#{HC}#{FRED}WARNING! CTRL+C Detected, Shutting things down and exiting program#{FWHT}....#{RS}"; exit 666; }

#Define all the magic functions needed to make it all happen......
def all_sys_enum
	cls
	print "#{HC}#{FWHT}"
	puts '
|<><><><><><><><><><><><><><><><><><><><><><><>|
|            can       *       y0u             |
|   /\~~~~~~~~~~~~~~~~~|~~~~~~~~~~~~~~~~~/\    |
|  (o )                .                ( o)   |
|   \/               .` `.               \/    |
|   /\             .`     `.             /\    |
|  (             .`         `.             )   |
|   )          .`      N      `.          (    |
|  (         .`   A    |        `.         )   |
|   )      .`     <\> )|(         `.      (    |
|  (     .`         \  |  (         `.     )   |
|   )  .`         )  \ |    (         `.  (    |
|    .`         )     \|      (         `.     |
|  .`     W---)--------O--------(---E     `.   |
|   `.          )      |\     (          .`    |
|   ) `.          )    | \  (          .` (    |
|  (    `.          )  |  \          .`    )   |
|   )     `.          )|( <\>      .`     (    |
|  (        `.         |         .`        )   |
|   )         `.       S       .`         (    |
|  (            `.           .`            )   |
|   \/            `.       .`            \/    |
|   /\              `.   .`              /\    |
|  (o )               `.`               ( o)   |
|   \/~~~~~~~~~~~~~~~~~|~~~~~~~~~~~~~~~~~\/    |
|            find     -|-     r00t?            |
|<><><><><><><><><><><><><><><><><><><><><><><>|'
	puts
	print "#{RS}"
	foo = Time.now
	bar=foo.to_s.split(' ')
	puts "#{HC}#{FGRN}Unix System Enumerator Script#{RS}"
	puts "#{HC}#{FGRN}By#{FWHT}: Hood3dRob1n#{RS}"
	puts "#{HC}#{FGRN}Started#{FWHT}: #{bar[0]}#{FGRN}, at #{FWHT}#{bar[1]}#{RS}"
	puts
	puts "#{HC}#{FGRN}Highlights will be displayed in console#{FWHT}, #{FGRN}check '#{FWHT}inf0rm3d.txt#{FGRN}' file for full system enumeration details#{RS}"
	puts

	f = File.new("inf0rm3d.txt", "w+")
	f.print '|<><><><><><><><><><><><><><><><><><><><><><><>|
|            can       *       y0u             |
|   /\~~~~~~~~~~~~~~~~~|~~~~~~~~~~~~~~~~~/\    |
|  (o )                .                ( o)   |
|   \/               .` `.               \/    |
|   /\             .`     `.             /\    |
|  (             .`         `.             )   |
|   )          .`      N      `.          (    |
|  (         .`   A    |        `.         )   |
|   )      .`     <\> )|(         `.      (    |
|  (     .`         \  |  (         `.     )   |
|   )  .`         )  \ |    (         `.  (    |
|    .`         )     \|      (         `.     |
|  .`     W---)--------O--------(---E     `.   |
|   `.          )      |\     (          .`    |
|   ) `.          )    | \  (          .` (    |
|  (    `.          )  |  \          .`    )   |
|   )     `.          )|( <\>      .`     (    |
|  (        `.         |         .`        )   |
|   )         `.       S       .`         (    |
|  (            `.           .`            )   |
|   \/            `.       .`            \/    |
|   /\              `.   .`              /\    |
|  (o )               `.`               ( o)   |
|   \/~~~~~~~~~~~~~~~~~|~~~~~~~~~~~~~~~~~\/    |
|            find     -|-     r00t?            |
|<><><><><><><><><><><><><><><><><><><><><><><>|'
	f.puts
	f.puts
	f.puts "Unix System Enumerator Script"
	f.puts "By: Hood3dRob1n"
	f.puts "Started: #{bar[0]}, at #{bar[1]}"
	f.puts
	f.close

	basicInfo
	sleep 2
	getKernelSploits
	sleep 2
	interestingStuff
	sleep 2
	toolz
	sleep 2
	fileInfo
	sleep 2
	userInfo
	sleep 2
	networkInfo
	miscInfo

	closer
end

def basicInfo
	host = commandz('/bin/hostname 2> /dev/null')
	uptime = commandz('/usr/bin/uptime 2> /dev/null')
	shell = commandz('echo $SHELL 2> /dev/null')
	user = ENV['USER']
	whoami = commandz('whoami')
	uid = Process.uid
	euid = Process.euid
	home = commandz('echo $HOME 2> /dev/null')
	pwd = commandz('pwd')
	uname = commandz('uname -a')

	puts "#{HC}#{FGRN}Hostname#{FWHT}: #{host[0].strip}#{RS}"
	puts "#{HC}#{FGRN}System Uptime#{FWHT}: #{uptime[0].strip}#{RS}"
	puts "#{HC}#{FGRN}Current Shell in Use#{FWHT}: #{shell[0].strip}#{RS}"
	puts "#{HC}#{FGRN}Logged In User#{FWHT}: #{user}#{RS}"
	puts "#{HC}#{FGRN}Whoami#{FWHT}: #{whoami[0].strip}#{RS}"
	puts "#{HC}#{FGRN}UID#{FWHT}: #{uid}#{RS}"
	puts "#{HC}#{FGRN}EUID#{FWHT}: #{euid}#{RS}"
	puts "#{HC}#{FGRN}User Home Directory#{FWHT}: #{home[0].strip}#{RS}"
	puts "#{HC}#{FGRN}Current Working Dir#{FWHT}: #{pwd[0].strip}#{RS}"
	puts "#{HC}#{FGRN}Kernel/Build#{FWHT}: #{uname[0].strip}#{RS}"
	puts

	f = File.new("inf0rm3d.txt", "a+")
	f.puts "Hostname: #{host[0].strip}"
	f.puts "System Uptime: #{uptime[0].strip}"
	f.puts "Current Shell in Use: #{shell[0].strip}"
	f.puts "Logged In User: #{user}"
	f.puts "Whoami: #{whoami[0].strip}"
	f.puts "UID: #{uid}"
	f.puts "EUID: #{euid}"
	f.puts "User Home Directory: #{home[0].strip}"
	f.puts "Current Working Dir: #{pwd[0].strip}"
	f.puts "Kernel/Build: #{uname[0].strip}"
	f.puts
	f.close
end

def closer
	puts "\n#{HC}#{FGRN}Bye Now#{FWHT}!#{RS}\n\n"
	f = File.new("inf0rm3d.txt", "a+")
	f.puts
	f.puts "Bye Now!"
	f.puts
	f.close
end

def cls #A quick method to clear the whole terminal
	system('clear')
end

def commandz(foo)
	bar = IO.popen("#{foo}")
	foobar = bar.readlines
	return foobar
end

def fileInfo
	mem = commandz('free --lohi --human')
	mountz = commandz('mount')
	sizez = commandz('df -h')

	f = File.new("inf0rm3d.txt", "a+")
	f.puts "FILESYSTEM INFO: "
	puts "#{HC}#{FGRN}FILESYSTEM INFO#{FWHT}: #{RS}"
	if not mountz.empty?
		f.puts "Mounts: "
		puts "#{HC}#{FGRN}Mounts#{FWHT}: "
		mountz.each do |entry|
	 		puts "#{entry.strip}"
	 		f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
	end
	if not sizez.empty?
		f.puts "Disk Space: "
		puts "#{HC}#{FGRN}Disk Space#{FWHT}: "
		sizez.each do |entry|
	 		puts "#{entry.strip}"
	 		f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
	end
	if not mem.empty?
		f.puts "Memory Space: "
		puts "#{HC}#{FGRN}Memory Space#{FWHT}: "
		mem.each do |entry|
	 		puts "#{entry.strip}"
	 		f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
	end
	f.close
end

def getAV
	tools = commandz('whereis avast bastille bulldog chkrootkit clamav firestarter iptables jailkit logrotate logwatch lynis  pwgen rkhunter snort tiger truecrypt ufw webmin')

	if not tools.empty?
		f = File.new("inf0rm3d.txt", "a+")
		f.puts
		puts
		f.puts "Possible Security/AV Found: "
		puts "#{HC}#{FGRN}Possible Security/AV Found#{FWHT}: "
		tools.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
		f.close
	end
end

def getKernelSploits
	known_sploits=Hash.new
	known_sploits = { 
		"do_brk" => { "CVE" => "2003-0961", "versions" => ["2.4.0-2.4.22"], "exploits" => ["131"] },
		"mremap missing do_munmap" => { "CVE" => "2004-0077", "versions" => ["2.2.0-2.2.25", "2.4.0-2.4.24", "2.6.0-2.6.2"], "exploits" => ["160"] },
		"binfmt_elf Executable File Read" => { "CVE" => "2004-1073", "versions" => ["2.4.0-2.4.27", "2.6.0-2.6.8"], "exploits" => ["624"] },
		"uselib()" => { "CVE" => "2004-1235", "versions" => ["2.4.0-2.4.29rc2", "2.6.0-2.6.10rc2"], "exploits" => ["895"] },
		"bluez" => { "CVE" => "2005-1294", "versions" => ["2.6.0-2.6.11.5"], "exploits" => ["4756", "926"] },
		"prctl()" => { "CVE" => "2006-2451", "versions" => ["2.6.13-2.6.17.4"], "exploits" => ["2031", "2006", "2011", "2005", "2004"] },
		"proc" => { "CVE" => "2006-3626", "versions" => ["2.6.0-2.6.17.4"], "exploits" => ["2013"] },
		"system call emulation" => { "CVE" => "2007-4573", "versions" => ["2.4.0-2.4.30", "2.6.0-2.6.22.7"], "exploits" => ["4460"] },
		"vmsplice" => { "CVE" => "2008-0009", "versions" => ["2.6.17-2.6.24.1"], "exploits" => ["5092", "5093"] },
		"ftruncate()/open()" => { "CVE" => "2008-4210", "versions" => ["2.6.0-2.6.22"], "exploits" => ["6851"] },
		"eCryptfs (Paokara)" => { "CVE" => "2009-0269", "versions" => ["2.6.19-2.6.31.1"], "exploits" => ["spender"] },
		"set_selection() UTF-8 Off By One" => { "CVE" => "2009-1046", "versions" => ["2.6.0-2.6.28.3"], "exploits" => ["9083"] },
		"UDEV < 141" => { "CVE" => "2009-1185", "versions" => ["2.6.25-2.6.30"], "exploits" => ["8478", "8572"] },
		"exit_notify()" => { "CVE" => "2009-1337", "versions" => ["2.6.0-2.6.29"], "exploits" => ["8369"] },
		"ptrace_attach() Local Root Race Condition" => { "CVE" => "2009-1527", "versions" => ["2.6.29"], "exploits" => ["8678", "8673"] },
		"sock_sendpage() (Wunderbar Emporium)" => { "CVE" => "2009-2692", "versions" => ["2.6.0-2.6.31rc3", "2.4.0-2.4.37.1"], "exploits" => ["9641", "9545", "9479", "9436", "9435", "spender"] },
		"udp_sendmsg() (The Rebel)" => { "CVE" => "2009-2698", "versions" => ["2.6.0-2.6.9.2"], "exploits" => ["9575", "9574", "spender3"] },
		"(32bit) ip_append_data() ring0" => { "CVE" => "2009-2698", "versions" => ["2.6.0-2.6.9"], "exploits" => ["9542"] },
		"perf_counter_open() (Powerglove and Ingo m0wnar)" => { "CVE" => "2009-3234", "versions" => ["2.6.31"], "exploits" => ["spender"] },
		"pipe.c (MooseCox)" => { "CVE" => "2009-3547", "versions" => ["2.6.0-2.6.32rc5", "2.4.0-2.4.37"], "exploits" => ["10018", "spender"] },
		"CPL 0" => { "CVE" => "2010-0298", "versions" => ["2.6.0-2.6.11"], "exploits" => ["1397"] },
		"ReiserFS xattr" => { "CVE" => "2010-1146", "versions" => ["2.6.0-2.6.34rc3"], "exploits" => ["12130"] },
		"Unknown" => { "CVE" => 'nil', "versions" => ["2.6.18-2.6.20"], "exploits" => ["10613"] },
		"SELinux/RHEL5 (Cheddar Bay)" => { "CVE" => 'nil', "versions" => ["2.6.9-2.6.30"], "exploits" => ["9208", "9191", "spender"] },
		"compat" => { "CVE" => "2010-3301", "versions" => ["2.6.27-2.6.36rc4"], "exploits" => ["15023", "15024"] },
		"BCM" => { "CVE" => "2010-2959", "versions" => ["2.6.0-2.6.36rc1"], "exploits" => ["14814"] },
		"RDS protocol" => { "CVE" => "2010-3904", "versions" => ["2.6.0-2.6.36rc8"], "exploits" => ["15285"] },
		"put_user() - full-nelson" => { "CVE" => "2010-4258", "versions" => ["2.6.0-2.6.37"], "exploits" => ["15704"] },
		"sock_no_sendpage() - full-nelson" => { "CVE" => "2010-3849", "versions" => ["2.6.0-2.6.37"], "exploits" => ["15704"] },
		"ACPI custom_method" => { "CVE" => "2010-4347", "versions" => ["2.6.0-2.6.37rc2"], "exploits" => ["15774"] },
		"CAP_SYS_ADMIN" => { "CVE" => "2010-4347", "versions" => ["2.6.34-2.6.37"], "exploits" => ["15916", "15944"] },
		"econet_sendmsg() - half-nelson" => { "CVE" => "2010-3848", "versions" => ["2.6.0-2.6.36.2"], "exploits" => ["17787"] },
		"ec_dev_ioctl() - half-nelson" => { "CVE" => "2010-3850", "versions" => ["2.6.0-2.6.36.2"], "exploits" => ["17787", "15704"] },
		"Mempodipper" => { "CVE" => "2012-0056", "versions" => ["2.6.39-3.1"], "exploits" => ["18411", "mempo"]},
		"Archlinux x86-64 sock_diag_handlers[]" => { "CVE" => "2013-1763", "versions" => ["3.3-3.7"], "exploits" => ["24555"]},
		"Fedora 18 x86-64 sock_diag_handlers[]" => { "CVE" => "2013-1763", "versions" => ["3.3-3.7"], "exploits" => ["ps1"]},
		"Ubuntu 12.10 64-Bit sock_diag_handlers[]" => { "CVE" => "2013-1763", "versions" => ["3.3-3.7"], "exploits" => ["24746"]},
		"ipc - half-nelson" => { "CVE" => "2010-4073", "versions" => ["2.6.0-2.6.37rc1"], "exploits" => ["17787"] }
	}
	k = commandz('uname -r')[0].chomp
	specialk = k.split('-')[0] #just a generic check so we dont care about the trailing aspects in this case, comes into play for manual review....
	exploit_db = "http://www.exploit-db.com/exploits/"
	mempo = "http://git.zx2c4.com/CVE-2012-0056/snapshot/CVE-2012-0056-master.zip"
	spender = "http://www.securityfocus.com/data/vulnerabilities/exploits/36423.tgz"
	ps1 = "http://packetstormsecurity.com/files/download/120784/fedora-sockdiag.c"
	f = File.new("inf0rm3d.txt", "a+")
	f.puts "Possible Exploits: "
	puts "#{HC}#{FGRN}Possible Exploits#{FWHT}: #{RS}"
	known_sploits.each do |key, value|
		versions = value["versions"]
		vsize = versions.size
		count=0
		@found=0
		while count.to_i < vsize.to_i
			versions.each do |v|
				if v =~ /-/
					vrange = v.split('-')
					min = vrange[0]
					max = vrange[1]
				else
					min = v
					max = v
				end
				if specialk.to_f >= min.to_f and specialk.to_f <= max.to_f
					foo = specialk.split('.')
					foo.shift
					kfoo = foo.join('.')

					foo = min.split('.')
					foo.shift
					minfoo = foo.join('.')

					foo = max.split('.')
					foo.shift
					maxfoo = foo.join('.')

					if kfoo.to_f >= minfoo.to_f and kfoo.to_f <= maxfoo.to_f
						@found = @found.to_i + 1
						cve = value["CVE"]
						exploit = value["exploits"]
						puts "#{HC}#{FGRN}Kernel#{FWHT}: #{k}#{RS}"
						puts "#{HC}#{FGRN}Possible Exploit#{FWHT}: #{key}#{RS}"
						puts "#{HC}#{FGRN}CVE#{FWHT}: #{cve}#{RS}"
						puts "#{HC}#{FGRN}Versions Affected#{FWHT}: #{versions.join(', ')}#{RS}"
						puts "#{HC}#{FGRN}Downloads Available for Possible Exploit#{FWHT}: "
						f.puts "Kernel: #{k}"
						f.puts "Possible Exploit: #{key}"
						f.puts "CVE: #{cve}"
						f.puts "Versions Affected: #{versions.join(', ')}"
						f.puts "Downloads Available for Possible Exploit: "
						exploit.each do |sploit|
							if sploit == "spender"
								puts "#{spender}"
								f.puts "#{spender}"
							elsif sploit == "mempo"
								puts "#{mempo}"
								f.puts "#{mempo}"
							elsif sploit == "ps1"
								puts "#{ps1}"
								f.puts "#{ps1}"
							else
								puts "#{exploit_db}#{sploit}"
								f.puts "#{exploit_db}#{sploit}"
							end
						end
						puts "#{RS}"
						f.puts
					end
				end
				count = count.to_i + 1
			end
		end
	end
	if @found.to_i == 0
		puts "#{HC}#{FWHT}Sorry, didn't find any matching exploits for kernel#{FGRN}....#{RS}"
		f.puts "Sorry, didn't find any matching exploits for kernel...."
	else
		puts "#{HC}#{FWHT}Hopefully you can use the above to help find your way to r00t#{FGRN}....#{RS}"
		f.puts "Hopefully you can use the above to help find your way to r00t...."
	end
	puts
	f.puts
	f.close
end

def getPassAndConfigs
	f = File.new("inf0rm3d.txt", "a+")
	puts "#{HC}#{FGRN}Checking for Password & Config Files#{FWHT}....#{RS}"
	f.puts "Password & Config Files:"
	puts "#{HC}#{FGRN}ALL config.php Files#{FWHT}:#{RS}"
	f.puts "ALL config.php Files:"
	Dir.glob('/**/config.php') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL config.inc.php Files#{FWHT}:#{RS}"
	f.puts "ALL config.inc.php Files:"
	Dir.glob('/**/config.inc.php') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL wp-config.php Files#{FWHT}:#{RS}"
	f.puts "ALL wp-config.php Files:"
	Dir.glob('/**/wp-config.php') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL db.php Files#{FWHT}:#{RS}"
	f.puts "ALL db.php Files:"
	Dir.glob('/**/db.php') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL db-conn.php Files#{FWHT}:#{RS}"
	f.puts "ALL db-conn.php Files:"
	Dir.glob('/**/db-conn.php') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL sql.php Files#{FWHT}:#{RS}"
	f.puts "ALL sql.php Files:"
	Dir.glob('/**/sql.php') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL security.php Files#{FWHT}:#{RS}"
	f.puts "ALL security.php Files:"
	Dir.glob('/**/security.php') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL service.pwd Files#{FWHT}:#{RS}"
	f.puts "ALL service.pwd Files:"
	Dir.glob('/**/service.pwd') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL .htpasswd Files#{FWHT}:#{RS}"
	f.puts "ALL .htpasswd Files:"
	Dir.glob('/**/.htpasswd') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL .sql Database Files#{FWHT}:#{RS}"
	f.puts "ALL .sql Database Files:"
	Dir.glob('/**/*.sql') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	puts "#{HC}#{FGRN}ALL .bash_history Files#{FWHT}:#{RS}"
	f.puts "ALL .bash_history Files:"
	Dir.glob('/**/.bash_history') do |gold|
		puts "#{HC}#{FWHT}#{gold.chomp}#{RS}"
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	puts
	f.puts
	f.puts "ALL config.* Files:"
	Dir.glob('/**/config.*') do |gold|
		f.puts "#{gold.chomp}"
		print ""
		f.print
	end
	f.close
end

def getSSH
	f = File.new("inf0rm3d.txt", "a+")
	puts "#{HC}#{FGRN}SSH Goodness#{FWHT}: "
	f.puts "SSH Goodness: "
	Dir.glob('/**/.ssh/*') do |gold|
		puts "#{HC}#{FGRN}#{gold}#{FWHT}: "
		f.puts "#{gold}: "
		content = commandz("cat #{gold} 2> /dev/null")
		content.each do |line|
	 		puts "#{line.strip}"
	 		f.puts "#{line.strip}"
		end
		puts "#{RS}"
		f.puts
	end
	f.close
end

def interestingStuff
	f = File.new("inf0rm3d.txt", "a+")
	f.puts "INTERESTING INFO: "
	puts "#{HC}#{FGRN}INTERESTING INFO#{FWHT}: #{RS}"

	writable = commandz('find / -type d -perm -2 -ls 2> /dev/null')
	if not writable.empty?
		puts "#{HC}#{FGRN}World Writable Directories#{FWHT}: "
		f.puts "World Writable Directories: "
		writable.each do |entry|
	 		puts "#{entry.strip}"
	 		f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
		sleep 2
	end

	suid = commandz('find / -type f -perm -04000 -ls 2> /dev/null')
	if not suid.empty?
		puts "#{HC}#{FGRN}SUID Files#{FWHT}: "
		f.puts "SUID Files: "
		suid.each do |entry|
	 		puts "#{entry.strip}"
	 		f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
		sleep 2
	end

	guid = commandz('find / -type f -perm -02000 -ls 2> /dev/null')
	if not guid.empty?
		puts "#{HC}#{FGRN}GUID Files#{FWHT}: "
		f.puts "GUID Files: "
		guid.each do |entry|
	 		puts "#{entry.strip}"
	 		f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
	end
	f.close

	getSSH
	getPassAndConfigs

	sudos = commandz('cat /etc/sudoers')
	if not sudos.empty?
		puts "#{HC}#{FGRN}/etc/sudoers Content#{FWHT}: "
		f = File.new("inf0rm3d.txt", "a+")
		f.puts
		f.puts "/etc/sudoers Content: "
		sudos.each do |line|
	 		puts "#{line.strip}"
	 		f.puts "#{line.strip}"
		end
		f.puts
		f.close
		sleep 2
	end
end

def miscInfo
	logz = commandz('ls -lRa /var/log')
	etcls = commandz('ls -lRa /etc')
	tmp = commandz('ls -lRa /tmp')
	lgmsgz = commandz('cat /var/log/messages')
	last = commandz('last -50')

	f = File.new("inf0rm3d.txt", "a+")
	f.puts "MISC INFO: "
	f.puts "Cron Jobs: "
	Dir.glob('/etc/cron*') do |gold|
		f.puts "#{gold}: "
		f.puts
	end
	if not logz.empty?
		f.puts "/var/log content: "
		logz.each do |entry|
	 		f.puts "#{entry.strip}"
		end
		f.puts
	end
	if not etcls.empty?
		f.puts "/etc content: "
		etcls.each do |entry|
	 		f.puts "#{entry.strip}"
		end
		f.puts
	end
	if not tmp.empty?
		f.puts "/tmp content: "
		tmp.each do |entry|
	 		f.puts "#{entry.strip}"
		end
		f.puts
	end
	if not lgmsgz.empty?
		f.puts "/var/log/messages content: "
		lgmsgz.each do |entry|
	 		f.puts "#{entry.strip}"
		end
		f.puts
	end
	if not last.empty?
		f.puts "Last 50 logins: "
		last.each do |entry|
	 		f.puts "#{entry.strip}"
		end
		f.puts
	end
	f.close
end

def networkInfo
	interfaces = `/sbin/ifconfig -a 2> /dev/null`
	hosts = commandz('cat /etc/hosts')
	resolvers = commandz('cat /etc/resolv.conf 2> /dev/null')
	route = commandz('route 2> /dev/null')
	ports = commandz('netstat -lpn 2> /dev/null')
	listening = commandz('netstat -n --listen 2> /dev/null')
	procs = commandz('ps axuw')

	puts "#{HC}#{FGRN}Known Interfaces#{FWHT}:#{RS}"
	system('/sbin/ifconfig -a 2> /dev/null')
	f = File.new("inf0rm3d.txt", "a+")
	f.puts "NETWORK INFO: "
	f.puts "Known Interfaces:"
	f.puts interfaces
	f.puts
	if not resolvers.empty?
		puts "#{HC}#{FGRN}resolv.conf Content#{FWHT}:"
		f.puts "resolv.conf Content:"
		resolvers.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
	end
	if not hosts.empty?
		f.puts "/etc/hosts Content:"
		hosts.each do |entry|
			f.puts "#{entry.strip}"
		end
		f.puts
	end
	if not route.empty?
		f.puts "Routing Table:"
		route.each do |entry|
			f.puts "#{entry.strip}"
		end
		f.puts
	end
	if not ports.empty?
		puts "#{HC}#{FGRN}Netstat - Open Ports and Services#{FWHT}:"
		f.puts "Netstat - Open Ports and Services:"
		ports.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
		sleep 1
	end
	if not listening.empty?
		f.puts "Listening Ports:"
		listening.each do |entry|
			f.puts "#{entry.strip}"
		end
		f.puts
	end
	if not procs.empty?
		f.puts "Process listing:"
		procs.each do |entry|
			f.puts "#{entry.strip}"
		end
		f.puts
	end
	f.close
end

def toolz
	tools = commandz('which curl gcc java lynx nc ncat netcat nmap ftp perl php proxychains python ruby tcpdump wget wireshark')
	gcc = commandz('gcc --version')
	mysql = commandz('mysql --version')
	perl = commandz('perl -v')
	php = commandz('php --version')
	ruby = commandz('ruby -v ')
	java = commandz('foo=$(java -version 2>&1); echo $foo;')
	python = commandz('foo=$(python -V 2>&1); echo $foo;')

	f = File.new("inf0rm3d.txt", "a+")
	f.puts
	puts
	f.puts "LOCAL TOOLS: "
	puts "#{HC}#{FGRN}LOCAL TOOLS#{FWHT}: "
	if not tools.empty?
		tools.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
	end
	puts "#{RS}"
	f.puts
	puts "#{HC}#{FGRN}Version Info#{FWHT}: "
	f.puts "Version Info: "
	if not gcc.empty?
		gcc.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
	end
	if not mysql.empty?
		mysql.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
	end
	if not perl.empty?
		perl.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
	end
	if not python.empty?
		python.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
	end
	puts
	f.puts
	if not java.empty?
		java.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
	end
	puts
	f.puts
	if not php.empty?
		php.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
	end
	puts
	f.puts
	if not ruby.empty?
		ruby.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
	end
	puts "#{RS}"
	f.puts
	f.close
end

def userInfo
	userCount = commandz('cat /etc/passwd | /usr/bin/wc -l')
	shadow = commandz('cat /etc/shadow 2> /dev/null')
	users = commandz('cat /etc/passwd')
	group = commandz('cat /etc/group')

	puts "#{HC}#{FGRN}USER INFO#{FWHT}: #{RS}"
	puts "#{HC}#{FGRN}Number of user accounts#{FWHT}: #{userCount[0].strip}#{RS}"

	f = File.new("inf0rm3d.txt", "a+")
	f.puts "USER INFO: "
	f.puts "Number of user accounts: #{userCount[0].strip}"
	if not shadow.empty?
		puts "#{HC}#{FGRN}/etc/shadow Content#{FWHT}:"
		f.puts "/etc/shadow Content:"
		shadow.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
		sleep 2
	end
	if not users.empty?
		puts "#{HC}#{FGRN}/etc/passwd Content#{FWHT}:"
		f.puts "/etc/passwd Content:"
		users.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
		sleep 2
	end
	if not group.empty?
		f.puts "/etc/group Content:"
		puts "#{HC}#{FGRN}/etc/group Content#{FWHT}:"
		group.each do |entry|
			puts "#{entry.strip}"
			f.puts "#{entry.strip}"
		end
		puts "#{RS}"
		f.puts
		sleep 2
	end
	f.close
end

all_sys_enum
#EOF
