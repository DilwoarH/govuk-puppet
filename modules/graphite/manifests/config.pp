class graphite::config {

  file { '/etc/graphite/local_settings.py':
    ensure  => present,
    source  => 'puppet:///modules/graphite/etc/graphite/local_settings.py',
  }

  # Allow this to fail() on later versions of Ubuntu.
  # Could be replaced by a `pythonversion` fact.
  $python_version = $::lsbdistcodename ? {
    'lucid'   => '2.6',
    'precise' => '2.7',
  }
  file { '/usr/lib/pythonX.X/dist-packages/graphite/local_settings.py':
    ensure  => link,
    path    => "/usr/lib/python${python_version}/dist-packages/graphite/local_settings.py",
    target  => '/etc/graphite/local_settings.py',
  }

  file { '/etc/carbon':
    ensure  => directory,
    source  => 'puppet:///modules/graphite/etc/carbon',
    purge   => true,
    recurse => true,
  }

  file { '/opt/graphite/storage':
    ensure  => directory,
    require => File['/opt/graphite'],
  }

  exec { 'create whisper db for graphite' :
    command     => '/usr/bin/django-admin syncdb --noinput --settings=graphite.settings',
    creates     => '/opt/graphite/storage/graphite.db',
    environment => [
      'GRAPHITE_STORAGE_DIR=/opt/graphite/storage',
      'GRAPHITE_CONF_DIR=/etc/graphite/'
    ],
    require     => File['/opt/graphite/storage'],
  }

  nginx::config::vhost::proxy { 'graphite':
    to        => ['localhost:33333'],
    root      => '/opt/graphite/webapp',
    aliases   => ['graphite.*' ,'graphite.production-ec2.alphagov.co.uk'],
    protected => str2bool(extlookup('monitoring_protected','yes')),
  }

  file { '/etc/init/graphite.conf':
    source => 'puppet:///modules/graphite/etc/init/graphite.conf',
  }

  # Use our upstart script.
  file { '/etc/init.d/carbon-cache':
    ensure => absent,
  }
  file { '/etc/init/carbon_cache.conf':
    source => 'puppet:///modules/graphite/etc/init/carbon_cache.conf',
  }
  file { '/etc/init/carbon_aggregator.conf':
    source => 'puppet:///modules/graphite/etc/init/carbon_aggregator.conf',
  }

  @@nagios::check { "check_carbon_cache_running_on_${::hostname}":
    check_command       => 'check_nrpe!check_proc_running!carbon-cache',
    service_description => "carbon-cache running",
    host_name           => $::fqdn,
  }

  @@nagios::check { "check_carbon_aggregator_running_on_${::hostname}":
    check_command       => 'check_nrpe!check_proc_running!carbon-aggregator',
    service_description => "carbon-aggregator running",
    host_name           => $::fqdn,
  }

}
