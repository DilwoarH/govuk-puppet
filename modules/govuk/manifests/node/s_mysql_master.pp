# Configure a MySQL Master server for GOV.UK
#
# [*mysql_bouncer*]
#   Password for the bouncer user which grants read-only
#   access to the transition_production database
#
class govuk::node::s_mysql_master (
  $mysql_bouncer = ''
) inherits govuk::node::s_base {
  $replica_password = hiera('mysql_replica_password', '')
  $root_password = hiera('mysql_root', '')

  class { 'govuk_mysql::server':
    root_password => $root_password,
  }
  class { 'govuk_mysql::server::master':
    replica_pass => $replica_password,
  }

  class { [
    'govuk::apps::collections_publisher::db',
    'govuk::apps::contacts::db',
    'govuk::apps::content_planner::db',
    'govuk::apps::release::db',
    'govuk::apps::search_admin::db',
    'govuk::apps::signon::db',
    'govuk::apps::tariff_admin::db',
    # FIXME: tariff_api::db is ensured absent. It can be removed once the DB has gone everywhere
    'govuk::apps::tariff_api::db',
    'govuk::apps::tariff_api_temporal::db',
    'govuk::apps::transition::db',
    ]:
  }

  govuk_mysql::user { 'bouncer@%':
    ensure        => absent,
    password_hash => mysql_password($mysql_bouncer),
    table         => 'transition_production.*',
    privileges    => ['SELECT'],
  }

  collectd::plugin::tcpconn { 'mysql':
    incoming => 3306,
    outgoing => 3306,
  }

  Govuk::Mount['/var/lib/mysql'] -> Class['govuk_mysql::server']
}
