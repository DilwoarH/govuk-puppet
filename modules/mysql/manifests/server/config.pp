class mysql::server::config ( $error_log ) {
  $debian_sys_maint_password = extlookup('mysql_debian_sys_maint', '')

  file { '/etc/mysql':
    ensure => 'directory',
  }

  file { '/etc/mysql/my.cnf':
    content => template('mysql/etc/mysql/my.cnf.erb'),
  }

  file { '/etc/mysql/conf.d':
    ensure  => 'directory',
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { '/etc/mysql/debian.cnf':
    content => template('mysql/etc/mysql/debian.cnf.erb'),
    mode    => '0600',
  }

  # MySQL's server-id MUST be unique for every server in a cluster. That is,
  # each and every server must have a server-id that doesn't conflict with any
  # other server in the cluster.
  #
  # lib/facter/server_id.rb in this module provides a nice way of doing this,
  # by using the IP address of the machine to compute a server-id, and exposes
  # this as a facter fact, "mysql_server_id".
  file { '/etc/mysql/conf.d/serverid.cnf':
    content => "
[mysqld]
server-id = ${::mysql_server_id}
",
  }

}
