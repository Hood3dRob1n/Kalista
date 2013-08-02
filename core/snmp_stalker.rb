# This is a wrapper class for the SNMP Pure Ruby Implementation (gem install snmp)
# It simple extends the underlying gem to make methods available in simpler manner
# for me anyways.....
# Leaving separate and you can call from the snmp.rb class script as needed

class SNMPStalker
	def initialize(host,port,string)
		@host = host
		@port = port
		@string = string
		@manager = SNMP::Manager.new(:Host => host, :Port => port, :Community => string)
	end

	#Convert OID 2 Symbolic Name
	def oid2name(oid)
		name = @manager.mib.name(oid)
		t = [['OID', 'Symbolic Name'], ["#{oid}", "#{name}"]]
		table = t.to_table(:first_row_is_head => true)
		puts table.to_s
	end

	#Convert Name to OID
	def name2oid(name)
		oid = @manager.mib.oid(name)
		t = [['OID', 'Symbolic Name'], ["#{oid}", "#{name}"]]
		table = t.to_table(:first_row_is_head => true)
		puts table.to_s
	end

	# Walk the target OID or OID Symbolic Name tree if available....
	# Nice if you need something random perhaps
	def walk(oidorname)
		print_status("Trying to Walk the '#{oidorname}' tree......")
		@manager.walk("#{oidorname}") { |x| print_good("#{x}") }
	end

	# SET value for specified OID with given string
	# ex: set("1.3.6.1.2.1.1.5.0", "FooFucked") # => would change device system name value to string 'FooFucked'
	def set(oid, string)
		print_status("Trying to SET value of '#{oid}' to '#{string}'......")
		old = @manager.get_value(oid)
		print_status("Current Value: #{old}")
		varbind = VarBind.new(oid, OctetString.new(string))
		@manager.set(varbind)
		new = @manager.get_value(oid)
		print_status("Updated Value: #{new}")
	end

	#Confirm credentials are working
	def can_we_connect
		begin
			@sys_time = @manager.get_value("sysUpTime.0")
		rescue SNMP::RequestTimeout => e
			print_error("#{e}")
			print_error("Can't connect using '#{@string.chomp}'!")
			$fail=1
		end
	end

	# Enumerate some basic info about the target
	def basic_info
		#Grab some basic info using OID values which should be fairly generic in nature
		target = "#{@manager.config[:host]}:#{@manager.config[:port]}"
		cstring = @manager.config[:community]
		@snmp_version = @manager.config[:version] #We need this one later for some decisions so setting to class var
		sys_name = @manager.get_value("sysName.0")
		sys_descr = @manager.get_value("sysDescr.0")

		#Print out our basic info for user
		puts "[*] ".light_green + "Target".light_yellow + ": #{target}".white
		puts "[*] ".light_green + "Community String".light_yellow + ": #{cstring}".white
		if @snmp_version
			puts "[*] ".light_green + "SNMP Version".light_yellow + ": #{@snmp_version}".white
		else
			print_caution("Unable to determine SNMP Version in use?")
		end
		if sys_name
			puts "[*] ".light_green + "System Name".light_yellow + ": #{sys_name}".white
		else
			print_error("Unable to determine system name!")
		end
		if sys_descr
			puts "[*] ".light_green + "System Description".light_yellow + ": \n#{sys_descr}".white
		else
			print_error("Unable to find system description!")
		end
		if @sys_time
			puts "[*] ".light_green + "System Uptime".light_yellow + ": #{@sys_time}".white
		else
			print_error("Unable to find system description!")
		end
	end

	# Walk the "SNMPv2-SMI::enterprises.77.1.2.25" or "1.3.6.1.4.1.77.1.2.25" tree
	# This will disclose the existing Windows Usernames for valid accounts on box
	def users_walk
		print_status('Enumerating Usernames.....')
		users=[['Usernames']]
		@manager.walk('enterprises.77.1.2.25') { |x| users << ["#{x.value}"] }
		if users.empty?
			print_error("No Values Found!")
		else
			print_good("#{users.size} Usernames Found!")
			table = users.to_table(:first_row_is_head => true)
			puts table.to_s
		end
	end

	# Walk the 'SNMPv2-SMI::mib-2.25.6.3.1.2' or '1.3.6.1.2.1.25.6.3.1.2' tree
	# This will disclose the currently installed software on system
	def sw_walk
		print_status('Enumerating Installed Software.....')
		sw=[['Installed Software']]
		@manager.walk('mib-2.25.6.3.1.2') { |x| sw << ["#{x.value}"] }
		if sw.empty?
			print_error("No Values Found!")
		else
			table = sw.to_table(:first_row_is_head => true)
			puts table.to_s
		end
	end
	# Enumerate Running Services (Windows)
	# Walk the 'SNMPv2-SMI::enterprises.77.1.2.3.1.1' or '1.3.6.1.4.1.77.1.2.3.1.1' tree
	# This will disclose the currently running windows services
	def services_walk
		print_status('Enumerating Running Services.....')
		services=[['Running Services']]
		@manager.walk('enterprises.77.1.2.3.1.1') { |x| services << ["#{x.value}"] }
		if services.empty?
			print_error("No Values Found!")
		else
			table = services.to_table(:first_row_is_head => true)
			puts table.to_s
		end
	end

	# Enumerate the Currently Running Processes
	# Process Name, PID, and PATH returned
	# PROCESS: Symbolic Name: mib-2.25.4.2.1.2 or OID: 1.3.6.1.2.1.25.4.2.1.2
	# PID: Symbolic Name: mib-2.25.4.2.1.1 or OID: 1.3.6.1.2.1.25.4.2.1.1
	# PATH: Symbolic Name: mib-2.25.4.2.1.4 or OID: 1.3.6.1.2.1.25.4.2.1.4
	def process_walk
		print_status('Enumerating Running Process.....')
		psz=[] #process name
		@manager.walk('mib-2.25.4.2.1.2') { |x| psz << x.value }
		if psz.empty?
			print_error("No Values Found!")
		else
			ps_present = [['PID', 'Process', 'Path']]
			pidz=[] #PID valud
			@manager.walk('mib-2.25.4.2.1.1') { |x| pidz << x.value }

			pathz=[] #Path of process
			@manager.walk('mib-2.25.4.2.1.4') do |path|
				if path.value.chomp != '' and not path.nil?
					pathz << path.value
				else
					pathz << " - "
				end
			end
			count=0
			while count.to_i < psz.size
				ps_present << [[ "#{pidz[count]}", "#{psz[count]}", "#{pathz[count]}" ]]
				count = count.to_i + 1
			end

			table = ps_present.to_table(:first_row_is_head => true)
			puts table.to_s
		end
	end

	# Enumerate Listening and Open TCP Ports (a.k.a. Netstat Output)
	# Walk the tcpConnState or 1.3.6.1.2.1.6.13.1.1 oid names (not values)
	# Results needs some formatting to make like netstat....
	def netstat_tcp
		tcp=[]
		print_status('Enumerating Open TCP Ports.....')
		@manager.walk('tcpConnState') {|x| tcp << x.to_s.split(", ")[0].sub('[name=TCP-MIB::tcpConnState.', '') }
		if not tcp.empty?
			puts "[*] ".light_green + "OPEN TCP PORTS".light_yellow + ": ".white
			tcp.each do |entry|
				if entry =~ /(\d+.\d+.\d+.\d+).(\d+).(\d+.\d+.\d+.\d+).(\d+)/ or entry =~ /(\d+.\d+.\d+.\d+).(\d+)/
					ip=$1
					port=$2
					ip2=$3
					port2=$4
					print_good("#{ip}:#{port}")
					if ip2 and port2
						print_good("#{ip2}:#{port2}")
					end
				else
					print_good("#{entry}")
				end
			end
		else
			print_error("No Values Found!")
		end
	end

	# Enumerate Listening and Open UDP Ports (a.k.a. Netstat Output)
	# Walk the udpLocalAddress or 1.3.6.1.2.1.7.5.1.1 oid names (not values)
	# Results needs some formatting to make like netstat....
	def netstat_udp
		udp=[]
		print_status('Enumerating Open UDP Ports.....')
		@manager.walk('udpLocalAddress') {|x| udp << x.to_s.split(", ")[0].sub('[name=UDP-MIB::udpLocalAddress.', '') }
		if not udp.empty?
			puts "[*] ".light_green + "OPEN UDP PORTS".light_yellow + ": ".white
			udp.each do |entry|
				if entry =~ /(\d+.\d+.\d+.\d+).(\d+)/
					ip=$1
					port=$2
					print_good("#{ip}:#{port}")
				else
					print_good("#{entry}")
				end
			end
		else
			print_error("No Values Found!")
		end
	end

	# Dump the 'MGMT' OID
	# Discloses most everything it has stored....
	# Nice if you need something random perhaps
	def dump
		print_status("Dumping a bunch of info from the 'mgmt' OID......")
		dumpz=[]
		@manager.walk('mgmt') { |x| dumpz << x }
		if dumpz.empty?
			print_error("No Values Found!")
		else
			puts "[*] ".light_green + "SNMP MGMT Dump".light_yellow + ": ".white
			dumpz.each do |entry|
				print_good("#{entry}")
			end
		end
	end

	# Close the SNMP Connection cleanly
	def close
		@manager.close
	end
end

#Helpful Print Status Function
def print_status(string)
	puts "[*] ".light_blue + "#{string}".white
end

#Cautionary Print Status Function
def print_caution(string)
	puts "[*] ".light_yellow + "#{string}".white
end

#Helpful Print Good or Positive Results
def print_good(string)
	puts "[*] ".light_green + "#{string}".white
end

#Helpful Print Error or Negative/False Results
def print_error(string)
	puts "[*] ".light_red + "#{string}".white
end

# Print Line
def print_line(string)
	puts "#{string}".white
end
