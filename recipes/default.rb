include_recipe 'python'

# Package dependencies
['git-core','python-dev'].each do |pkg|
  package pkg do
    action :install
  end
end

user node[:akara][:user] do
  action :create
  system true
  shell "/bin/false"
end

directory node[:akara][:home] do
  owner node[:akara][:user]
  group node[:akara][:group]
  mode "0755"
  action :create
end

venv_path = node[:akara][:home]+node[:akara][:virtualenv]

python_virtualenv venv_path do
  owner node[:akara][:user]
  group node[:akara][:group]
#  interpreter 'python2.7'
  action :create
end

# perform Akara setup
#execute "akara-setup" do
#  command node[:akara][:home]+node[:akara][:virtualenv]+'/bin/akara setup'
#  creates node[:akara][:home]+node[:akara][:virtualenv]+'/logs'
#  cwd node[:akara][:home]+node[:akara][:virtualenv]
#  user node[:akara][:user]
#  group node[:akara][:group]
#  action :run
#end

# shortcut Akara setup by manually creating logs dir
directory node[:akara][:home]+node[:akara][:virtualenv]+'/logs' do
  owner node[:akara][:user]
  group node[:akara][:group]
  mode "0755"
  action :create
end

['html5lib','httplib2','python-dateutil','simplejson','feedparser','xlrd'].each do |pkg|
  python_pip pkg do
    action :install
    virtualenv venv_path
  end
end

python_pip "git+git://github.com/zepheira/amara.git" do
  virtualenv venv_path
  action :install
end

python_pip "git+git://github.com/zepheira/akara.git" do
  virtualenv venv_path
  action :install
end

template "/etc/init.d/akara" do
  source "akara.init.erb"
  mode "0755"
end

service "akara" do
  #provider Chef::Provider::Service::Init::Debian
  enabled true
  supports :status => true, :restart => true
  action [:start, :enable]
end

template "#{venv_path}/akara.conf" do
  owner node[:akara][:user]
  group node[:akara][:group]
  source "akara.conf.erb"
  mode "0644"
  notifies :restart, resources(:service => "akara"), :immediately
end
