name 'librenms'
maintainer 'Nicolas Grieco'
maintainer_email 'n.grieco@criteo.com'
license 'All rights reserved'
description 'Installs/Configures librenms'
long_description 'Installs/Configures librenms'
version '0.1.1'
supports 'centos7'
issues_url 'https://github.com/nicolasglab/chef-librenms/issues' if respond_to?(:issues_url)
source_url 'https://github.com/nicolasglab/chef-librenms' if respond_to?(:source_url)

depends	'apache2'
depends	'logrotate'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
