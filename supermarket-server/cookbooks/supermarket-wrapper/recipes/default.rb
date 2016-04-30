#
# Cookbook Name:: supermarket-wrapper
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


app = data_bag_item('apps', 'supermarket')
node.set['supermarket_omnibus']['chef_server_url'] = app['chef_server_url']
node.set['supermarket_omnibus']['chef_oauth2_app_id'] = app['uid']
node.set['supermarket_omnibus']['chef_oauth2_secret'] = app['secret']

node.set['supermarket_omnibus']['config']['postgresql']['enable'] = app['internal_database_enable']
node.set['supermarket_omnibus']['config']['database']['host'] = app['database']['host']
node.set['supermarket_omnibus']['config']['database']['name'] = app['database']['name']
node.set['supermarket_omnibus']['config']['database']['password'] = app['database']['password']
node.set['supermarket_omnibus']['config']['database']['port'] = app['database']['port']
node.set['supermarket_omnibus']['config']['database']['username'] = app['database']['username']
node.set['supermarket_omnibus']['config']['log_level'] = 'DEBUG'

node.set['supermarket_omnibus']['config']['s3_bucket'] = app['s3_bucket']
node.set['supermarket_omnibus']['config']['s3_access_key_id'] = app['s3_access_key_id']
node.set['supermarket_omnibus']['config']['s3_secret_access_key'] = app['s3_secret_access_key']

node.set['supermarket_omnibus']['config']['redis']['enable'] = app['redis']['enable']
node.set['supermarket_omnibus']['config']['redis_url'] = app['redis_url']

node.set['supermarket_omnibus']['config']['fqdn'] = app['fqdn']
node.set['supermarket_omnibus']['config']['host'] = app['fqdn']

node.set['supermarket_omnibus']['config']['features'] = app['features']

node.set['supermarket_omnibus']['config']['fieri_key'] = app['fieri_key']
node.set['supermarket_omnibus']['config']['fieri_url'] = app['fieri_url']


include_recipe 'supermarket-omnibus-cookbook'
