template "/etc/yum.repos.d/docker.repo" do
	mode "0644"
    owner "root"
    source "docker.repo.erb"
    notifies :install, "package[docker-engine]", :immediately
end

package 'docker-engine' do
	action :nothing
	notifies :create, "template[/etc/sysconfig/docker]", :immediately
end

template "/etc/sysconfig/docker" do
	mode "0644"
	owner "root"
	source "docker.erb"
	variables :registry_url => node['docker']['registry']
	action :nothing
end
