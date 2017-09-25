
default['mariadb']['user_librenms']['password'] = 'default'

default['librenms']['path'] = '/var/opt/librenms'
default['librenms']['user']  = 'librenms'
default['librenms']['group'] = 'librenms'

# httpd related
default['librenms']['web']['name'] = 'librenms.example.com'
default['librenms']['web']['port'] = '8080'
default['librenms']['web']['options'] = 'FollowSymLinks MultiViews'
default['librenms']['web']['override'] = 'All'
default['librenms']['phpini']['timezone'] = 'UTC'

# snmpd
default['librenms']['snmp']['community'] = 'public'
default['librenms']['snmp']['distro'] = 'https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro'
default['librenms']['contact'] = 'webmaster@example.com'

# librenms user mgmt
default['librenms']['user_admin'] = 'admin'
default['librenms']['user_pass'] = 'admin'

# repo for php7
default['librenms']['additional_repo']['url'] = 'https://mirror.webtatic.com/yum/el7/$basearch/debug/mirrorlist'
default['librenms']['additional_repo']['desc'] = 'Webtatic repo EL7'
default['librenms']['additional_repo']['enabled'] = 'true'
default['librenms']['additional_repo']['gpgcheck'] = 'true'

# downloading librenms
default['librenms']['install']['url'] = 'https://github.com/librenms/librenms/archive/'
default['librenms']['install']['version'] = 'master'

# cron jobs mgmt
default['librenms']['config']['poller_threads'] = '8'
default['librenms']['cron']['discovery_all'] = 'true'
default['librenms']['cron']['discovery_new'] = 'true'
default['librenms']['cron']['poller'] = 'true'
default['librenms']['cron']['daily'] = 'true'
default['librenms']['cron']['alerts'] = 'true'
default['librenms']['cron']['poll-billing'] = 'true'
default['librenms']['cron']['billing-calculate'] = 'true'
default['librenms']['cron']['check'] = 'true'

# rrdcached
default['librenms']['rrdcached']['enabled'] = 'false'
default['librenms']['rrdcached']['config_file'] = '/etc/sysconfig/rrdcached'
default['librenms']['rrdcached']['options'] = '-w 1800 -z 1800 -f 3600 -B -R -j /var/tmp -l unix:/var/run/rrdcached/rrdcached.sock -t 4 -F'
default['librenms']['rrdcached']['user_options'] = "-s node['librenms']['user'] -U node['librenms']['user'] -G node['librenms']['group']"
default['librenms']['rrdcached']['path'] = "node['librenms']['path']/rrd"
