Description
===========

Installs and configures [Akara](http://akara.info/) as a service.

Requirements
============

* [python](https://github.com/opscode-cookbooks/python)
* iptables
* monit

Tested on:

* Ubuntu 12.04

Attributes
==========

In order to support multiple instances of Akara on one node, data bags are used.  For the recipe, the following attributes apply:

* `node["akara"]["data_bag"]` must be set to the data bag containing the Akara instances to deploy, *required*.
* `node["akara"]["base"]` defaults to "/opt/akara"
* `node["akara"]["user"]` defaults to "akara"
* `node["akara"]["group"]` defaults to "akara"

Each item in the data bag will be known by and set up according to its idenifier.  The data bag items can carry the following attributes:

* `port` defaults to 8880
* `max_servers` defaults to 100
* `max_spare_servers` defaults to 30
* `min_spare_servers` defaults to 10
* `max_requests_per_server` defaults to 1000
* `log_level` defaults to "INFO"
* `pip_options` defaults to nothing, extra options for pip
* `packages` lists extra packages and the version to install in the virtualenv.  The recipe is aware of which are required and will install the latest for those that aren't in the `packages` hash.
* `modules` lists extra modules to include in akara.conf
* `module_config` is a hash with extra configuration directives, like

```
module_config: {
  config_class: { attr1: value,
                  attr2: other_value }
}
```

Usage
=====

Include the `default` recipe to install Akara instances according to the data bags you set up.

License and Author
==================

Author:: Ryan Lee <ryanlee@zepheira.com>
Author:: Mark Baker <mark@zepheira.com>

Copyright:: 2013 Zepheira LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
