#
# Cookbook Name:: fieri
# Recipe:: application
#
# Copyright 2014 Chef Software, Inc.
#

include_recipe 'git'
include_recipe 'xml'
include_recipe 'fieri::_ruby'

group 'fieri' do
  system true
end

user 'fieri' do
  gid 'fieri'
  system true
  home node['fieri']['home']
  comment 'Fieri'
  shell '/bin/bash'
end

%w( shared shared/bundle ).each do |dir|
  directory "#{node['fieri']['home']}/#{dir}" do
    user 'fieri'
    group 'fieri'
    mode 0755
    recursive true
  end
end

begin
  app = data_bag_item(:apps, node['fieri']['data_bag'])
rescue Net::HTTPServerException => e
  if e.response.code.to_i == 404
    Chef::Application.fatal! "This recipe requires a data bag item in the apps data bag, defined in the node['fieri']['data_bag'] attribute."
  else
    raise
  end
end

file "#{node['fieri']['home']}/shared/env" do
  content app.map { |k, v| "#{k.upcase}=#{v}" }.join("\n")

  user 'fieri'
  group 'fieri'
  mode '0600'

  notifies :restart, 'service[unicorn]'
  notifies :restart, 'service[sidekiq]'
end

template "#{node['fieri']['home']}/shared/unicorn.rb" do
  source 'unicorn.rb.erb'
end

deploy_revision node['fieri']['home'] do
  repo 'https://github.com/opscode/fieri.git'
  revision 'master'
  user 'fieri'
  group 'fieri'

  create_dirs_before_symlink %w( vendor )
  symlinks 'env' => '.env', 'bundle' => 'vendor/bundle'
  migrate false
  symlink_before_migrate({})
  purge_before_symlink []

  environment 'RACK_ENV' => 'production'

  before_restart do
    execute 'bundle install --deployment' do
      cwd release_path
      user 'fieri'
    end
  end

  notifies :restart, 'service[unicorn]'
  notifies :restart, 'service[sidekiq]'
end
