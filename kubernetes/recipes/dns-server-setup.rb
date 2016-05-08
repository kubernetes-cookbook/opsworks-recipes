# run the pod and servie of DNS server
include_recipe 'kubernetes::kubernetes-master-run'
unless Dir.exist?('/opt/dns-template')
	directory "/opt/dns-template" do
		 owner 'root'
    	 group 'root'
    	 mode '0755'
    	 action :create
    	 notifies :create, 'template[/opt/dns-template/skydns-rc.yaml]', :immediately
    	 notifies :create, 'template[/opt/dns-template/skydns-svc.yaml]', :immediately
	end
end

template "/opt/dns-template/skydns-rc.yaml" do
    mode "0644"
    owner "root"
    source "skydns-rc.yaml.erb"
    variables ({
		:dns_domain => node['kubernetes']['dns_domain'],
    	:master_url => node['kubernetes']['master_url']
	})
    notifies :run, "execute[wait_apiserver_running]", :delayed
    action :nothing
end

template "/opt/dns-template/skydns-svc.yaml" do
    mode "0644"
    owner "root"
    source "skydns-svc.yaml.erb"
    variables :dns_ip => node['kubernetes']['dns_ip']
    notifies :run, "execute[wait_apiserver_running]", :delayed
    action :nothing
end

execute 'wait_apiserver_running' do
	command "sleep 10"
    action :nothing
    notifies :run, 'execute[run-rc]', :delayed
    notifies :run, 'execute[run-svc]', :delayed
end


execute "run-rc" do
    cwd "/opt/dns-template/"
    command "kubectl create -f skydns-rc.yaml"
    action :nothing
end

execute "run-svc" do
    cwd "/opt/dns-template/"
    command "kubectl create -f skydns-svc.yaml"
    action :nothing
end

