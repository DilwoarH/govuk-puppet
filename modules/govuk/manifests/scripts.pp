# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::scripts {

  # govuk_node_list is a simple script that lists nodes of specified classes
  # using puppetdb
  file { '/usr/local/bin/govuk_node_list':
    ensure => present,
    source => 'puppet:///modules/govuk/bin/govuk_node_list',
    mode   => '0755',
  }

  # govuk_node_clean removes stale or decommissioned nodes from puppetdb and the
  # puppetmaster
  file { '/usr/local/bin/govuk_node_clean':
    ensure => present,
    source => 'puppet:///modules/govuk/bin/govuk_node_clean',
    mode   => '0755',
  }

  # govuk_check_security_upgrades list packages which need a security upgrade
  file { '/usr/local/bin/govuk_check_security_upgrades':
    ensure => present,
    source => 'puppet:///modules/govuk/bin/govuk_check_security_upgrades',
    mode   => '0755',
  }

}
