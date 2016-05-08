include_recipe 'kubernetes::kubernetes'

bash "minion-file-copy" do
    user 'root'
    cwd '/tmp'
    code <<-EOH
    if ! [[ $(ls /usr/local/bin/kube*) ]]; then
      mkdir /var/lib/kubelet
      mkdir /etc/kubernetes
	  cd ./kubernetes/server/kubernetes/server/bin
      cp kubelet kube-proxy /usr/local/bin/
    fi
    EOH
end

template "/etc/init.d/kubernetes-minion" do
	mode "0755"
	owner "root"
	source "kubernetes-minion.erb"
	variables :master_url => node['kubernetes']['master_url']
	subscribes :create, "bash[minion-file-copy]", :immediately
	notifies :disable, 'service[kubernetes-minion]', :immediately
    action :nothing
end

service "kubernetes-minion" do
	action :nothing
end
