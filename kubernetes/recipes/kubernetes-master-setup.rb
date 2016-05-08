include_recipe 'kubernetes::kubernetes'

bash "master-file-copy" do
    user 'root'
    cwd '/tmp'
    code <<-EOH
    if ! [[ $(ls /usr/local/bin/kube*) ]]; then
      mkdir /etc/kubernetes
	  cd ./kubernetes/server/kubernetes/server/bin
      cp kubectl kube-apiserver kube-scheduler kube-controller-manager kube-proxy /usr/local/bin/
    fi
    EOH
end

etcd_endpoint="http://root:#{node['etcd']['password']}@#{node['etcd']['elb_url']}:80"

template "/etc/init.d/kubernetes-master" do
	mode "0755"
	owner "root"
	source "kubernetes-master-new.erb"
	variables({
	  :etcd_server => etcd_endpoint,
	  :cluster_cidr => node['kubernetes']['cluster_cidr'],
	  :ba_path => "/root/ba_file"
	})
	subscribes :create, "bash[master-file-copy]", :immediately
    action :nothing
end

file "/root/ba_file" do
	owner 'root'
	group 'root'
	mode '0600'
	content "#{node['ba']['password']},#{node['ba']['account']},#{node['ba']['uid']}"
	action :create
end


