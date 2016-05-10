bash 'install_kubernetes' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  if [[ $(ls /usr/local/bin/kubectl) ]]; then
    current_version=$(/usr/local/bin/kubectl version | awk 'NR==1' | awk -F":\"v" '{ print $2 }' | awk -F"\"," '{ print $1 }')
    if [ "$current_version" -eq "#{node['kubernetes']['version']}" ]; then
        exit
    fi
  fi

  if [[ $(ls /usr/local/bin/kubelet) ]] ; then
    current_version=$(/usr/local/bin/kubelet --version | awk -F"Kubernetes v" '{ print $2 }')
    if [ "$current_version" -eq "#{node['kubernetes']['version']}" ]; then
        exit
    fi
  fi
  rm -rf kubernetes/
  wget --max-redirect 255 https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v#{node['kubernetes']['version']}/kubernetes.tar.gz -O kubernetes-#{node['kubernetes']['version']}.tar.gz
  tar zxvf kubernetes-#{node['kubernetes']['version']}.tar.gz
  cd kubernetes/server
  tar zxvf kubernetes-server-linux-amd64.tar.gz

  EOH
end
