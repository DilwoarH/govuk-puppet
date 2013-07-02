# == Class: puppet::master
#
# Install and configure a puppet master served by nginx and unicorn.
# Includes PuppetDB of a fixed version on the same host.
#
# === Parameters
#
# [*puppet_version*]
#   Specify version of pupet-common and puppet
#
# [*unicorn_port*]
#   Specify the port on which unicorn (and hence the puppetmaster) should
#   listen.
#
class puppet::master(
  $puppet_version = undef,
  $unicorn_port = '9090',
) {
  include puppet::repository
  include unicornherder

  $puppetdb_version = '1.0.2-1puppetlabs1'

  class { '::puppetdb':
    package_ensure => $puppetdb_version,
  }

  anchor {'puppet::master::begin':
    notify => Class['puppet::master::service'],
  }
  class{'puppet::master::package':
    puppet_version   => $puppet_version,
    puppetdb_version => $puppetdb_version,
    notify           => Class['puppet::master::service'],
    require          => [
      Class['unicornherder'],
      Anchor['puppet::master::begin'],
    ],
  }
  class{'puppet::master::config':
    unicorn_port => $unicorn_port,
    require      => Class['puppet::master::package'],
    notify       => Class['puppet::master::service'],
  }
  class { 'puppet::master::generate_cert':
    require   => Class['puppet::master::config'],
  }

  class { 'puppet::master::firewall':
    require => Class['puppet::master::config'],
  }

  class{'puppet::master::service':
    # This subscribe is here because /etc/puppet/puppet.conf is currently
    # provided by a manifest separate from puppet::master::*. TODO: move
    # master puppet.conf into the configuration of the puppetmaster.
    subscribe => File['/etc/puppet/puppet.conf'],
    require   => Class['puppet::master::generate_cert'],
  }

  class { 'puppet::master::nginx': }

  anchor {'puppet::master::end':
    subscribe => Class['puppet::master::service'],
    require   => Class[
      'puppet::master::firewall',
      'puppet::master::nginx'
    ],
  }
}
