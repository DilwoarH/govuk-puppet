class assets {
  include assets::user

  package { 'nfs-common':
    ensure => installed,
  }

  collectd::plugin { 'nfs':
    require => Package['nfs-common'],
  }

  file { "/data/uploads":
    ensure  => 'directory',
    owner   => 'assets',
    group   => 'assets',
    mode    => '0664',
    require => [User['assets'], Group['assets']],
  }

  if $::govuk_platform != 'development' {
    $app_domain = extlookup('app_domain')

    mount { "/data/uploads":
      ensure   => "mounted",
      device   => "asset-master.${app_domain}:/mnt/uploads",
      fstype   => "nfs",
      options  => 'rw,soft',
      remounts => false,
      atboot   => true,
      require  => [File["/data/uploads"], Package['nfs-common']],
    }
  }
}
