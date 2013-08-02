#!/usr/bin/env ruby
#
# Ruby Shell-Storm API
# By: Hood3dRob1n
#
# Source: http://pastebin.com/wQRYCSxK
#
# Search and display all shellcodes in shell-storm database
# I just wanted to make my own version in Ruby for fun :p
# Many Thanks to Jonathan Salwan for his hard work and great site!
#
# Usage: 
# ./shell-storm-api.rb --search <term>
# ./shell-storm-api.rb --display <id>
#
###### STD GEMS ######
require 'net/http'   #
require 'optparse'   #
#### NON-STD GEMS ####
require 'rubygems'   #
require 'text-table' #
######################
#
#Add some color without extra gems
RS="\033[0m"    # reset
HC="\033[1m"    # hicolor
FRED="\033[31m" # foreground red
FGRN="\033[32m" # foreground green
FWHT="\033[37m" # foreground white
FCYN="\033[36m" # foreground cyan
#
# Catch System Interupts
trap("SIGINT") { puts "#{HC}#{FRED}\n\nWARNING#{FWHT}!#{FRED} CTRL#{FWHT}+#{FRED}C Detected#{FWHT} => #{FRED}Closing Down#{FWHT}....#{RS}"; exit 666; }
#
# Clear Terminal
def cls
	if RUBY_PLATFORM =~ /win32/
		system('cls')
	else
		system('clear')
	end
end
#
# Simple Banner
def banner
	puts
	puts "#{HC}#{FGRN}Shell-Storm Ruby API"
	puts "By#{FWHT}: Hood3dRob1n#{RS}"
	puts
end
#
# Run Search & Display Results in Table
# Search is run in against all lowercase on server side
# Need to .downcase our search before sending or results fail!
def scsearch(squery)
	http = Net::HTTP.new("shell-storm.org", 80)
	req = Net::HTTP::Get.new("/api/?s=#{squery.downcase}", {'User-Agent' => 'Shell-Storm Ruby API - Search'})
	res = http.request(req)
	case res
	when Net::HTTPSuccess then
		t=[ [ "Author", 'Platform', 'Description', 'ID' ] ]
		res.body.split("\n").each do |entry|
			show = entry.split("::::")
			t << [ "#{show[0]}", "#{show[1]}", "#{show[2]}", "#{show[3]}" ]
		end
		table = t.to_table(:first_row_is_head => true)
		puts "#{HC}#{FGRN}" + table.to_s + "#{RS}"
	else
		puts "#{HC}#{FRED}Seems we made a bad request somehow#{FWHT}....#{RS}"
		puts res.value
	end
end
#
# Display Shell Code by ID
def scdisplay(id)
	http = Net::HTTP.new("shell-storm.org", 80)
	req = Net::HTTP::Get.new("/shellcode/files/shellcode-#{id}.php", {'User-Agent' => 'Shell-Storm Ruby API - Display'})
	res = http.request(req)
	case res
	when Net::HTTPSuccess then
		puts "#{HC}#{FGRN}[#{FWHT}*#{FGRN}] Displaying#{FWHT}: http://shell-storm.org/shellcode/files/shellcode-#{id}.php#{FCYN}"
		puts res.body.split("\n")[7..-13].join("\n").gsub('&quot;', '"').gsub('&gt;', '>').gsub('&lt;', '<').gsub('&amp;', '&')
		puts "#{RS}"
	else
		puts "#{HC}#{FRED}Seems we made a bad request somehow#{FWHT}....#{RS}"
		puts res.value
	end
end
# Parse User Options & Arguments and Run Accordingly...
options = {}
optparse = OptionParser.new do |opts| 
	opts.banner = "#{HC}#{FGRN}Usage#{FWHT}: #{$0} #{FGRN}[ #{FWHT}OPTIONS #{FGRN}] [ #{FWHT}ARGS #{FGRN}]"
	opts.separator ""
	opts.separator "EX#{FWHT}: #{$0} --search arm#{FGRN}"
	opts.separator "EX#{FWHT}: #{$0} --display 660#{FGRN}"
	opts.separator ""
	opts.separator "Options#{FWHT}: #{RS}"
	opts.on('-S', '--search TERM', "#{HC}#{FWHT}\n\tSearch Term to check against Shell-Storm#{RS}") do |squery|
		options[:method] = 1
		options[:search] = squery.chomp
	end
	opts.on('-D', '--display ID', "#{HC}#{FWHT}\n\tDisplay Shell Code for ID#{RS}") do |code_id|
		options[:method] = 2
		options[:display] = code_id
	end
	opts.on('-h', '--help', "#{HC}#{FWHT}\n\tHelp Menu#{RS}") do 
		cls
		banner
		puts opts
		puts
		exit 69
	end
end
begin
	foo = ARGV[0] || ARGV[0] = "-h"
	optparse.parse!
	mandatory = [:method]
	missing = mandatory.select{ |param| options[param].nil? }
	if not missing.empty?
		puts "#{HC}#{FRED}Missing option(s)#{FWHT}: #{missing.join(', ')}#{RS}"
		puts optparse
		exit
	end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
	cls
	banner
	puts "#{HC}#{FRED}#{$!.to_s}#{RS}"
	puts optparse
	puts
	exit 666;
end
banner
if options[:method].to_i == 1
	scsearch(options[:search])
else
	scdisplay(options[:display])
end
