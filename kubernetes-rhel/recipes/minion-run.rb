include_recipe 'kubernetes-rhel::minion-setup'
include_recipe 'kubernetes-rhel::flanneld'
include_recipe 'kubernetes-rhel::docker-engine'

bash 'start_flanneld_and_docker' do
	user 'root'
	code <<-EOH
	systemctl daemon-reload	
	service flanneld start
	service docker start
	EOH
	notifies :start, 'service[kubelet]', :delayed
	notifies :start, 'service[kube-proxy]', :delayed
end

service "kubelet" do
	action :nothing
end

service "kube-proxy" do
	action :nothing
end
