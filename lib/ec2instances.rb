require 'fog'

module EC2SSH
	class EC2Instances

		@connection = nil

		def initialize(key, secret, region)
			@connection ||= Fog::Compute.new(
			  :provider           => 'AWS',
			  :aws_access_key_id  => key,
			  :aws_secret_access_key => secret,
			  :region 			  => region
			)
		end

		def connected?
			@connection
		end

		def ssh(options, params)
			# is `ssh user@host:port df -h; ls /` a valid ssh command?
			if params.length == 0
				raise "Please specify a HOST"
			end

			host = params[0]
			ssh_cmds = params[1..-1]

			# look up hostname
			instances = @connection.servers.all('tag:Name' => host)

			if instances.length > 1
				raise "#{instances.length} instances were found matching Name tag '#{host}'"
			elsif instances.length == 0
				raise "No instances found matching '#{host}'"
			end

			hostname = instances[0].dns_name

			cp = []
			cp << "ssh "
			cp << "#{options[:user]}@" if options[:user]
			cp << "#{hostname}"
			cp << " -p #{options[:port]}" if options[:port]
			cp << " -i #{options[:identity]}" if options[:identity]
			cp << " \"#{ssh_cmds.join(' ')}\"" unless ssh_cmds.nil? || ssh_cmds.empty?
			cmd = cp.join

			exec cmd
		end

		def list(filter=nil)
			error "connect needs to be called first" unless connected?

			instance_list = @connection.servers.all.map{ |instance| [ instance.tags['Name'], instance.dns_name ] }.sort

			instance_list.reject!{ |k,v| !k.match(filter) } unless filter.nil?

			instance_list
		end

		def generate(template, options={})
			error "connect needs to be called first" unless connected?

			instance_list = @connection.servers.all.map do |instance| 
				{ :host => instance.tags['Name'], :hostname => instance.dns_name }
			end

			filter = options[:filter]
			instance_list.reject!{ |h| !h[:host].match(filter) } unless filter.nil?

			if options[:shortnames]
				instance_list.map! { |h| h[:host] = shorten_name(h[:host]); h }
				raise "Duplicates would have been produced by short name option. Please apply a filter or remove the shortname option" unless no_duplicates?(instance_list.map{ |h| h[:host] })
			end

			cl = []
			user = options[:user]
			port = options[:port]
			identity = options[:identity]

			instance_list.sort{ |x,y| x[:host] <=> y[:host] }.each do |hsh| 
				# apply the required template to each instance
				applied = case template
				when :ssh_config
					template_ssh_config(hsh[:host], hsh[:hostname], user, identity, port)
				when :ssh_aliases
					template_ssh_alias(hsh[:host], hsh[:hostname], user, identity, port)
				end
				cl << applied
			end

			result = cl.join("\n")

			out_file = options[:output]
			if out_file
				save_to_file(out_file, result)
				puts "Saved output to #{out_file}"
			else 
				puts result
			end
		end

		def template_ssh_alias(host, hostname, user, identity, port)
			t = []
			t << "alias ssh#{host}='"
			t << "#{user}@" if user
			t << "#{hostname}"
			t << " -p #{port}" if port
			t << " -i #{identity}" if identity
			t << "'"
			t.join
		end

		def template_ssh_config(host, hostname, user, identity, port)
			t = []
			t << "Host #{host}"
			t << "\tHostName #{hostname}"
			t << "\tUser #{user}" if user
			t << "\tIdentityFile #{identity}" if identity
			t << "\tPort #{port}" if port
			t << ""
			t.join("\n")
		end

		def shorten_name(name)
			name.split('-').map{ |p| p=p[0,1] }.join
		end

		def save_to_file(name, contents)
			File.open(name, 'w') do |f|
				f.write(contents)
			end
		end

		def no_duplicates?(arr)
			arr.uniq.length == arr.length
		end

	end
end
