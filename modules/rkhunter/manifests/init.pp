# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class rkhunter {

  anchor { 'rkhunter::begin':
    notify => Class['rkhunter::config'];
  }

  class { 'rkhunter::package':
    require => Anchor['rkhunter::begin'],
    notify  => Class['rkhunter::config'],
  }

  class { 'rkhunter::config':
    require => Class['rkhunter::package'],
    notify  => [
      Class['rkhunter::update'],
      Anchor['rkhunter::end'],
    ],
  }

  class { 'rkhunter::update':
    require => Class['rkhunter::config'],
  }

  class { 'rkhunter::monitoring':
    require => Class['rkhunter::config'],
  }

  anchor { 'rkhunter::end':
    require => Class['rkhunter::monitoring'],
  }

}
