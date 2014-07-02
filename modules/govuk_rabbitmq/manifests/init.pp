class govuk_rabbitmq {
  include govuk_rabbitmq::firewalls
  include govuk_rabbitmq::logging
  include govuk_rabbitmq::monitoring
  include govuk_rabbitmq::repo
  include '::rabbitmq'

  rabbitmq_plugin { 'rabbitmq_stomp':
    ensure => present,
  }

  rabbitmq_plugin {'rabbitmq_management':
    ensure => present,
  }

  class { 'collectd::plugin::rabbitmq': }
}
