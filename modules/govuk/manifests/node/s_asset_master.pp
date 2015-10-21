# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::node::s_asset_master (
  $run_virus_scan_clean_hour = '4',
) inherits govuk::node::s_asset_base {

  file { '/var/run/virus_scan':
    ensure => directory,
    owner  => 'assets',
  }

  # daemontools provides setlock
  $cron_requires = [
    File[
      '/usr/local/bin/virus_scan.sh',
      '/var/run/virus_scan'
    ],
    Package['daemontools'],
  ]

  cron { 'virus-scan-incoming':
    user    => 'assets',
    minute  => '*/2',
    command => '/usr/bin/setlock -n /var/run/virus_scan/incoming.lock /usr/local/bin/virus_scan.sh /mnt/uploads/whitehall/incoming /mnt/uploads/whitehall/infected /mnt/uploads/whitehall/clean',
    require => $cron_requires,
  }

  cron { 'virus-scan-clean':
    user    => 'assets',
    hour    => $run_virus_scan_clean_hour,
    minute  => '18',
    command => '/usr/bin/setlock -n /var/run/virus_scan/clean.lock /usr/local/bin/virus_scan.sh /mnt/uploads/whitehall/clean /mnt/uploads/whitehall/infected',
    require => $cron_requires,
  }

  cron { 'virus-scan-incoming-draft':
    user    => 'assets',
    minute  => '*/2',
    command => '/usr/bin/setlock -n /var/run/virus_scan/incoming-draft.lock /usr/local/bin/virus_scan.sh /mnt/uploads/whitehall/draft-incoming /mnt/uploads/whitehall/draft-infected /mnt/uploads/whitehall/draft-clean',
    require => $cron_requires,
  }

  cron { 'virus-scan-clean-draft':
    user    => 'assets',
    hour    => $run_virus_scan_clean_hour,
    minute  => '48',
    command => '/usr/bin/setlock -n /var/run/virus_scan/clean-draft.lock /usr/local/bin/virus_scan.sh /mnt/uploads/whitehall/draft-clean /mnt/uploads/whitehall/draft-infected',
    require => $cron_requires,
  }
}
