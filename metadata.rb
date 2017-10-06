name 'chef-librenms'
maintainer 'Nicolas Grieco'
maintainer_email 'n.grieco@criteo.com'
license 'All rights reserved'
description 'Installs/Configures librenms'
long_description 'Installs/Configures librenms'
version '0.1.3'
supports 'centos7'
issues_url 'https://github.com/nicolasglab/chef-librenms/issues' if respond_to?(:issues_url)
source_url 'https://github.com/nicolasglab/chef-librenms' if respond_to?(:source_url)

depends	'apache2'
depends	'logrotate'
