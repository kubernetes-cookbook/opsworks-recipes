template "/etc/yum.repos.d/docker.repo" do
	mode "0644"
    owner "root"
    source "docker.repo.erb"
    notifies :install, "package[docker-engine]", :immediately
end

package 'docker-engine' do
	action :nothing
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
