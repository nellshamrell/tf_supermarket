#
# Cookbook Name:: fieri
# Recipe:: _ruby
#
# Copyright 2014 Chef Software, Inc.
#

apt_repository 'brightbox-ruby' do
  uri 'http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'C3173AA6'
end

package 'ruby2.0'
package 'ruby2.0-dev'

%w(erb gem irb rake rdoc ri ruby testrb).each do |rb|
  link "/usr/bin/#{rb}" do
    to "/usr/bin/#{rb}2.0"
  end
end

gem_package 'bundler'
