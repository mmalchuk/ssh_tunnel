#
# Cookbook Name:: ssh_tunnel
# Recipe:: default
#
# Copyright 2012, Maksim Malchuk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# install ssh package
package "ssh" do
	action :install
end

# create some dir's
directory "/var/run/ssh_tunnel" do
	owner "root"
	group "root"
	mode "0751"
end
directory "/etc/ssh_tunnel" do
	owner "root"
	group "root"
	mode "0751"
end

# process each tunnel
node[:ssh_tunnel][:list].each do |tun|

	Chef::Log.info "Prcessing tunnel: #{tun[:name]}"

	if tun[:enabled] == true

		# convert some attr's to local var's
		gw_port = tun[:config][:gw_port].empty? ? '22' : tun[:config][:gw_port]
		gw_user = tun[:config][:gw_user].empty? ? 'root' : tun[:config][:gw_user]

		local = tun[:config][:loc_addr].empty? ? tun[:config][:loc_port] : tun[:config][:loc_addr] + ':' + tun[:config][:loc_port]
		remote = tun[:config][:rem_addr] + ':' + tun[:config][:rem_port]

		pattern = local + ':' + remote

		Chef::Log.info "Prcessing pattern: #{pattern}"

		# create private key file
		template "/etc/ssh_tunnel/#{pattern}.pem" do
			source "default.pem.erb"
			owner "root"
			group "root"
			mode "0600"
			variables(
				:private_key => tun[:config][:private_key]
			)
		end

		# service
		# /usr/bin/ssh -f -N -i #{gw_cert} -L #{local}:#{remote} -p #{gw_port } #{gw_user}@#{gw_addr}

		service "ssh_tunell" do

			start_command "/usr/bin/ssh -q -f -N -i #{tun[:config][:gw_cert]}/#{pattern}.pem -L #{pattern} -p #{gw_port } #{gw_user}@#{tun[:config][:gw_addr]} && echo `ps aux | grep 'ssh.*#{pattern}' | grep -v grep | awk '{print $2}'` >'/var/run/ssh_tunnel/#{pattern}.pid'"

			stop_command "kill `cat '/var/run/ssh_tunnel/#{pattern}.pid'` && rm -f '/var/run/ssh_tunnel/#{pattern}.pid' >/dev/null 2>&1"

			pattern "#{pattern}"
			supports [ :start, :stop ]

			if tun[:action] == 'start'
				action [ :start ]
			elsif tun[:action] == 'restart'
				action [ :stop ]
				action [ :start ]
			else
				action [ :stop ]
			end

		end

	end

end

