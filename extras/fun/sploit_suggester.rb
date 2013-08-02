#!/usr/bin/env ruby

#Add some color without colorize gem since we sticking to std libs for this one :)
RS="\033[0m"    # reset
HC="\033[1m"    # hicolor
FRED="\033[31m" # foreground red
FGRN="\033[32m" # foreground green
FWHT="\033[37m" # foreground white

#Trap System interupts so we can exit clean....
trap("SIGINT") { puts "\n\n#{HC}#{FRED}WARNING! CTRL+C Detected, Shutting things down and exiting program#{FWHT}....#{RS}"; exit 666; }

def commandz(foo)
	bar = IO.popen("#{foo}")
	foobar = bar.readlines
	return foobar
end

def suggestions
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
	puts "#{HC}#{FGRN}Possible Exploits#{FWHT}: #{RS}"
	known_sploits.each do |key, value|
		versions = value["versions"]
		vsize = versions.size
		count=0
		found=0
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
						found = found.to_i + 1
						cve = value["CVE"]
						exploit = value["exploits"]
						puts "#{HC}#{FGRN}Kernel#{FWHT}: #{k}#{RS}"
						puts "#{HC}#{FGRN}Possible Exploit#{FWHT}: #{key}#{RS}"
						puts "#{HC}#{FGRN}CVE#{FWHT}: #{cve}#{RS}"
						puts "#{HC}#{FGRN}Versions Affected#{FWHT}: #{versions.join(', ')}#{RS}"
						puts "#{HC}#{FGRN}Downloads Available for Possible Exploit#{FWHT}: "
						exploit.each do |sploit|
							if sploit == "spender"
								puts "#{spender}"
							elsif sploit == "mempo"
								puts "#{mempo}"
							elsif sploit == "ps1"
								puts "#{ps1}"
							else
								puts "#{exploit_db}#{sploit}"
							end
						end
						puts "#{RS}"
					end
				end
				count = count.to_i + 1
			end
		end
	end
end

suggestions
