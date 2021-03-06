# frozen_string_literal: true

#
# Cookbook Name:: mesos
# Recipe:: master
#
# Copyright (C) 2015 Medidata Solutions, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef::Recipe
  include MesosHelper
end

include_recipe 'mesos::install'

# Mesos configuration validation
ruby_block 'mesos-master-configuration-validation' do
  block do
    unknown_flags('master', node).each do |flag|
      Chef::Application.fatal!("Invalid Mesos configuration option: #{flag}. Aborting!", 1000)
    end
  end
  only_if { unknown_flags('master', node).any? }
end

# ZooKeeper Exhibitor discovery
if node['mesos']['zookeeper_exhibitor_discovery'] && node['mesos']['zookeeper_exhibitor_url']
  zk_nodes = MesosHelper.discover_zookeepers_with_retry(node['mesos']['zookeeper_exhibitor_url'])

  Chef::Application.fatal!('Failed to discover zookeepers. Cannot continue.') if zk_nodes.nil?

  node.override['mesos']['master']['flags']['zk'] = 'zk://' + zk_nodes['servers'].sort.map { |s| "#{s}:#{zk_nodes['port']}" }.join(',') + '/' + node['mesos']['zookeeper_path']
end

user node['mesos']['master']['user'] do
  home '/etc/mesos-chef'
end

directory node['mesos']['master']['flags']['work_dir'] do
  owner node['mesos']['master']['user']
  mode '0755'
  recursive true
end

# Mesos master configuration wrapper
template 'mesos-master-wrapper' do
  path '/etc/mesos-chef/mesos-master'
  owner node['mesos']['master']['user']
  group 'root'
  mode '0750'
  source 'wrapper.erb'
  variables(bin: node['mesos']['master']['bin'],
            flags: node['mesos']['master']['flags'])
  notifies :restart, 'service[mesos-master]'
end

file '/etc/mesos-chef/mesos-master-environment' do
  owner node['mesos']['master']['user']
  group 'root'
  mode '0750'
  content node['mesos']['master']['env'].sort.map { |k, v| %(#{k}="#{v}") }.join("\n")
  notifies :restart, 'service[mesos-master]'
end

systemd_service 'mesos-master' do
  unit do
    description 'Mesos mesos-master'
    after 'network.target'
    wants 'network.target'
    # see https://jira.apache.org/jira/browse/MESOS-9772
    requires 'systemd-journald.service'
  end

  service do
    environment_file '/etc/mesos-chef/mesos-master-environment'
    exec_start '/etc/mesos-chef/mesos-master'
    restart 'on-failure'
    restart_sec 20
    limit_nofile node['mesos']['master']['limit_nofile']
    user node['mesos']['master']['user']
  end

  install do
    wanted_by 'multi-user.target'
  end
  action %i[create enable]
  notifies :restart, 'service[mesos-master]'
end

# Mesos master service definition
service 'mesos-master' do
  supports status: true, restart: true
  action %i[enable]
end
