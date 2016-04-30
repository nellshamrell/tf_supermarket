#
# Cookbook Name:: fieri
# Recipe:: default
#
# Copyright 2014 Chef Software, Inc.
#

include_recipe 'apt'
include_recipe 'redisio::install'
include_recipe 'redisio::enable'

include_recipe 'fieri::_runit'
include_recipe 'fieri::_nginx'
include_recipe 'fieri::_application'
