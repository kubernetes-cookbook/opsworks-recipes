bash 'install_kubernetes' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  yum -y install wget
  wget --max-redirect 255 https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v#{node['kubernetes']['version']}/kubernetes.tar.gz
  tar zxvf kubernetes.tar.gz
  cd kubernetes/server
  tar zxvf kubernetes-server-linux-amd64.tar.gz
  EOH
end
