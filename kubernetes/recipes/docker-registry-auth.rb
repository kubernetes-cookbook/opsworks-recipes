template "/root/.dockercfg" do
  source "docker.credential.erb"
  variables({
    :registry => node["docker"]["registry"],
    :auth => node["docker"]["auth"],
    :email => node["docker"]["email"]
  })
end
