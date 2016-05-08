bash "enable-repo" do
    user 'root'
    code <<-EOH
	yum repolist all
	yum-config-manager --enable rhui-REGION-rhel-server-optional
	yum-config-manager --enable rhui-REGION-rhel-server-extras
    EOH
    action :run
end 
