include_recipe 'kubernetes-rhel::master-setup'
include_recipe 'kubernetes-rhel::flanneld' 
#version newer than 0.5.2 won't pass etcd URL with BA

# ignore this if you don't want flanneld working on master node
#service 'flanneld' do
#	action :start
#end
bash 'start_flanneld' do
	user 'root'
	code <<-EOH	
	systemctl daemon-reload
	service flanneld start
	EOH
	notifies :start, 'service[kube-apiserver]', :immediately
end

service "kube-apiserver" do
	action :nothing
	notifies :start, 'service[kube-scheduler]', :immediately
	notifies :start, 'service[kube-controller-manager]', :immediately
end

service "kube-scheduler" do
	action :nothing
end

service "kube-controller-manager" do
	action :nothing
end
