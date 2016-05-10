include_recipe 'kubernetes::kubernetes'

bash "master-file-copy" do
    user 'root'
    cwd '/tmp/kubernetes/server/kubernetes/server/bin'
    code <<-EOH
    if [[ $(ls /usr/local/bin/kubectl) ]]; then
        current_version=$(/usr/local/bin/kubectl version | awk 'NR==1' | awk -F":\"v" '{ print $2 }' | awk -F"\"," '{ print $1 }')        
        if [ "$current_version" -eq "#{node['kubernetes']['version']}" ]; then
            exit
        fi
    fi
    cp kubectl kube-apiserver kube-scheduler kube-controller-manager kube-proxy /usr/local/bin/
    EOH
end

directory '/etc/kubernetes' do
    owner 'root'
    group 'root'
    mode '0755'
    subscribes :create, "bash[master-file-copy]", :immediately
    action :nothing
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

