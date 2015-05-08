# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk_elasticsearch::dump {
  package { 'es_dump_restore':
    ensure   => '1.0.0',
    provider => 'system_gem',
  }

  file { '/var/es_dump':
    ensure => directory,
    owner  => 'elasticsearch',
    group  => 'elasticsearch',
  }

  file { '/usr/bin/es_dump':
    ensure => file,
    source => 'puppet:///modules/govuk_elasticsearch/es_dump',
    mode   => '0755',
  }

  cron { 'dump-elasticsearch-indexes':
    command => '/usr/bin/es_dump http://localhost:9200 /var/es_dump',
    user    => 'elasticsearch',
    require => [
      File['/var/es_dump'],
      File['/usr/bin/es_dump'],
    ],
    hour    => '3',
    minute  => '0',
  }
}
