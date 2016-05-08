include_recipe 'kubernetes::docker'

template "/etc/cron.daily/docker-clean.cron" do
    mode "0644"
    owner "root"
    source "docker-clean.cron.erb"
end


template "/etc/cron.weekly/remove-docker-image.cron" do
	mode "0644"
    owner "root"
    source "remove-docker-image.cron.erb"
end


template "/etc/cron.monthly/remove-log.cron" do
	mode "0644"
	owner "root"
	source "remove-log.cron.erb"
end
