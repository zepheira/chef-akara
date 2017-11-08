maintainer        "Zepheira LLC"
maintainer_email  "ryanlee@zepheira.com"
license           "Apache 2.0"
description       "Installs and configures the Akara server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
chef_version       ">= 12.1" if respond_to?(:chef_version)
issues_url        "https://github.com/zepheira/chef-akara/issues" if respond_to?(:issues_url)
source_url        "https://github.com/zepheira/chef-akara" if respond_to?(:source_url)
supports          "ubuntu", ">= 16.04"
name              "akara"
version           "2.0.0"

depends           "poise-python"
depends           "logrotate"
depends           "systemd"
