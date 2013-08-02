# This is our WiFi Class
# This should house anything related to WiFi Scanning & Hacking
# If you add, just update the usage and w_shell function to make available

class WiFiSploit
	def show_wifi_usage
		puts "List of available commands and general description".light_yellow + ": ".white
		puts "\tcls".light_yellow + "         => ".white + "Clear Screen".light_yellow
		puts "\thelp ".light_yellow + "       => ".white + "Display this Help Menu".light_yellow
		puts "\tback ".light_yellow + "       => ".white + "Return to Main Menu".light_yellow
		puts "\texit ".light_yellow + "       => ".white + "Exit Completely".light_yellow
		print_line("")
		print_error("")
		print_error("WiFi Section is still in the works, sorry....")
		print_error("Chat/Contribute: hood3drob1n@gmail.com")
		print_error("")
	end

	def w_shell
		prompt = "(WiFi)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^clear|^cls|^banner/i
					cls
					banner
					w_shell
				when /^help|^h$|^ls$/i
					show_wifi_usage
					w_shell
				when /^exit|^quit/i
					print_line("")
					print_error("OK, exiting Kalista....")
					print_line("")
					exit 69;
				when /^back|^main/i
					print_line("")
					print_error("OK, back to the Main Menu....")
					print_line("")
					$framework.core_shell
				else
					cls
					print_line("")
					print_error("Oops, Didn't quite understand that one")
					print_error("Please Choose a Valid Option From Menu Below Next Time.....")
					print_line("")
					show_wifi_usage
					w_shell
				end
		end
	end
end
