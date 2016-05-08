include_recipe 'kubernetes-rhel::repo-setup'

package 'etcd' do
	action :install
end

package 'wget' do
	action :install
end

template '/etc/etcd/etcd.conf' do
	source "etcd.conf.erb"
	mode "0755"
	owner "root"
	subscribes :create, "package[etcd]", :immediately
end

