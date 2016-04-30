#
# Cookbook Name:: fieri
# Recipe:: _runit
#
# Copyright 2014 Chef Software, Inc.
#

package 'runit'

directory '/etc/service' do
  mode 0755
  recursive true
end

%w(unicorn sidekiq).each do |name|
  directory "/etc/sv/#{name}" do
    mode 0755
    recursive true
  end

  template "/etc/sv/#{name}/run" do
    source "#{name}.sv.erb"
    mode 0755
  end

  directory "/etc/sv/#{name}/log" do
    recursive true
    mode 0755
  end

  directory "/var/log/#{name}" do
    recursive true
    mode 0755
  end

  file "/etc/sv/#{name}/log/run" do
    content "#!/bin/sh\nexec svlogd -tt /var/log/#{name}\n"
    mode 0755
  end

  link "/etc/service/#{name}" do
    to "/etc/sv/#{name}"
  end

  service name do
    restart_command "sv t #{name}"
  end
end
