include_recipe 'kubernetes-rhel::etcd'

service "etcd" do 
	action :start
end

template "/root/etcd_enable_ba.sh" do
    mode "0755"
    owner "root"
    source "etcd_enable_ba.sh.erb"
    variables :etcd_password => node['etcd']['password']
	subscribes :create, "service[etcd]", :delayed 
    notifies :run, "bash[ba_setup]", :delayed
end

bash 'ba_setup' do
    user 'root'
    cwd '/root'
    code <<-EOH
    tries=0
    while [ $tries -lt 10 ]; do
        sleep 1
        tries=$((tries + 1))
    done

    /root/etcd_enable_ba.sh

    EOH

    action :nothing
end
