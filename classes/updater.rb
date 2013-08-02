# This is our Updater Class
# This should house anything related to Updating the tool itself or anything used within it
# If you add, just update the usage and u_shell function to make available

class Updater
	def show_update_usage
		puts "List of available commands and general description".light_yellow + ": ".white
		puts "\tcls".light_yellow + "       => ".white + "Clear Screen".light_yellow
		puts "\thelp ".light_yellow + "     => ".white + "Display this Help Menu".light_yellow
		puts "\tback ".light_yellow + "     => ".white + "Return to Main Menu".light_yellow
		puts "\texit ".light_yellow + "     => ".white + "Exit Completely".light_yellow
		print_line("")
		puts "\tmsf ".light_yellow + "      => ".white + "Update Metasploit Framework".light_yellow
		print_line("")
	end

	def u_shell
		prompt = "(Update)> "
		while line = Readline.readline("#{prompt}", true)
			cmd = line.chomp
			case cmd
				when /^clear|^cls|^banner/i
					cls
					banner
					u_shell
				when /^help|^h$|^ls$/i
					show_update_usage
					u_shell
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
				when /^msf|^metasploit/i
					msf_updater
					u_shell
				else
					cls
					print_line("")
					print_error("Oops, Didn't quite understand that one")
					print_error("Please Choose a Valid Option From Menu Below Next Time.....")
					print_line("")
					show_updates_usage
					u_shell
				end
		end
	end

	# Metasploit Framework Updater
	def msf_updater
		print_status("Launching Metasploit Updater, hang tight......")
		system("#{MSFPATH}/msfupdate 2> /dev/null")
		print_status("")
		print_status("OK, should be all set now!")
		print_status("")
		print_caution("Press ENTER to Continue......")
		fuqoff=gets
	end
end
