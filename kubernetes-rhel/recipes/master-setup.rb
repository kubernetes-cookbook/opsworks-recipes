include_recipe 'kubernetes-rhel::k8s-setup'

etcd_endpoint="http://root:#{node['etcd']['password']}@#{node['etcd']['elb_url']}:80"

execute 'set_flanneld_CIDR_at_ETCD' do
	command "curl -L #{etcd_endpoint}/v2/keys/coreos.com/network/config -XPUT -d value=\"{\\\"Network\\\": \\\"#{node['kubernetes']['cluster_cidr']}\\\" }\""
end

#package 'kubernetes-master', 'kubernetes-client'
bash "master-file-copy" do
	user 'root'
	cwd '/tmp//kubernetes/server/kubernetes/server/bin'
	code <<-EOH
	mkdir /etc/kubernetes
	cp kubectl kube-apiserver kube-scheduler kube-controller-manager /usr/local/bin/
	EOH
end

# add config files
template "/etc/kubernetes/apiserver" do
	mode "0644"
	owner "root"
	source "master-apiserver.conf.erb"
	variables({
		:etcd_server => etcd_endpoint,
		:ba_path => "/opt/ba_file",
		:cluster_cidr => node['kubernetes']['cluster_cidr'],
		:cluster_name => "happy-k8s-cluster"
	})
	subscribes :create, "bash[master-file-copy]", :immediately
	action :nothing
end

template "/etc/kubernetes/config" do
	mode "0644"
	owner "root"
	source "master-conf.erb"
	subscribes :create, "bash[master-file-copy]", :immediately
	action :nothing
end

# add service init files
template "/usr/lib/systemd/system/kube-apiserver.service" do
	mode "0644"
	owner "root"
	source "kube-apiserver.service.erb"
	subscribes :create, "bash[master-file-copy]", :immediately
	action :nothing
end
template "/usr/lib/systemd/system/kube-controller-manager.service" do
	mode "0644"
	owner "root"
	source "kube-controller-manager.service.erb"
	subscribes :create, "bash[master-file-copy]", :immediately
	action :nothing
end
template "/usr/lib/systemd/system/kube-scheduler.service" do
	mode "0644"
	owner "root"
	source "kube-scheduler.service.erb"
	subscribes :create, "bash[master-file-copy]", :immediately
	action :nothing
end

user 'kube' do
	home '/home/kube'
	shell '/bin/bash'
	action :create
	notifies :create, "file[/opt/ba_file]", :immediately
end

file "/opt/ba_file" do
	owner 'kube'
	group 'kube'
	mode '0600'
	content "#{node['ba']['password']},#{node['ba']['account']},#{node['ba']['uid']}"
	action :nothing
end

