# enable DNS setting in kubelet and restart 

template "/etc/init.d/kubernetes-minion" do
    mode "0755"
    owner "root"
    source "kubernetes-minion-new.erb"
    variables({
	  :master_url => node['kubernetes']['master_url'],
      :dns_domain => node['kubernetes']['dns_domain'],
      :dns_ip => node['kubernetes']['dns_ip']
    })
    notifies :restart, 'service[restart-kubernetes-minion]', :immediately	
end

service "restart-kubernetes-minion" do
	service_name 'kubernetes-minion'
	action :nothing
	supports :restart => true, :stop => true, :start => true 
end
