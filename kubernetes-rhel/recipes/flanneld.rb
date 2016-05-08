bash 'install_flannel' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  yum -y install wget
  wget --max-redirect 255 https://github.com/coreos/flannel/releases/download/v0.5.2/flannel-0.5.2-linux-amd64.tar.gz
  tar zxvf flannel-0.5.2-linux-amd64.tar.gz
  cd flannel-0.5.2
  cp flanneld /usr/local/bin
  EOH
end


template "/etc/init.d/flanneld" do
  mode "0755"
  owner "root"
  source "flanneld-init-conf.erb"
  variables ({
	:etcd_url => node['etcd']['elb_url'],
	:etcd_password => node['etcd']['password']
  })
end

