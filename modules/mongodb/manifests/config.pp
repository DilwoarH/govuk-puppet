# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class mongodb::config (
  $dbpath = '/var/lib/mongodb',
  $logpath,
  $development,
  $replicaset,
) {
  validate_bool($development)

  # Class params are used in the templates below.

  file { '/etc/mongodb.conf':
    ensure  => present,
    content => template('mongodb/mongodb.conf'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/init/mongodb.conf':
    ensure  => present,
    content => template('mongodb/upstart-standalone.conf'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

}
