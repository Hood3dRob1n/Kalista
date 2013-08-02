#!/usr/bin/env ruby
#
# xdb.rb
# Search Tool for the Exploit-DB Archive
# By: Hood3dRob1n
#
# I was unable to cleanly parse the CSV file myself
# so instead I did my best to correct and put in arrays
# then loop through with a weighted search. Essentially we
# just narrow things down based on logical search order.
# Search Order: platform=>type=>author=>port=>searchterm
# It works well for me, and I added options to help keep updated
# or set you up if you dont have the archives (4 non-kali users)
#
# Link for Manual Archive Setup: http://www.exploit-db.com/archive.tar.bz2
# Just untar it and edit the CSV variable below to point at the files.csv
#
# Feedback, questions or suggestions: hood3drob1n@gmail.com
#

######## Exploit-DB Path #############
CSV='/usr/share/exploitdb/files.csv' #
######################################

###### STD GEMS ######
require 'optparse'   #
require 'net/http'   #
require 'fileutils'  #
#### NON-STD GEMS ####
require 'rubygems'   #
require 'colorize'   #
######################

#Catch System Interupts
trap("SIGINT") {puts "\n\nWARNING! CTRL+C Detected, Disconnecting from DB and exiting program....".red; exit 666;}

#Clear Terminal
def cls
	system('clear')
end

def db_exists
	if (File.directory?('platforms') and File.exists?('files.csv')) or (File.directory?("#{CSV.split("/")[0..-2].join("/")}/platforms") and File.exists?(CSV))
		if File.exists?(CSV)
			$csv=CSV
		else
			$csv="#{Dir.pwd}/files.csv"
		end
		$csvdir="#{$csv.split("/")[0..-2].join("/")}/platforms"
		puts "[*] ".light_green + "Found archive files: #{$csvdir.split("/")[0..-2].join("/")} ".white
	else
		puts "[*] ".light_red + "Can't Find archive files!".white
		puts "[*] ".light_red + "We can't run a search without the archive files....".white
		puts "[*] ".light_yellow + "Do you want to try to download the archive files (Y/N)?".white
		answer=gets.chomp
		if answer.upcase='Y' or answer.upcase='YES'
			fetch_db
			if (File.directory?('platforms') and File.exists?('files.csv'))
				$csv="#{Dir.pwd}/files.csv"
				$csvdir="#{$csv.split("/")[0..-2].join("/")}/platforms"
				puts "[*] ".light_green + "Found new archive files: #{$csvdir.split("/")[0..-2].join("/")} ".white
			else
				puts "[*] ".light_red
				puts "[*] ".light_red + "Sorry still not finding shit, try again or setup manually.....".white
				puts "[*] ".light_red
				puts
				exit 666;
			end
		else
			puts "[*] ".light_red
			puts "[*] ".light_red + "OK, have a good one.....".white
			puts "[*] ".light_red
			puts
			exit 666;
		end
	end
end

# Fetch latest copy of the exploit-db archive
def fetch_db
	puts "[*] ".light_green + "Fetching the latest exploit-db archive file.....".white
	############### DOWNLOAD ###############
	Net::HTTP.start("www.exploit-db.com") do |http|
		begin
			file = open("archive.tar.bz2", 'wb')
			http.request_get('/' + URI.encode("archive.tar.bz2"),  { 'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; rv:12.0) Gecko/20120403211507 Firefox/12.0' } ) do |response|
				response.read_body do |segment|
					file.write(segment)
				end
			end
		rescue Timeout::Error => e
			puts "[*] ".light_red + "Connection Timeout Error during archive download!".white
			puts "[*] ".light_red + "Not horribly uncommon - Try again or set things up manually, sorry.....".white
			return false
		ensure
			file.close
		end
	end
	puts "[*] ".light_green + "Archive Download Complete!".white
	puts "[*] ".light_blue + "Extracting archive files, just another minute...".white
	system("tar xvf archive.tar.bz2")
	begin
		FileUtils.chmod(0755, 'files.csv') #override these files...
	rescue Errno::ENOENT
		puts "[*] ".light_red +  "Extract failed, unable to extract full archive!".white
		puts "[*] ".light_red +  "You will need to try again later as can happen regularly enough.....".white
		puts "[*] ".light_red +  "If you can get and create things manually you can re-run script fine!".white
		puts "[*] ".light_red +  "Sorry.................>\n\n".white
		exit 666;
	end
	# chmod files as needed....
	# chmod +x yourself when you actualy need to run them :p
	# search recursively from current dir and chmod as needed
	system("find #{Dir.pwd} -type d -print0 | xargs -0 chmod 755")
	# use xargs instead of exec option to avoid spawning more subprocesses
	system("find #{Dir.pwd} -type f -print0 | xargs -0 chmod 666")
	puts "[*] ".light_green + "Archive is now ready!".white 
end

# Search based on initial full CSV results set against platform
# This initializes our array to perform further searchs
# We wind down narrowing results as we go
# Due to poor CSV consistency this is the best I could come up with
def search_platform(searchterm)
	platform_results=[]
	IO.foreach("#{$csvdir.split("/")[0..-2].join("/")}/files.csv") do |line|
		line = line.unpack('C*').pack('U*') if !line.valid_encoding? #Thanks Stackoverflow :)
		if line =~ /(\".+,.+\")/ #Deal with annoying commans within quotes as they shouldn't be used to split on (ahrg)
			crappy_csv_line = $1
			not_as_crappy_csv_line = crappy_csv_line.sub(",", "")
			workable_csv_line = line.sub!("#{crappy_csv_line}","#{not_as_crappy_csv_line}").split(",")
		else
			workable_csv_line = line.split(",")
		end
		foo = workable_csv_line - workable_csv_line.slice(0,5)
		foobar = foo - workable_csv_line.slice(-1, 1) - workable_csv_line.slice(-2, 1)
		if searchterm == 'nil'
			platform_results << line
		else
			if "#{foobar.join(",")}" =~ /#{searchterm}/i
				platform_results << line
			end
		end
	end
	return platform_results
end

# Search based on TYPE
# Returns an array with the results
def search_type(exploits_array, searchterm)
	search_results=[]
	exploits_array.each do |line|
		line = line.unpack('C*').pack('U*') if !line.valid_encoding?
		if line =~ /(\".+,.+\")/ 
			crappy_csv_line = $1
			not_as_crappy_csv_line = crappy_csv_line.sub(",", "")
			workable_csv_line = line.sub!("#{crappy_csv_line}","#{not_as_crappy_csv_line}").split(",")
		else
			workable_csv_line = line.split(",")
		end
		foo = workable_csv_line - workable_csv_line.slice(0,5)
		foobar = foo - workable_csv_line.slice(-1, 1) - workable_csv_line.slice(-2, 1)
		if searchterm == 'nil'
			search_results << line
		else
			if not workable_csv_line[-2].nil?
				if "#{workable_csv_line[-2].downcase}" =~ /#{searchterm}/i
					search_results << line
				end
			end
		end
	end
	return search_results
end

# Search based on Author
# Returns an array with the results
def search_author(exploits_array, searchterm)
	search_results=[]
	exploits_array.each do |line|
		line = line.unpack('C*').pack('U*') if !line.valid_encoding?
		if line =~ /(\".+,.+\")/ 
			crappy_csv_line = $1
			not_as_crappy_csv_line = crappy_csv_line.sub(",", "")
			workable_csv_line = line.sub!("#{crappy_csv_line}","#{not_as_crappy_csv_line}").split(",")
		else
			workable_csv_line = line.split(",")
		end
		foo = workable_csv_line - workable_csv_line.slice(0,5)
		foobar = foo - workable_csv_line.slice(-1, 1) - workable_csv_line.slice(-2, 1)
		if searchterm == 'nil'
			search_results << line
		else
			if not workable_csv_line[4].nil?
				if "#{workable_csv_line[4].downcase}" =~ /#{searchterm}/i
					search_results << line
				end
			end
		end
	end
	return search_results
end

# Search based on PORT
# Returns an array with the results
def search_port(exploits_array, searchterm)
	search_results=[]
	exploits_array.each do |line|
		line = line.unpack('C*').pack('U*') if !line.valid_encoding?
		if line =~ /(\".+,.+\")/ 
			crappy_csv_line = $1
			not_as_crappy_csv_line = crappy_csv_line.sub(",", "")
			workable_csv_line = line.sub!("#{crappy_csv_line}","#{not_as_crappy_csv_line}").split(",")
		else
			workable_csv_line = line.split(",")
		end
		foo = workable_csv_line - workable_csv_line.slice(0,5)
		foobar = foo - workable_csv_line.slice(-1, 1) - workable_csv_line.slice(-2, 1)
		if searchterm == 'nil'
			search_results << line
		else
			if not workable_csv_line[-1].nil?
				if "#{workable_csv_line[-1].downcase}" =~ /#{searchterm}/i
					search_results << line
				end
			end
		end
	end
	return search_results
end

# Search based on SEARCH Term
# Returns an array with the results
def search_search(exploits_array, searchterm)
	search_results=[]
	exploits_array.each do |line|
		line = line.unpack('C*').pack('U*') if !line.valid_encoding?
		if searchterm == 'nil'
			search_results << line
		else
			if line =~ /#{searchterm}/i
				search_results << line
			end
		end
	end
	return search_results
end

# Parse remaining exploits in array
# Print out the search results for user
def print_results(remaining_exploits, log=false, q=false)
	rezsize = remaining_exploits.length
	if q == true
		puts "[*] ".light_green + "Saved #{rezsize} Result(s) to: #{@out}".white
	else
		if log
			puts "[*] ".light_green + "Saved #{rezsize} Result(s) to: #{@out}".white
			puts "[*] ".light_green + "Displaying Result(s):".white
		else
			puts "[*] ".light_green + "Found #{rezsize} Result(s):".white
		end
	end
	sleep(2)
	remaining_exploits.each do |line|
		if line =~ /(\".+,.+\")/ #Deal with annoying commans within quotes as they shouldn't be used to split on (ahrg)
			crappy_csv_line = $1
			not_as_crappy_csv_line = crappy_csv_line.sub(",", "")
			workable_csv_line = line.sub!("#{crappy_csv_line}","#{not_as_crappy_csv_line}").split(",")
		else
			workable_csv_line = line.split(",")
		end
		foo = workable_csv_line - workable_csv_line.slice(0,5)
		foobar = foo - workable_csv_line.slice(-1, 1) - workable_csv_line.slice(-2, 1)
		if log == true
			outputz = File.open("#{@out}", 'a+')
			outputz.puts "Description: #{workable_csv_line[2]}"
			outputz.puts "Location: #{$csvdir}/#{workable_csv_line[1].sub('/platforms', '')}"
			outputz.puts "Exploit ID: #{workable_csv_line[0]}"
			outputz.puts "Platform: #{foobar.join(",")}"
			outputz.puts "Type: #{workable_csv_line[-2]}"
			if not "#{workable_csv_line[-1].chomp}".to_i == 0
				outputz.puts "Port: #{workable_csv_line[-1].chomp}"
			end
			outputz.puts "Author: #{workable_csv_line[4]}"
			outputz.puts "Submit: #{workable_csv_line[3]}"
			outputz.puts
			outputz.close
		end
		if q != true
			puts "[*] ".light_green + "Description: ".light_red + "#{workable_csv_line[2]}".white
			puts "[*] ".light_green + "Location: ".light_red + "#{$csvdir}/#{workable_csv_line[1].sub('/platforms', '')}".white
			puts "[*] ".light_green + "Exploit ID: ".light_red + "#{workable_csv_line [0]}".white
			puts "[*] ".light_green + "Platform: ".light_red + "#{foobar.join(",")}".white
			puts "[*] ".light_green + "Type: ".light_red + "#{workable_csv_line[-2]}".white
			if not "#{workable_csv_line[-1].chomp}".to_i == 0
				puts "[*] ".light_green + "Port: ".light_red + "#{workable_csv_line[-1].chomp}".white
			end
			puts "[*] ".light_green + "Author: ".light_red + "#{workable_csv_line[4]}".white
			puts "[*] ".light_green + "Submit: ".light_red + "#{workable_csv_line[3]}".white
			puts "[*] ".light_blue
		end
	end
	puts "[*] ".light_blue + "Search Complete!".white
	puts "[*] ".light_blue + "Hope you found what you needed....".white
	puts "[*] ".light_blue + "Good Bye!".white
	puts "[*] ".light_blue
end

# Update the exploit-db to latest archive
def update_db
	if (File.directory?('platforms') and File.exists?('files.csv')) or (File.directory?("#{CSV.split("/")[0..-2].join("/")}/platforms") and File.exists?(CSV))
		if File.exists?(CSV)
			$csv=CSV
		else
			$csv="#{Dir.pwd}/files.csv"
		end
		$csvdir="#{$csv.split("/")[0..-2].join("/")}/platforms"
		puts "[*] ".light_blue + "Updating Database.....".white
		FileUtils.mv($csv, "#{$csv}.bk") if File.exists?($csv)
		FileUtils.mv($csvdir, "#{$csvdir}_BK") if File.directory?($csvdir)
		db_exists
		if (File.directory?($csvdir) and File.exists?($csv))
			puts "[*] ".light_good + "Archive has been updated!".white
			puts "[*] ".light_blue + "Removing old backups....".white
			FileUtils.rm_rf("#{$csvdir}_BK")
			FileUtils.rm_f("#{$csv}.bk")
			puts "[*] ".light_good
			puts "[*] ".light_good + "Update Complete!".white
			puts "[*] ".light_good
			exit 69;
		else
			puts "[*] ".light_red
			puts "[*] ".light_red + "Problem with update!".white
			puts "[*] ".light_red + "Backups were made but need to be re-named again....".white
			puts "[*] ".light_red + "Try again or update manually....".white
			puts "[*] ".light_red
			exit 666;
		end
	else
		puts "[*] ".light_red
		puts "[*] ".light_red + "Archive files NOT found!".white
		puts "[*] ".light_red + "You can't run an update without archive files....".white
		puts "[*] \n\n".light_red
		exit 666;
	end
end

########### MAIN ###########
options = {}
optparse = OptionParser.new do |opts| 
	opts.banner = "Usage:".light_green + "#{$0} ".white + "[".light_green + "OPTIONS".white + "]".light_green
	opts.separator ""
	opts.separator "EX:".light_green + " #{$0} --update".white
	opts.separator "EX:".light_green + " #{$0} -T webapps -S vBulletin".white
	opts.separator "EX:".light_green + " #{$0} --search=\"Linux Kernel 2.6\"".white
	opts.separator "EX:".light_green + " #{$0} -A \"JoinSe7en\" -S \"MyBB\"".white
	opts.separator "EX:".light_green + " #{$0} -T remote -S \"SQL Injection\"".white
	opts.separator "EX:".light_green + " #{$0} -P linux -T local -S UDEV -O search_results.txt".white
	opts.separator ""
	opts.separator "Options: ".light_green
	#setup argument options....
	opts.on('-U', '--update', "\n\tUpdate Exploit-DB Working Archive to Latest & Greatest".white) do |host|
		options[:method] = 0
	end
	opts.on('-P', '--platform <PLATFORM>', "\n\tSystem Platform Type, options include:
sco, bsdi/x86, openbsd, lin/amd64, plan9, bsd/x86, openbsd/x86, hardware, bsd, unix, lin/x86-64, netbsd/x86, linux, solaris, ultrix, arm, php, solaris/sparc, osX, os-x/ppc, cfm, generator, freebsd/x86, bsd/ppc, minix, unixware, freebsd/x86-64, cgi, hp-ux, multiple, win64, tru64, jsp, novell, linux/mips, solaris/x86, aix, windows, linux/ppc, irix, QNX, lin/x86, win32, linux/sparc, freebsd, asp, sco/x86".white) do |platform|
		options[:platform] = platform.downcase.chomp
		options[:method] = 1
	end
	opts.on('-T', '--type <TYPE>', "\n\tType of Exploit, options include:\n\tDoS, Remote, Local, WebApps, Papers or Shellcode".white) do |type|
		options[:type] =  type.downcase.chomp
		options[:method] = 1
	end
	opts.on('-A', '--author <NAME>', "\n\tRun Lookup based on Author Username".white) do |author|
		options[:author] = author.downcase.chomp
		options[:method] = 1
	end
	opts.on('-S', '--search <SEARCH_TERM>', "\n\tSearch Term to look for in Exploit-DB Working Archive".white) do |search|
		options[:search] = search.downcase.chomp
		options[:method] = 1
	end
	opts.on('-O', '--output <OUTPUT_FILE>', "\n\tOutput File to Write Search Results to".white) do |output|
		@out = output.chomp
		options[:log] = true
	end
	opts.on('-q', '--quiet', "\n\tSilence Output to Terminal for Search Results (when logging output)".white) do |output|
		options[:q] = true
	end
	opts.on('-h', '--help', "\n\tHelp Menu".white) do 
		cls 
		puts
		puts "Exploit-DB Archive Search Tool".white
		puts "By: ".white + "Hood3dRob1n".light_green
		puts
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
		puts "Missing or Unknown Options: ".red
		puts optparse
		exit
	end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
	cls
	puts $!.to_s.red
	puts
	puts optparse
	puts
	exit 666;
end
puts
puts "Exploit-DB Archive Search Tool".white
puts "By: ".white + "Hood3dRob1n".light_green
puts
# Update or Check|Build Archive
if options[:method] == 0
	update_db
else
	db_exists
end

# Set Cookie Crumb in Results File to duplicate
if options[:log]
	outputz = File.open("#{@out}", 'w+')
	cmd="#{$0} "
	if options[:platform]
		cmd += "-P #{options[:platform]} "
	end
	if  options[:type]
		cmd += "-T #{options[:type]} "
	end
	if options[:author]
		cmd += "-A #{options[:author]} "
	end
	if options[:port]
		cmd += "--port #{options[:port]} "
	end
	if options[:search]
		cmd += "-S #{options[:search]} "
	end
	outputz.puts
	outputz.puts cmd
	outputz.puts
	outputz.close
end

#Make we have search values or set wildcards
if not options[:platform]
	options[:platform] = ''
end
if not options[:type]
	options[:type] = ''
end
if not options[:author]
	options[:author] = ''
end
if not options[:port]
	options[:port] = ''
end
if not options[:search]
	options[:search] = ''
end

# Run the search based on what was passed from user
platform_results = search_platform(options[:platform])
type_results = search_type(platform_results, options[:type])
author_results = search_author(type_results, options[:author])
port_results = search_port(author_results, options[:port])
results = search_search(port_results, options[:search])
if options[:log]
	if options[:q]
		print_results(results, log=true, q=true)
	else
		print_results(results, log=true, q=false)
	end
else
	print_results(results, log=false, q=false)
end
#EOF
