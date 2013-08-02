#!/usr/bin/env ruby
#
# Kalista Dependency & Installation Helper
# Assumes you already have Ruby and Git installed, tries to do the rest....
# Trying to make it work on more than Kali....
#

# EDIT THIS TO WHERE YOU WANT SHIT INSTALLED
######################
INSTALL='/root/fun/' #
######################

#Trap any interupt signals for cleaner termination, add cleanup as needed....
trap("SIGINT") { puts "\n\nWARNING! CTRL+C Detected, shutting down!"; exit 666 }

# Execute commands safely, result is returned as array
def commandz(foo)
	bar = IO.popen("#{foo}")
	foobar = bar.readlines
	return foobar
end

# Check dependencies by checking which tools are already installed and where
# Returns an array with the name of each tool which still needs to be installed
def check_depenencies
	check_installer
	check_git
	check_tools
	check_gems
end

#Check gems needed and return array of those needed
def check_gems
	puts "Installing Ruby Gems....."
	gemz = [ 'rb-readline', 'colorize', 'snmp', 'text-table' ]
	Dir.chdir(INSTALL) {
		gemz.each do |g|
			system("sudo gem install #{g}")
		end
	}
end

# Check if Git is already installed as we need it for many tools and you should have it if you dont already! :p
def check_git
	g = commandz('which git')
	if not g.size > 0
		puts "Attempting to install git...."
		if @fetch == 'yum'
			system("sudo #{@fetch} install curl-devel expat-devel gettext-devel openssl-devel zlib-devel")
		elsif @fetch == 'apt-get'
			system("sudo #{@fetch} install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev")
		else
			puts
			puts "Git doesn't appear to be installed & you have no available package manager!"
			puts "Can't continue without these key items!"
			puts "Try things manually or try installing git manually......"
			puts
			puts
			exit 666;
		end
		system("sudo #{@fetch} install git")
	else
		puts "Git appears to be installed!"
	end
end

# Small function to determine our package installer, apt-get or yum
# Expand it in future to include more options....
def check_installer
	a = commandz('which apt-get')
	if not a.size > 0
		puts "Apt-Get appears to be installed!"
		@fetch='apt-get'
	else
		puts "Apt-Get doesn't appears to be available, checking for yum....."
		b = commandz('which yum')
		if not b.size > 0
			puts "Yum appears to be installed!"
			@fetch='yum'
		else
			puts
			puts "Can't find a package installer I know how to use!"
			puts "You will have issues installing some of the dependencies as a result, sorry....."
			puts
			@fetch='nil'
		end
	end
end
#Check tools and return array of those needed
def check_tools
	toolz = [ 'msfconsole', 'keimpx', 'dnsrecon', 'dnsmap', 'nmap', 'netdiscover', 'nbtscan', 'aircrack-ng', 'dsniff', 'macchanger',  'evilgrade', 'sslstrip', 'driftnet' ] #'pwdump'
	Dir.chdir(INSTALL) {
		toolz.each do |t|
			case t
#			when 'pwdump'
#				e = commandz('which pwdump')
#				if not e.size > 0
#					puts "Installing PWDUMP Tool....."
#					pwdump_installer
#				else
#					puts "PWDUMP appears to be installed!"
#				end
			when 'driftnet'
				e = commandz('which driftnet')
				if not e.size > 0
					puts "Installing Driftnet MiTM Tool....."
					driftnet_installer
				else
					puts "Driftnet appears to be installed!"
				end
			when 'sslstrip'
				e = commandz('which sslstrip')
				if not e.size > 0
					puts "Installing SSLSTRIP MiTM Tool....."
					sslstrip_installer
				else
					puts "SSLSTRIP appears to be installed!"
				end
			when 'evilgrade'
				e = commandz('which evilgrade')
				if not e.size > 0
					e = commandz('locate isr-evilgrade/evilgrade')
					if not e.size > 0
						puts "Installing Evilgrade....."
						Dir.chdir(INSTALL) {
							system('git clone https://github.com/infobyte/evilgrade.git')
						}
					else
						puts "Evilgrade appears to be installed!"
					end
				else
					puts "Evilgrade appears to be installed!"			
				end
			when 'macchanger'
				e = commandz('which macchanger')
				if not e.size > 0
					macchanger_installer
				else
					puts "MacChanger appears to be installed!"
				end
			when 'dsniff'
				e = commandz('which dsniff')
				if not e.size > 0
					puts "Installing DSNIFF Tool Suite....."
					dsniff_installer
				else
					puts "DSNIFF appears to be installed!"
				end
			when 'aircrack-ng'
				e = commandz('which aircrack-ng')
				if not e.size > 0
					puts "Installing Aircrack Wireless Tool Suite....."
					aircrack_installer
				else
					puts "Aircrack appears to be installed!"
				end
			when 'nbtscan'
				e = commandz('which nbtscan')
				if not e.size > 0
					puts "Installing nbtscan NetBios Scanner....."
					nbtscan_installer
				else
					puts "nbtscan appears to be installed!"
				end
			when 'netdiscover'
				e = commandz('which netdiscover')
				if not e.size > 0
					puts "Installing NetDiscover Sniffing Tool....."
					netdiscover_installer
				else
					puts "NetDiscover appears to be installed!"
				end
			when 'nmap'
				e = commandz('which nmap')
				if not e.size > 0
					puts "Installing NMAP Scanner....."
					nmap_installer
				else
					puts "NMAP appears to be installed!"
				end
			when 'dnsmap'
				e = commandz('which dnsmap')
				if not e.size > 0
					puts "Installing DNSMAP DNS Scanner....."
					dnsmap_installer
				else
					puts "DNSMAP appears to be installed!"
				end
			when 'dnsrecon'
				e = commandz('which dnsrecon')
				if not e.size > 0
					e = commandz('locate dnsrecon.py')
					if not e.size > 0
						puts "Installing DNSRECON DNS Scanner....."
						Dir.chdir(INSTALL) {
							system('git clone https://github.com/darkoperator/dnsrecon.git')
						}
					else
						puts "DNSRECON appears to be installed!"
					end
				else
					puts "DNSRECON appears to be installed!"			
				end
			when 'msfconsole'
				e = commandz('which msfconsole')
				if not e.size > 0
					puts "Installing Metasploit Community Edition, you will need to fill out a few questions in the GUI....."
					msf_installer
				else
					puts "Metasploit appears to be installed!"
				end
			when 'keimpx'
				e = commandz('locate keimpx.py')
				if not e.size > 0
					puts "Installing KEIMPX SMB Tool....."
					Dir.chdir(INSTALL) {
						system('git clone https://github.com/inquisb/keimpx.git')
					}
				else
					puts "KEIMPX appears to be installed!"
				end
			end
		end
	}
end

# DNSMAP Installer
def dnsmap_installer
	Dir.chdir(INSTALL) {
		system('wget http://dnsmap.googlecode.com/files/dnsmap-0.30.tar.gz')
		system('tar zxvf dnsmap-0.30.tar.gz')
		Dir.chdir('dnsmap-0.30') {
			system('gcc -Wall dnsmap.c -o dnsmap')
			system('chmod +x dnsmap')
			system('cp dnsmap /usr/bin/dnsmap')
		}
	}
end

# Metasploit Installer
def msf_installer
	if osm =~ /x64|x86_64/
		system('wget http://downloads.metasploit.com/data/releases/metasploit-latest-linux-x64-installer.run')
		system('chmod +x metasploit-latest-linux-x64-installer.run')
		system('sudo metasploit-latest-linux-x64-installer.run')
	else
		system('wget http://downloads.metasploit.com/data/releases/metasploit-latest-linux-x32-installer.run')
		system('chmod +x metasploit-latest-linux-x32-installer.run')
		system('sudo metasploit-latest-linux-x32-installer.run')
	end
end

# NMAP Installer
def nmap_installer
	Dir.chdir(INSTALL) {
		system('wget http://nmap.org/dist/nmap-6.25.tgz')
		system('tar zxvf nmap-6.25.tgz')
		Dir.chdir('nmap-6.25') {
			system('./configure')
			system('make')
			system('sudo make install')
		}
	}
end

# NetDiscover Network Sniffer Tool
def netdiscover_installer
	Dir.chdir(INSTALL) {
		system('wget http://nixgeneration.com/~jaime/netdiscover/releases/netdiscover-0.3-beta6.tar.gz')
		system('tar zxvf netdiscover-0.3-beta6.tar.gz')
		Dir.chdir('netdiscover-0.3-beta6') {
			system('./configure')
			system('make')
			system('sudo make install')
		}
	}
end

#NBTSCAN NetBios Scanner
def nbtscan_installer
	Dir.chdir(INSTALL) {
		system('wget http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/nbtscan-1.5.1.tar.gz')
		system('tar zxvf nbtscan-1.5.1.tar.gz')
		Dir.chdir('nbtscan-1.5.1') {
			system('./configure')
			system('make')
			system('sudo make install')
		}
	}
end

# Aircrack Wireless Tool Set Installer
def aircrack_installer
	Dir.chdir(INSTALL) {
		system('wget http://download.aircrack-ng.org/aircrack-ng-1.2-beta1.tar.gz')
		system('tar zxvf aircrack-ng-1.2-beta1.tar.gz')
		Dir.chdir('aircrack-ng-1.2-beta1') {
			system('make sqlite=true')
			system('sudo make sqlite=true install')
		}
	}
end

# DSNIFF Tool Suite for MiTM Audits and Attacks
def dsniff_installer
	Dir.chdir(INSTALL) {
		system('wget http://www.monkey.org/~dugsong/dsniff/dsniff-2.3.tar.gz')
		system('tar zxvf dsniff-2.3.tar.gz')
		Dir.chdir('dsniff-2.3') {
			system('./configure')
			system('make')
			system('sudo make install')
		}
	}
end

# MacChanger Installer
# Allows you to change MAC address which can be very handy for all sorts of scannings, mitm and wifi fun
def macchanger_installer
	if @fetch != 'nil'
		puts "Installing MacChanger and MacChanger-GTK....."
		system("sudo #{@fetch} install macchanger macchanger-gtk")
	else
		puts
		puts "No package installer available!"
		puts "Can't install MacChanger or MacChanger-GTK as a result....."
		puts
	end
end

# SSLSTRIP Installer
def sslstrip_installer
	Dir.chdir(INSTALL) {
		system("sudo #{@fetch} install python-twisted-web")
		system('wget http://www.thoughtcrime.org/software/sslstrip/sslstrip-0.9.tar.gz')
		system('tar -zxvf sslstrip-0.9.tar.gz')
		Dir.chdir('sslstrip-0.9') {
			system('sudo python ./setup.py install')
		}
	}
end

# DriftNet Installer
# Grabs Images and Audio files out of network captures. Handy for MiTM attacks...
def driftnet_installer
	Dir.chdir(INSTALL) {
		system('wget http://www.ex-parrot.com/~chris/driftnet/driftnet-0.1.6.tar.gz')
		system('tar -zxvf driftnet-0.1.6.tar.gz')
		Dir.chdir('driftnet-0.1.6') {
			system('make')
			system('sudo make install')
		}
	}
end

######################################################
#	################ MAIN ################	     #
######################################################
# Check if its a Linux system, if not all bets are off!
if RUBY_PLATFORM =~ /win|.NET/i
	puts "\n\nThis is not meant for Winblows!"
	puts "GTFO!\n"
end
os=`uname -o`
osm=`uname -m`
osv=`uname -v`
if not os =~ /linux/i
	puts "Doesn't appear to be a Linux system, can't promise anything will work....."
end

# Create our Installation Directory if it doesn't exist yet
Dir.mkdir(INSTALL) unless File.exists?(INSTALL)

# Check if we are running on Kali Linux, our intended target it was written for
# If Global paths are fixed after all dependencies are installed everything should work fine, should....
if not osv =~ /kali/i
	puts "Doesn't appear to be a Kali Linux system, can't promise everything will work flawlessly but here goes....."
end

puts "Starting Kalista Dependency Installer...."
check_depenencies
