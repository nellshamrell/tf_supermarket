#
# Cookbook Name:: fieri
# Recipe:: _nginx
#
# Copyright 2014 Chef Software, Inc.
#

package 'nginx'

template '/etc/nginx/sites-available/default' do
  source 'fieri.nginx.erb'
  notifies :restart, 'service[nginx]', :immediately
end

service 'nginx' do
  action :nothing
end
