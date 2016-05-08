# run the pod and servie of monitoring system
include_recipe 'kubernetes::kubernetes-master-run'
unless Dir.exist?('/opt/monitoring-template') #should access etcd for sure
	directory "/opt/monitoring-template" do
		 owner 'root'
    	 group 'root'
    	 mode '0755'
    	 action :create
    	 notifies :create, 'template[/opt/monitoring-template/grafana-service.yaml]', :immediately
    	 notifies :create, 'template[/opt/monitoring-template/heapster-service.yaml]', :immediately
    	 notifies :create, 'template[/opt/monitoring-template/influxdb-service.yaml]', :immediately
    	 notifies :create, 'template[/opt/monitoring-template/heapster-controller.yaml]', :immediately
    	 notifies :create, 'template[/opt/monitoring-template/influxdb-grafana-controller.yaml]', :immediately
	end
end

template "/opt/monitoring-template/grafana-service.yaml" do
    mode "0644"
    owner "root"
    source "grafana-service.yaml.erb"
    notifies :run, "execute[start-services-and-db]", :delayed
    action :nothing
end

template "/opt/monitoring-template/heapster-service.yaml" do
    mode "0644"
    owner "root"
    source "heapster-service.yaml.erb"
    notifies :run, "execute[start-services-and-db]", :delayed
    action :nothing
end
template "/opt/monitoring-template/influxdb-service.yaml" do
    mode "0644"
    owner "root"
    source "influxdb-service.yaml.erb"
    notifies :run, "execute[start-services-and-db]", :delayed
    action :nothing
end
template "/opt/monitoring-template/heapster-controller.yaml" do
    mode "0644"
    owner "root"
    source "heapster-controller.yaml.erb"
    variables :master_url => node['kubernetes']['master_url']
    action :nothing
end
template "/opt/monitoring-template/influxdb-grafana-controller.yaml" do
    mode "0644"
    owner "root"
    source "influxdb-grafana-controller.yaml.erb"
    notifies :run, "execute[start-services-and-db]", :delayed
    action :nothing
end

execute 'start-services-and-db' do
    cwd "/opt/monitoring-template/"
	command <<-EOF
	kubectl create -f grafana-service.yaml
	kubectl create -f heapster-service.yaml
	kubectl create -f influxdb-service.yaml
	kubectl create -f influxdb-grafana-controller.yaml
	EOF
    action :nothing
    notifies :run, 'execute[wait-for-db-creation]', :delayed
end

execute "wait-for-db-creation" do
    command "sleep 30"
    action :nothing
    notifies :run, 'execute[start-heapster]', :delayed
end

execute "start-heapster" do
    cwd "/opt/monitoring-template/"
    command "kubectl create -f heapster-controller.yaml"
    action :nothing
end

