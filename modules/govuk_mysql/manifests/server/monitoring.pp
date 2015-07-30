# == Class: govuk_mysql::server::monitoring
#
# Set up basic monitoring of mysql
#
class govuk_mysql::server::monitoring {

  package { 'python-mysqldb':
    ensure => installed,
  }

  @@icinga::check { "check_mysqld_running_${::hostname}":
    check_command       => 'check_nrpe!check_proc_running!mysqld',
    service_description => 'mysqld not running',
    host_name           => $::fqdn,
  }

  @@icinga::check::graphite { "check_mysql_connections_${::hostname}":
    target    => "${::fqdn_metrics}.mysql.threads-connected",
    warning   => 250,
    critical  => 350,
    desc      => 'mysql high cur conn',
    host_name => $::fqdn,
  }

  collectd::plugin::mysql { 'lazy_eval_workaround':
    master  => false,
    slave   => false,
    require => Class['mysql::server'],
  }

}
