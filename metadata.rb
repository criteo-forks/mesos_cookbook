# frozen_string_literal: true

name             'mesos'
maintainer       'Criteo'
maintainer_email 'g.seux@criteo.com'
license          'Apache-2.0'
description      'Installs/Configures Apache Mesos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '4.0.0'
source_url       'https://github.com/criteo-forks/mesos_cookbook'
issues_url       'https://github.com/criteo-forks/mesos_cookbook/issues'

supports 'centos'

depends 'java', '>= 8.1.0'
depends 'yum'
depends 'systemd'
chef_version '>= 15' if respond_to?(:chef_version)
