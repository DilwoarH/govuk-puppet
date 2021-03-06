# == Class: govuk_mtail
#
# Enable and configure Mtail for GOV.UK
#
# Logs are looked up directly from Hiera with the `hiera_array`
# function and the `govuk_mtail::logs` key. If no values are found
# the default Nginx access log is passed to the Mtail class.
#
# === Parameters
#
# [*manage_repo_class*]
#   Whether to use a separate repository to install Statsd
#   Default: false (use 'govuk_ppa' repository)
#
# [*logs*]
#   List of files to monitor
#
# [*port*]
#   HTTP port to listen on. (default "3903")
#
# [*collectd_socketpath*]
#   Path to collectd unixsock to write metrics to.
#
# [*graphite_host_port*]
#   Host:port to graphite carbon server to write metrics to.
#
# [*statsd_hostport*]
#   Host:port to statsd server to write metrics to.
#
# [*metric_push_interval*]
#   Interval between metric pushes, in seconds (default 60)
#
# [*extra_args*]
#   Mtail program extra arguments (default -log_dir /var/log/mtail)
#
class govuk_mtail(
  $manage_repo_class = false,
  $logs = ['/var/log/nginx/access.log'],
  $port = 3903,
  $collectd_socketpath = undef,
  $graphite_host_port = undef,
  $statsd_hostport = undef,
  $metric_push_interval = 60,
  $extra_args = '-log_dir /var/log/mtail',
) {

  validate_bool($manage_repo_class)
  validate_array($logs)

  if $manage_repo_class {
    $repo_class = 'govuk_mtail::repo'
  } else {
    $repo_class = 'govuk_ppa'
  }

#  include $repo_class

  class { '::mtail':
    logs                 => join($logs, ','),
    enabled              => true,
    port                 => $port,
    collectd_socketpath  => $collectd_socketpath,
    graphite_host_port   => $graphite_host_port,
    statsd_hostport      => $statsd_hostport,
    metric_push_interval => $metric_push_interval,
    extra_args           => $extra_args,
#    require              => Class[$repo_class],
  }

  file { '/etc/mtail/nginx_metrics.mtail':
#    ensure  => present,
    ensure => 'absent',
    source => 'puppet:///modules/govuk_mtail/nginx_metrics.mtail',
#    require => File['/etc/mtail'],
#    notify  => Service['mtail'],
  }

  @@icinga::check { "check_mtail_up_${::hostname}":
    ensure              => 'absent',
    check_command       => 'check_nrpe!check_proc_running!mtail',
    service_description => 'mtail not running',
    host_name           => $::fqdn,
    notes_url           => monitoring_docs_url(check-process-running),
  }
}
