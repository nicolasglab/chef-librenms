#
# Cookbook:: librenms
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'apache2'
include_recipe 'logrotate'

# mariadb special criteo ?
package %w[mariadb-server mariadb]

service 'mariadb' do
  supports supports status: true, restart: true, reload: true
  action :start, :enable
end

template '/tmp/create_db.sql' do
  source 'create_db.sql.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(password: node['mariadb']['user_librenms']['password'])
end

execute 'create_db' do
  action :run
  command 'mysql -uroot < /tmp/create_db.sql'
  cwd '/tmp'
  user 'root'
  group 'root'
  not_if 'echo "show tables;" | mysql -uroot librenms'
end

# voir cookbook mysql/mariadb
template '/etc/my.cnf.d/librenms-mysqld.cnf' do
  source 'librenms-mysqld.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[mariadb]'
end

yum_repository 'webtatic' do
  description "['librenms']['additional_repo']['desc']"
  mirrorlist "node['librenms']['additional_repo']['url']"
  gpgcheck "['librenms']['additional_repo']['gpgcheck']"
  enabled "['librenms']['additional_repo']['enabled']"
end

package %w[php70w php70w-cli php70w-gd php70w-mysql php70w-snmp php70w-curl php70w-common \
           net-snmp ImageMagick jwhois nmap mtr rrdtool MySQL-python net-snmp-utils \
           cronie php70w-mcrypt fping git] do
  action :install
end

template '/etc/php.d/librenms.ini' do
  source 'librenms.ini.erb'
  owner 'root'
  group 'root'
  variables(timezone: node['librenms']['phpini']['timezone'])
  mode '0644'
end

group "node['librenms']['group']" do
  action :create
end

user "node['librenms']['user']" do
  action :create
  comment 'LibreNMS user'
  group "node['librenms']['group']"
  home "node['librenms']['path']"
  shell '/bin/bash'
end

logrotate_app 'librenms' do
  cookbook 'logrotate'
  path "node['librenms']['path']/logs"
  options %w[missingok delaycompress notifempty]
  frequency 'weekly'
  rotate 6
  create "644 node['librenms']['user'] node['librenms']['group']"
end

service 'snmpd' do
  supports status: true, restart: true, reload: true
  action [:enable]
end

template '/etc/snmp/snmpd.conf' do
  source 'snmpd.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    community: node['librenms']['snmp']['community'],
    contact:   node['librenms']['contact'],
    hostname:  node['librenms']['hostname'],
  )
  notifies :restart, 'service[snmpd]'
end

remote_file '/usr/bin/distro' do
  source "node['librenms']['snmp']['distro']"
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[snmpd]'
end

apache_module 'php7_module' do
  filename 'libphp7.so'
end

web_app do
  name 'librenms'
  server_name "node['hostname']"
  server_name "node['librenms']['web']['name']"
  docroot "node['librenms']['path']/html"
  directory_options "node['librenms']['web']['options']"
  allow_override "node['librenms']['web']['override']"
end

# remote_file librenms + extract

directory "node['librenms']['path']/rrd" do
  owner node['librenms']['user']
  group node['librenms']['group']
  mode '0755'
  action :create
end

# cron mgmt to be able to disable them if not wanted.
cron 'discovery all' do
  command "node['librenms']['path']/discovery.php -h all >> /dev/null 2>&1"
  hour '*/6'
  minute '33'
  user "node['librenms']['user']"
  only_if { node.normal['librenms']['cron']['discovery_all'] = 'true' }
end

cron 'discover new' do
  command "node['librenms']['path']/discovery.php -h new >> /dev/null 2>&1"
  hour '*'
  minute '*/5'
  user "node['librenms']['user']"
  only_if { node.normal['librenms']['cron']['discovery_new'] = 'true' }
end

cron 'poller wrapper' do
  command "node['librenms']['path']/cronic /var/opt/librenms/poller-wrapper.py node['librenms']['config']['poller_threads']"
  hour '*'
  minute '*/5'
  user "node['librenms']['user']"
  only_if { node.normal['librenms']['cron']['poller'] = 'true' }
end

cron 'daily' do
  command "node['librenms']['path']/daily.sh >> /dev/null 2>&1"
  hour '0'
  minute '15'
  user "node['librenms']['user']"
  only_if { node.normal['librenms']['cron']['daily'] = 'true' }
end

cron 'alerts' do
  command "node['librenms']['path']/alerts.php >> /dev/null 2>&1"
  hour '*'
  minute '*'
  user "node['librenms']['user']"
  only_if { node.normal['librenms']['cron']['alerts'] = 'true' }
end

cron 'poll billing' do
  command "node['librenms']['path']/poll-billing.php >> /dev/null 2>&1"
  hour '*'
  minute '*/5'
  user "node['librenms']['user']"
  only_if { node.normal['librenms']['cron']['poll-billing'] = 'true' }
end

cron 'billing calculate' do
  command "node['librenms']['path']/billing-calculate.php >> /dev/null 2>&1"
  hour '*'
  minute '01'
  user "node['librenms']['user']"
  only_if { node.normal['librenms']['cron']['billing-calculate'] = 'true' }
end

cron 'check services' do
  command "node['librenms']['path']/check-services.php >> /dev/null 2>&1"
  hour '*'
  minute '*/5'
  user "node['librenms']['user']"
  only_if { node.normal['librenms']['cron']['check'] = 'true' }
end

template "node['librenms']['rrdcached']['config_file']" do
  source 'rrdcached.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    options:      node['librenms']['rrdcached']['options'],
    user_options: node['librenms']['rrdcached']['user_options'],
    user:         node['librenms']['user'],
  )
  notifies :restart, 'service[snmpd]'
  only_if { node.normal['librenms']['rrdcached']['enabled'] = 'true' }
end

# config.php
template "node['librenms']['path']/config.php" do
  source 'config.php.erb'
  owner "node['librenms']['user']"
  group "node['librenms']['group']"
  mode '0640'
  variables(
    db_pass:  "node['mariadb']['user_librenms']['password']",
    user:     "node['librenms']['user']",
    path:     "node['librenms']['path']",
    networks: "node['librenms']['scanning_discovery']",
    hostname: "node['librenms']['hostname']",
    port:     "node['librenms']['port_service']",
  )
end

# exec build-base.php

execute 'adduser admin' do
  action :run
  command 'php adduser.php $LIBRE_USER $LIBRE_PASS 10 $LIBRE_MAIL'
  cwd "node['librenms']['path']"
  environment(
    'LIBRE_USER' => node['librenms']['user_admin'],
    'LIBRE_PASS' => node['librenms']['user_pass'],
    'LIBRE_MAIL' => node['librenms']['contact'],
  )
  user 'root'
  group 'root'
end
