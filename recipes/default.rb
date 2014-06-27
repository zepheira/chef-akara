include_recipe "python"

# Package dependencies
%w{git-core python-dev}.each do |pkg|
  package pkg do
    action :install
  end
end

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
  action :create
end

data_bag(node["akara"]["data_bag"]).each do |name|
  venv = "#{node["akara"]["base"]}/#{name.to_s}"
  instance = data_bag_item(node["akara"]["data_bag"], name.to_s)

  python_virtualenv venv do
    options "--distribute --no-site-packages"
    owner node["akara"]["user"]
    group node["akara"]["group"]
    action :create
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
    action :create
  end

  link "#{venv}/logs" do
    to "#{node["akara"]["log_base"]}/#{name.to_s}"
    action :create
    link_type :symbolic
  end

  requirements = %w{html5lib httplib2 python-dateutil simplejson feedparser xlrd amara akara}
  seen = []
  instance["packages"].each do |pkg,vers|
    seen.push pkg.downcase
    python_pip pkg do
      virtualenv venv
      options instance["pip_options"]
      version vers
      action :install
    end
  end

  requirements.each do |pkg|
    if !seen.include?(pkg)
      if pkg.eql?("amara")
        python_pip "git+git://github.com/zepheira/amara.git" do
          virtualenv venv
          options instance["pip_options"]
          action :install
        end
      elsif pkg.eql?("akara")
        python_pip "git+git://github.com/zepheira/akara.git" do
          virtualenv venv
          options instance["pip_options"]
          action :install
        end
      else
        python_pip pkg do
          virtualenv venv
          options instance["pip_options"]
          action :install
        end
      end
    end
  end

  template "/etc/init.d/akara-#{name.to_s}" do
    source "akara.init.erb"
    owner "root"
    group "root"
    mode 00755
    variables({:name => name.to_s, :venv => venv, :user => node["akara"]["user"]})
  end

  service "akara-#{name.to_s}" do
    supports :status => true, :restart => true
    action :enable
  end

  template "#{venv}/akara.conf" do
    source "akara.conf.erb"
    owner node["akara"]["user"]
    group node["akara"]["group"]
    mode 00644
    variables({:config => instance, :venv => venv})
    notifies :restart, "service[akara-#{name.to_s}]", :immediately
  end

  template "/etc/logrotate.d/akara-#{name.to_s}" do
    source "logrotate.erb"
    owner "root"
    group "root"
    mode 00644
    variables({:name => name.to_s, :owner => node["akara"]["user"], :group => node["akara"]["group"]})
  end

end
