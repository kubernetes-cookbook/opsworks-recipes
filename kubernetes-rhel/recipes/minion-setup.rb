include_recipe 'kubernetes-rhel::k8s-setup'

#package 'kubernetes-node'
bash "minion-file-copy" do
    user 'root'
    cwd '/tmp//kubernetes/server/kubernetes/server/bin'
    code <<-EOH
	mkdir /var/lib/kubelet
    mkdir /etc/kubernetes
    cp kubelet kube-proxy /usr/local/bin/
    EOH
end

# add config files
template "/etc/kubernetes/config" do
	mode "0644"
	owner "root"
	source "minion-conf.erb"
	variables :master_endpoint => node['kubernetes']['master_url']
	subscribes :create, "bash[minion-file-copy]", :immediately
	action :nothing
end

template "/etc/kubernetes/kubelet" do
	mode "0644"
	owner "root"
	source 	"minion-kubelet.erb"
	variables :master_endpoint => node['kubernetes']['master_url']
	subscribes :create, "bash[minion-file-copy]", :immediately
	action :nothing
end

# add service init files
template "/usr/lib/systemd/system/kubelet.service" do
    mode "0644"
    owner "root"
    source "kubelet.service.erb"
    subscribes :create, "bash[minion-file-copy]", :immediately
	action :nothing
end
template "/usr/lib/systemd/system/kube-proxy.service" do
    mode "0644"
    owner "root"
    source "kube-proxy.service.erb"
    subscribes :create, "bash[minion-file-copy]", :immediately
	action :nothing
end

