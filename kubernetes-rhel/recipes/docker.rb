include_recipe 'kubernetes-rhel::repo-setup'

package 'docker' do
	action :install
	notifies :create, "template[/etc/sysconfig/docker]", :immediately
	notifies :create, "template[/usr/lib/systemd/system/docker.service]", :immediately
end

template "/etc/sysconfig/docker" do
	mode "0644"
	owner "root"
	source "docker.erb"
	action :nothing
end

template "/usr/lib/systemd/system/docker.service" do
    mode "0644"
    owner "root"
    source "docker.service.erb"
    action :nothing
end

