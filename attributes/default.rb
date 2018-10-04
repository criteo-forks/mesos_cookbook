# frozen_string_literal: true

# Default Java version
default['java']['jdk_version'] = '8'

# Use Mesosphere repo
default['mesos']['repo']       = true

# Mesosphere Mesos version.
# overriding this attribute to nil in a wrapper cookbook will force the
# cookbook to use the latest version available in the repositories
default['mesos']['version']    = '1.7.0'

default['mesos']['package_options'] = case node['platform_family']
                                      when 'debian'
                                        ['--no-install-recommends']
                                      when 'rhel'
                                        []
                                      end

#
# Mesos MASTER configuration
#

# Mesos master binary location.
default['mesos']['master']['bin']                   = '/usr/sbin/mesos-master'

# Environmental variables set before calling the mesos master process.
default['mesos']['master']['env']['ULIMIT']         = '-n 16384'

# Send stdout and stderr to syslog.
default['mesos']['master']['syslog']                = true

# Mesos master command line flags.
# http://mesos.apache.org/documentation/latest/configuration/
default['mesos']['master']['flags']['port']          = 5050
default['mesos']['master']['flags']['log_dir']       = '/var/log/mesos'
default['mesos']['master']['flags']['logging_level'] = 'INFO'
default['mesos']['master']['flags']['cluster']       = 'MyMesosCluster'
default['mesos']['master']['flags']['work_dir']      = '/tmp/mesos'

#
# Mesos SLAVE configuration
#

# Mesos slave binary location.
default['mesos']['slave']['bin']                    = '/usr/sbin/mesos-slave'

# Environmental variables set before calling the mesos-slave process.
default['mesos']['slave']['env']['ULIMIT']          = '-n 16384'

# Send stdout and stderr to syslog.
default['mesos']['slave']['syslog']                 = true

# Mesos slave command line flags
# http://mesos.apache.org/documentation/latest/configuration/
default['mesos']['slave']['flags']['port']          = 5051
default['mesos']['slave']['flags']['log_dir']       = '/var/log/mesos'
default['mesos']['slave']['flags']['logging_level'] = 'INFO'
default['mesos']['slave']['flags']['work_dir']      = '/tmp/mesos'
default['mesos']['slave']['flags']['isolation']     = 'posix/cpu,posix/mem'
default['mesos']['slave']['flags']['master']        = 'localhost:5050'
default['mesos']['slave']['flags']['strict']        = true
default['mesos']['slave']['flags']['recover']       = 'reconnect'

# Workaround for setting default cgroups hierarchy root
default['mesos']['slave']['flags']['cgroups_hierarchy'] = '/sys/fs/cgroup'

# Use the following options if you are using Exhibitor to manage Zookeeper
# in your environment.

# Zookeeper path that Mesos will use to write to.
default['mesos']['zookeeper_path']                      = 'mesos'

# Flag to enable Zookeeper ensemble discovery via Netflix Exhibitor.
default['mesos']['zookeeper_exhibitor_discovery']       = false

# Netflix Exhibitor ZooKeeper ensemble url.
default['mesos']['zookeeper_exhibitor_url']             = nil
