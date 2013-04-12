class govuk::node::s_asset_slave inherits govuk::node::s_asset_base {
  include assets::user
  include daemontools # provides setlock

  cron { 'virus-check':
    ensure => 'absent'
  }

  file { '/data/master-uploads':
    ensure  => 'directory',
    owner   => 'assets',
    group   => 'assets',
    mode    => '0755',
  }

  $app_domain = extlookup('app_domain')

  mount { '/data/master-uploads':
    ensure  => 'mounted',
    device  => "asset-master.${app_domain}:/mnt/uploads",
    fstype  => 'nfs',
    options => 'rw,soft',
    atboot  => true,
    require => File['/data/master-uploads'],
  }

  file { '/var/run/whitehall-assets':
    ensure => 'directory',
    owner  => 'assets',
    group  => 'assets',
  }

  cron { 'sync-assets-from-master':
    user      => 'assets',
    minute    => '*/30',
    command   => '/usr/bin/setlock -n /var/run/whitehall-assets/sync.lock /usr/local/bin/sync_assets_from_master.rb /data/master-uploads /mnt/uploads whitehall/clean whitehall/incoming whitehall/infected',
  }

  cron { 'sync-assets-from-master-draft':
    user      => 'assets',
    minute    => '*/30',
    command   => '/usr/bin/setlock -n /var/run/whitehall-assets/sync-draft.lock /usr/local/bin/sync_assets_from_master.rb /data/master-uploads /mnt/uploads whitehall/draft-clean whitehall/draft-incoming whitehall/draft-infected',
  }
}
