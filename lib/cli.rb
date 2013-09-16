require 'thor'
require 'ec2instances'

module EC2SSH
	class CLI < Thor

		default_task :show_help

		desc "", "Shows the program help" 
		def show_help
			# show program help banner
			puts <<-HELP
				This program assumes that all your EC2 instances have the NAME tag set. If you do not have this set, this will not work for you.
			HELP
			# now tack on thors help
			help
		end

		desc "list", "Print a list of all the hosts"
		option :aws_key, :required => true, :aliases => "-k", :desc => "Your AWS secret key"
		option :aws_secret, :required => true, :aliases => "-s", :desc => "Your AWS secret"
		option :region, :required => true, :aliases => "-r", :desc => "The AWS region you want to connect to"
		option :filter, :aliases => "-f", :default => nil, :desc => "Only print hosts that match the given regex"
		def list
			print_table ec2instances(options).list(options[:filter])
		end

		desc "ssh_config", "Generate an ssh config file"
		option :aws_key, :required => true, :aliases => "-k", :desc => "Your AWS secret key"
		option :aws_secret, :required => true, :aliases => "-s", :desc => "Your AWS secret"
		option :region, :required => true, :aliases => "-r", :desc => "The AWS region you want to connect to"
		option :filter, :aliases => "-f", :default => nil, :desc => "Only print hosts that match the given regex"
		option :output, :aliases => "-o", :desc => "Save the generated configuration to a file"
		option :user, :aliases => "-u", :desc => "The user to set"
		option :port, :aliases => "-p", :desc => "The port to use"
		option :identity, :aliases => "-i", :desc => "Sets an identity file to use"
		option :shortnames, :desc => "Split names on '-' and take the first letter from each part to be the name. Will error if duplicate names would be produced. eg production-app-1 would become pa1"
		def ssh_config
			begin
				ec2instances(options).generate(:ssh_config, options)
			rescue Exception => e
				#error e.message
				puts e
			end
		end

		desc "ssh_aliases", "Generate an ssh alias list"
		option :aws_key, :required => true, :aliases => "-k", :desc => "Your AWS secret key"
		option :aws_secret, :required => true, :aliases => "-s", :desc => "Your AWS secret"
		option :region, :required => true, :aliases => "-r", :desc => "The AWS region you want to connect to"
		option :filter, :aliases => "-f", :default => nil, :desc => "Only print hosts that match the given regex"
		option :output, :aliases => "-o", :desc => "Save the generated configuration to a file"
		option :user, :aliases => "-u", :desc => "The user to set"
		option :port, :aliases => "-p", :desc => "The port to use"
		option :identity, :aliases => "-i", :desc => "Sets an identity file to use"
		option :shortnames, :desc => "Split names on '-' and take the first letter from each part to be the name. Will error if duplicate names would be produced. eg production-app-1 would become pa1"
		def ssh_aliases
			begin
				ec2instances(options).generate(:ssh_aliases, options)
			rescue Exception => e
				error e.message
			end
		end

		desc "ssh [HOST]", "ssh into the instance where the Name tag matches the HOST"
		option :aws_key, :required => true, :aliases => "-k", :desc => "Your AWS secret key"
		option :aws_secret, :required => true, :aliases => "-s", :desc => "Your AWS secret"
		option :region, :required => true, :aliases => "-r", :desc => "The AWS region you want to connect to"
		option :user, :aliases => "-u", :desc => "The user to set"
		option :port, :aliases => "-p", :desc => "The port to use"
		option :identity, :aliases => "-i", :desc => "Sets an identity file to use"
		def ssh(*params)
			ec2instances(options).ssh(options, params)
		end

		no_commands do
			def ec2instances(options)
				EC2Instances.new(options[:aws_key], options[:aws_secret], options[:region])
			end
		end

	end
end