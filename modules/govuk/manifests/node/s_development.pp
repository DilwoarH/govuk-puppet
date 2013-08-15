class govuk::node::s_development {
  include base

  include assets::user
  include base_packages
  include fonts
  include golang
  include hosts::development
  include imagemagick
  include mongodb::server
  include mysql::client
  include nodejs
  include puppet
  include rabbitmq
  include redis
  include tmpreaper
  include users
  include pip
  include virtualenv

  include govuk::deploy
  include govuk::envsys
  include govuk::repository
  include govuk::testing_tools

  include rbenv
  rbenv::version { '1.9.3-p392':
    bundler_version => '1.3.5'
  }
  rbenv::alias { '1.9.3':
    to_version => '1.9.3-p392'
  }

  class {
    'govuk::apps::bouncer':               vhost_protected => false;
    'govuk::apps::businesssupportfinder': vhost_protected => false;
    'govuk::apps::calculators':           vhost_protected => false;
    'govuk::apps::calendars':             vhost_protected => false;
    'govuk::apps::datainsight_frontend':  vhost_protected => false;
    'govuk::apps::designprinciples':      vhost_protected => false;
    'govuk::apps::feedback':              vhost_protected => false;
    'govuk::apps::frontend':              vhost_protected => false;
    'govuk::apps::licencefinder':         vhost_protected => false;
    'govuk::apps::limelight':             vhost_protected => true;
    'govuk::apps::smartanswers':          vhost_protected => false;
    'govuk::apps::tariff':                vhost_protected => false;
    'govuk::apps::transaction_wrappers':  vhost_protected => false;
    'govuk::apps::contentapi':            vhost_protected => false;
    'govuk::apps::backdrop_read':         vhost_protected => true;
    'govuk::apps::backdrop_write':        vhost_protected => false;
    'govuk::apps::backdrop_ga_collector': ;
    'govuk::apps::backdrop_ga_realtime_collector': ;
  }

  include govuk::apps::asset_manager
  include govuk::apps::canary_backend
  include govuk::apps::canary_frontend
  include govuk::apps::efg
  include govuk::apps::errbit
  include govuk::apps::fact_cave
  include govuk::apps::govuk_delivery
  include govuk::apps::imminence
  include govuk::apps::kibana
  include govuk::apps::need_o_tron
  include govuk::apps::panopticon
  include govuk::apps::publicapi
  include govuk::apps::publisher
  include govuk::apps::redirector
  include govuk::apps::release
  include govuk::apps::search
  include govuk::apps::signon
  include govuk::apps::static
  include govuk::apps::support
  include govuk::apps::tariff_api
  include govuk::apps::transactions_explorer
  include govuk::apps::transition
  include govuk::apps::travel_advice_publisher
  class { 'govuk::apps::whitehall':
    configure_admin    => true,
    configure_frontend => true,
    vhost_protected    => false,
  }
  class { 'govuk::apps::fco_services':
    vhost_protected => false,
    vhost_aliases   => [
      'www.pay-legalisation-post.service',
      'www.pay-legalisation-drop-off.service',
      'www.deposit-foreign-marriage.service',
      'www.pay-foreign-marriage-certificates.service',
      'www.pay-register-death-abroad.service',
      'www.pay-register-birth-abroad.service',
    ],
  }

  include datainsight::config::google_oauth

  # Java 6 is deprecated in precise, so use Oracle's Java 7
  case $::lsbdistcodename {
    'lucid': {
      include java::sun6::jdk
      include java::sun6::jre

      class { 'java::set_defaults':
        jdk => 'sun6',
        jre => 'sun6',
      }
    }
    'precise': {
      include java::oracle7::jdk
      include java::oracle7::jre

      class { 'java::set_defaults':
        jdk => 'oracle7',
        jre => 'oracle7',
      }
    }
    default: {
      fail("Unknown distribution: ${::lsbdistcodename}. Can't install java")
    }
  }

  class { 'elasticsearch':
    version            => "0.20.6-ppa1~${::lsbdistcodename}1",
    cluster_name       => 'govuk-development',
    heap_size          => '64m',
    number_of_shards   => '1',
    number_of_replicas => '0',
  }

  include nginx

  nginx::config::vhost::default { 'default': }
  nginx::config::site { 'development':
    source => 'puppet:///modules/nginx/development',
  }

  $mysql_password = ''
  class { 'mysql::server':
    root_password => $mysql_password
  }
  include mysql::server::development

  Mysql::Server::Db {
    root_password => $mysql_password,
    remote_host   => 'localhost',
  }

  mysql::server::db {
    [
      'datainsights_todays_activity',
      'datainsight_weekly_reach',
      'datainsight_weekly_reach_test',
      'datainsights_format_success',
      'datainsights_format_success_test',
      'datainsight_insidegov',
      'datainsight_insidegov_test',
    ]:
      user     => 'datainsight',
      password => '';

    [
      'efg_development',
      'efg_test',
      'efg_test1',
      'efg_test2',
      'efg_test3',
      'efg_test4',
      'efg_il0',
    ]:
      user     => 'efg',
      password => 'efg';

    ['fact_cave_development', 'fact_cave_test']:
      user     => 'fact_cave',
      password => 'fact_cave';

    'fco_development':
      user     => 'fco',
      password => '';

    'needotron_development':
      user     => 'needotron',
      password => '';

    ['panopticon_development', 'panopticon_test']:
      user     => 'panopticon',
      password => 'panopticon';

    ['release_development', 'release_test']:
      user     => 'release',
      password => 'release';

    [
      'signonotron2_development',
      'signonotron2_test',
      'signonotron2_integration_test',
    ]:
      user     => 'signonotron2',
      password => '';

    ['tariff_development', 'tariff_test']:
      user     => 'tariff',
      password => 'tariff';

    ['tariff_temporal_development', 'tariff_temporal_test']:
      user     => 'tariff',
      password => 'tariff';

    ['transition_development', 'transition_test']:
      user     => 'transition',
      password => 'transition';

    [
      'whitehall_development',
      'whitehall_test',
      'whitehall_test1',
      'whitehall_test2',
      'whitehall_test3',
      'whitehall_test4',
    ]:
      user     => 'whitehall',
      password => 'whitehall';
  }

  package {
    'foreman':        ensure => '0.27.0',    provider => gem;
    'sqlite3':        ensure => 'installed'; # gds-sso uses sqlite3 to run its test suite
    'wbritish-small': ensure => installed;
  }

  file { [ '/var/tmp/datainsight-everything-recorder.json' ]:
    ensure  => present,
    owner   => 'vagrant',
    group   => 'vagrant',
  }

  file { [ '/var/data', '/var/data/datainsight', '/var/data/datainsight/everything' ]:
    ensure  => directory,
    owner   => 'vagrant',
    group   => 'vagrant',
  }

}
