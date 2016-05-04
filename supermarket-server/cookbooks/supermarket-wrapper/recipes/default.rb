#
# Cookbook Name:: supermarket-wrapper
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


app = data_bag_item('apps', 'supermarket')
node.set['supermarket_omnibus']['chef_server_url'] = app['chef_server_url']
node.set['supermarket_omnibus']['chef_oauth2_app_id'] = app['uid']
node.set['supermarket_omnibus']['chef_oauth2_secret'] = app['secret']
node.set['supermarket_omnibus']['config']['fqdn'] = app['fqdn']
node.set['supermarket_omnibus']['config']['host'] = app['fqdn']
node.set['supermarket_omnibus']['config']['features'] = app['features']

node.set['supermarket_omnibus']['config']['s3_bucket'] = app['s3_bucket']
node.set['supermarket_omnibus']['config']['s3_access_key_id'] = app['s3_access_key_id']
node.set['supermarket_omnibus']['config']['s3_secret_access_key'] = app['s3_secret_access_key']

include_recipe 'supermarket-omnibus-cookbook'
