# Cookbook Name:: akara
# Recipe:: default

python_runtime "akara" do
  version "2.7"
  options :system, dev_package: true
end

package "git-core"

user node["akara"]["user"] do
  action :create
  system true
  shell "/bin/false"
end

directory node["akara"]["base"] do
  owner node["akara"]["user"]
  group node["akara"]["group"]
  mode 00755
  action :create
end

directory node["akara"]["log_base"] do
  owner node["akara"]["user"]
  group node["akara"]["group"]
  mode 00770
  recursive true
  action :create
end

data_bag(node["akara"]["data_bag"]).each do |name|
  venv = "#{node["akara"]["base"]}/#{name.to_s}"
  instance = data_bag_item(node["akara"]["data_bag"], name.to_s)

  python_virtualenv "akara-#{name.to_s}" do
    action :create
    path venv
    python "akara"
    system_site_packages false
    user node["akara"]["user"]
    group node["akara"]["group"]
  end

  directory "#{venv}/caches" do
    owner node["akara"]["user"]
    group node["akara"]["group"]
    mode 00755
    action :create
  end

  directory "#{node["akara"]["log_base"]}/#{name.to_s}" do
    owner node["akara"]["user"]
    group node["akara"]["group"]
    mode 00770
    recursive true
    action :create
  end

  link "#{venv}/logs" do
    to "#{node["akara"]["log_base"]}/#{name.to_s}"
    action :create
    link_type :symbolic
  end

  reqs = %w{html5lib httplib2 python-dateutil simplejson feedparser xlrd amara akara}
  seen = []
  instance["packages"].each do |pkg,vers|
    seen.push pkg.downcase
    python_package pkg do
      action :install
      user node["akara"]["user"]
      group node["akara"]["group"]
      virtualenv "akara-#{name.to_s}"
      options instance["pip_options"]
      version vers
    end
  end

  reqs.each do |pkg|
    if !seen.include?(pkg)
      if pkg.eql?("amara")
        python_package "git+git://github.com/zepheira/amara.git" do
          action :install
          virtualenv "akara-#{name.to_s}"
          options instance["pip_options"]
        end
      elsif pkg.eql?("akara")
        python_package "git+git://github.com/zepheira/akara.git" do
          action :install
          virtualenv "akara-#{name.to_s}"
          options instance["pip_options"]
        end
      else
        python_package pkg do
          action :install
          virtualenv "akara-#{name.to_s}"
          options instance["pip_options"]
        end
      end
    end
  end

  template "#{venv}/akara.conf" do
    source "akara.conf.erb"
    owner node["akara"]["user"]
    group node["akara"]["group"]
    mode 00644
    variables({:config => instance, :venv => venv})
    notifies :restart, "service[akara-#{name.to_s}]", :delayed
  end

  systemd_service "akara-#{name.to_s}" do
    unit_description "Akara (#{name.to_s})"
    unit_after "network.target"
    service_type "forking"
    service_pid_file "#{venv}/logs/akara.pid"
    service_working_directory venv
    service_exec_start "#{venv}/bin/akara -f #{venv}/akara.conf start"
    service_exec_stop "#{venv}/bin/akara stop"
    service_exec_reload "#{venv}/bin/akara -f #{venv}/akara.conf restart"
    service_restart "on-failure"
    service_restart_sec "3s"
    service_user node["akara"]["user"]
    install_wanted_by "multi-user.target"
  end

  service "akara-#{name.to_s}" do
    supports :status => true, :restart => true
    action [:enable, :start]
  end

  logrotate_app "akara-#{name.to_s}" do
    action :enable
    rotate 10
    frequency "weekly"
    create "644 #{node["akara"]["user"]} #{node["akara"]["group"]}"
    path ["#{node["akara"]["log_base"]}/#{name.to_s}/*.log"]
    options ["missingok","compress","delaycompress","notifempty","sharedscripts"]
    postrotate <<-EOH
        /bin/systemctl restart akara-#{name.to_s} >/dev/null 2>&1
EOH
  end
end
