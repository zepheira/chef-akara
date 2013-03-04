maintainer        "Zepheira LLC"
maintainer_email  "mark@zepheira.com"
license           "Apache 2.0"
description       "Installs and configures the Akara server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
recipe            "akara", "Includes the client recipe to configure a server"
depends           "python"
