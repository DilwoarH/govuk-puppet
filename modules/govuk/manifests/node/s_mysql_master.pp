class govuk::node::s_mysql_master inherits govuk::node::s_base {
  $root_password = extlookup('mysql_root', '')
  $replica_password = extlookup('mysql_replica_password', '')

  class { 'mysql::server':
    root_password => $root_password,
  }
  class { 'mysql::server::binlog':
    root_password => $root_password,
  }

  mysql::user { 'replica_user':
    root_password  => $root_password,
    user_password  => $replica_password,
    privileges     => 'SUPER, REPLICATION CLIENT, REPLICATION SLAVE',
  }

  class {'govuk::apps::need_o_tron::db':     require => Class['mysql::server'] }
  class {'govuk::apps::release::db':         require => Class['mysql::server'] }
  class {'govuk::apps::signon::db':          require => Class['mysql::server'] }
  class {'govuk::apps::tariff_api::db':      require => Class['mysql::server'] }
  class {'govuk::apps::tariff_demo_api::db': require => Class['mysql::server'] }
  class {'govuk::apps::transition::db':      require => Class['mysql::server'] }
  class {'govuk::apps::whitehall::db':       require => Class['mysql::server'] }

  mysql::user { 'whitehall_fe':
    root_password => $root_password,
    user_password => extlookup('mysql_whitehall_frontend', ''),
    db            => 'whitehall_production',
    privileges    => 'SELECT',
    require       => Class['govuk::apps::whitehall::db'],
  }

}
