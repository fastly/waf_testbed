#
# Cookbook Name:: waf_testbed
# Recipe:: default
#
# Copyright (c) 2016 Fastly, Inc. All Rights Reserved.

include_recipe 'apt'
include_recipe 'git'
include_recipe 'poise-python'

#
# install framework for testings WAFS (FTW) via python
python_runtime '2'

# use an experimental FTW branc
# if enabled, use a specified ftw branch instead of installing from pip 
if node['waf_testbed']['ftw']['use_git'] then
  git '/opt/ftw' do
    repository 'https://github.com/fastly/ftw.git'
    branch node['waf_testbed']['ftw']['branch']
    action :sync
    notifies :run, 'python_execute[install ftw]', :immediately
  end
  python_execute 'install ftw' do
    action :nothing
    command '-m pip install -e .'
    cwd '/opt/ftw'
  end
else
  python_package 'ftw' do
    version node['waf_testbed']['ftw']['pip_version']
  end
end


#
# Checkout the latest CRS regression tests
git '/opt/owasp-crs-regressions' do
  repository 'https://github.com/SpiderLabs/OWASP-CRS-regressions.git'
  revision 'master'
  action :sync
end

# NB: for debugging purposes
package 'curl' do
  action :install
end

httpd_service 'default' do
  action [ :create, :start ]
end

httpd_module 'security2' do
  action :create
end

httpd_module 'unique_id' do
  action :create
end

httpd_module 'headers' do
  action :create
end

httpd_module 'ssl' do
  action :create
end

httpd_module 'socache_shmcb' do
  action :create
end

directory '/usr/local/waftest' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

template '/usr/local/waftest/index.html' do
  source 'index.html.erb'
  owner 'root'
  group 'root'
  mode 0755
  action :create
  notifies :restart, 'httpd_service[default]'
end

httpd_config "crs-setup" do
  source 'crs-setup.conf.erb'
  notifies :restart, 'httpd_service[default]'
end

httpd_config "modsecurity" do
  source 'modsecurity.conf.erb'
  notifies :restart, 'httpd_service[default]'
end

httpd_config "headers" do
  source 'headers.conf.erb'
  notifies :restart, 'httpd_service[default]'
end

httpd_config "vhost" do
  source 'vhost.conf.erb'
  notifies :restart, 'httpd_service[default]'
end

httpd_config 'fastly_test_rules' do
  source 'fastly_test_rules.conf.erb'
  notifies :restart, 'httpd_service[default]'
end

httpd_config 'ports' do
  source 'ports.conf.erb'
  notifies :restart, 'httpd_service[default]'
end

template '/etc/modsecurity/unicode.mapping' do
  source 'unicode.mapping.erb'
  notifies :restart, 'httpd_service[default]'
end

msc_rules_collection = [
  "REQUEST-901-INITIALIZATION.conf",
  "REQUEST-903.9001-DRUPAL-EXCLUSION-RULES.conf",
  "REQUEST-903.9002-WORDPRESS-EXCLUSION-RULES.conf",
  "REQUEST-905-COMMON-EXCEPTIONS.conf",
  "REQUEST-910-IP-REPUTATION.conf",
  "REQUEST-911-METHOD-ENFORCEMENT.conf",
  "REQUEST-912-DOS-PROTECTION.conf",
  "REQUEST-913-SCANNER-DETECTION.conf",
  "REQUEST-920-PROTOCOL-ENFORCEMENT.conf",
  "REQUEST-921-PROTOCOL-ATTACK.conf",
  "REQUEST-930-APPLICATION-ATTACK-LFI.conf",
  "REQUEST-931-APPLICATION-ATTACK-RFI.conf",
  "REQUEST-932-APPLICATION-ATTACK-RCE.conf",
  "REQUEST-933-APPLICATION-ATTACK-PHP.conf",
  "REQUEST-941-APPLICATION-ATTACK-XSS.conf",
  "REQUEST-942-APPLICATION-ATTACK-SQLI.conf",
  "REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION.conf",
  "REQUEST-949-BLOCKING-EVALUATION.conf",
  "RESPONSE-950-DATA-LEAKAGES.conf",
  "RESPONSE-951-DATA-LEAKAGES-SQL.conf",
  "RESPONSE-952-DATA-LEAKAGES-JAVA.conf",
  "RESPONSE-953-DATA-LEAKAGES-PHP.conf",
  "RESPONSE-954-DATA-LEAKAGES-IIS.conf",
  "RESPONSE-959-BLOCKING-EVALUATION.conf",
  "RESPONSE-980-CORRELATION.conf",
  "crawlers-user-agents.data",
  "iis-errors.data",
  "java-code-leakages.data",
  "java-errors.data",
  "lfi-os-files.data",
  "php-config-directives.data",
  "php-errors.data",
  "php-function-names-933150.data",
  "php-function-names-933151.data",
  "php-variables.data",
  "restricted-files.data",
  "scanners-headers.data",
  "scanners-urls.data",
  "scanners-user-agents.data",
  "scripting-user-agents.data",
  "sql-errors.data",
  "sql-function-names.data",
  "unix-shell.data",
  "windows-powershell-commands.data"
]

msc_rules_collection.each do |t|
  template "/etc/modsecurity/#{t}" do
    source "#{t}.erb"
    owner 'root'
    group 'root'
    notifies :restart, 'httpd_service[default]'
  end
end
