class govuk::apps::whitehall::db {
  $whitehall_admin_password = extlookup('mysql_whitehall_admin', '')
  $mysql_password = extlookup('mysql_root', '')

  govuk_mysql::server::db { 'whitehall_production':
    user          => 'whitehall',
    password      => $whitehall_admin_password,
    root_password => $mysql_password,
  }
}
