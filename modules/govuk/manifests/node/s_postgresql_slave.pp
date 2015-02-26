# == Class: govuk::node::s_postgresql_slave
#
# PostgreSQL slave node for main cluster.
#
# === Parameters:
#
# [*master_password*]
#   Proxied to `govuk_postgresql::server::slave` so that we can set
#   per-cluster passwords in a single hiera credentials file.
#
class govuk::node::s_postgresql_slave (
  $master_password,
) inherits govuk::node::s_postgresql_base {
  class { 'govuk_postgresql::server::slave':
    master_password => $master_password,
  }

  # FIXME: Remove after AutoPostgreSQLBackup script has been removed from these machines
  file { ['/etc/cron.daily/autopostgresqlbackup',
          '/etc/default/autopostgresqlbackup',
          '/etc/postgresql-backup-post',
          '/etc/postgresql-backup-pre', ]:
        ensure => absent,
  }

}
