private_ip = node['opsworks']['instance']['private_ip']
hostname = node['opsworks']['instance']['hostname']
members = Array.new

node['opsworks']['layers']['etcd']['instances'].each do |inst|
	members << inst[0]+"=http://"+inst[1][:private_ip]+":7001"
end

service 'etcd' do
	action :stop
	notifies :run, "bash[update_new_setting]", :delayed
end

bash "update_new_setting" do
	user 'root'
	
	code <<-EOH
	sed -i '33c \\\t\\t-initial-advertise-peer-urls http://#{private_ip}:7001 -listen-peer-urls http://#{private_ip}:7001 -listen-client-urls http://#{private_ip}:4001,http://127.0.0.1:4001 -advertise-client-urls http://#{private_ip}:4001 -initial-cluster-token etcd-cluster-#{node[:token]} -initial-cluster #{members.join(',')} -initial-cluster-state new \\\\' /etc/init.d/etcd
	service etcd start
	EOH
	action :nothing
end

