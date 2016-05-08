include_recipe 'kubernetes::docker-registry-auth'

execute 'copy-auth' do
    user 'root'
    cwd '/var/lib/kubelet'
    command 'cp ~/.dockercfg ./'
	notifies :restart, 'service[kubernetes-minion]', :immediately
end

service "kubernetes-minion" do
	action :nothing
	supports :restart => true, :stop => true, :start => true 
end
