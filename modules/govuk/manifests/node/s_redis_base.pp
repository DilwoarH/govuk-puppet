# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::node::s_redis_base {
  include govuk::node::s_base

  $redis_port = 6379
  $redis_max_memory = floor($::memorysize_mb / 4 * 3)

  class { 'redis':
    maxmemory       => "${redis_max_memory}mb",
    manage_repo     => true,
    package_ensure  => '4:4.0.8-1chl1~trusty1',
    port            => $redis_port,
    slowlog_max_len => '1024',
  }

  $redis_mem_warn = $redis_max_memory * 0.8
  $redis_mem_crit = $redis_max_memory * 0.9

  @@icinga::check::graphite { "check_redis_memory_${::hostname}":
    target    => "${::fqdn_metrics}.redis_info.bytes-used_memory",
    warning   => to_bytes("${redis_mem_warn}M"),
    critical  => to_bytes("${redis_mem_crit}M"),
    desc      => 'redis memory usage',
    notes_url => monitoring_docs_url(redis),
    host_name => $::fqdn,
  }

  @@icinga::check::graphite { "check_redis_connected_clients_${::hostname}":
    target    => "${::fqdn_metrics}.redis_info.gauge-connected_clients",
    warning   => 1000,
    critical  => 2000,
    desc      => 'redis connected clients',
    notes_url => monitoring_docs_url(redis),
    host_name => $::fqdn,
  }

  class { 'collectd::plugin::redis': }
}
