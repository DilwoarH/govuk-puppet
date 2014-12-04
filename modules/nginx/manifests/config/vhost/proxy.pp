# == Define: nginx::config::vhost::proxy
#
# Simple Nginx vhost which reverse proxies to another location.
#
# === Parameters
#
# [*to*]
#   Array of upstream servers to reverse proxy to.
#
# [*to_ssl*]
#   Boolean whether the upstream servers are running on HTTPS/443.
#   Default: false
#
# TODO: More docs!
#
define nginx::config::vhost::proxy(
  $to,
  $to_ssl = false,
  $aliases = [],
  $extra_config = '',
  $extra_app_config = '',
  $intercept_errors = false,
  $deny_framing = false,
  $protected = true,
  $root = "/data/vhost/${title}/current/public",
  $ssl_only = false,
  $logstream = present,
  $is_default_vhost = false,
  $ssl_manage_cert = true,  # This is a *horrible* hack to make EFG work.
                            # Please, please, remove when we have a
                            # sensible means of managing SSL certificates.
  $hidden_paths = [],
  $ensure = 'present',
) {
  validate_re($ensure, '^(absent|present)$', 'Invalid ensure value')

  include govuk::htpasswd

  $proxy_vhost_template = 'nginx/proxy-vhost.conf'
  $logpath = '/var/log/nginx'
  $access_log = "${name}-access.log"
  $json_access_log = "${name}-json.event.access.log"
  $error_log = "${name}-error.log"
  $title_escaped = regsubst($title, '\.', '_', 'G')

  $to_port = $to_ssl ? {
    true    => ':443',
    default => '',
  }
  $to_proto = $to_ssl ? {
    true    => 'https://',
    default => 'http://',
  }

  # Whether to enable SSL. Used by template.
  $enable_ssl = hiera('nginx_enable_ssl', true)
  # Whether to enable basic auth protection. Used by template.
  $enable_basic_auth = hiera('nginx_enable_basic_auth', true)

  if $ssl_manage_cert {
    nginx::config::ssl { $name: certtype => 'wildcard_alphagov' }
  }
  nginx::config::site { $name:
    ensure  => $ensure,
    content => template($proxy_vhost_template),
  }

  $counter_basename = "${::fqdn_underscore}.nginx_logs.${title_escaped}"

  $logstream_ensure = $ensure ? {
    'present' => $logstream,
    default   => $ensure,
  }

  nginx::log {
    $json_access_log:
      json          => true,
      logpath       => $logpath,
      logstream     => $logstream_ensure,
      statsd_metric => "${counter_basename}.http_%{@fields.status}",
      statsd_timers => [{metric => "${counter_basename}.time_request",
                          value => '@fields.request_time'}];
    $error_log:
      logpath   => $logpath,
      logstream => $logstream_ensure;
  }

  statsd::counter { "${counter_basename}.http_500": }

  @@icinga::check::graphite { "check_nginx_5xx_${title}_on_${::hostname}":
    ensure    => $ensure,
    target    => "transformNull(stats.${counter_basename}.http_5xx,0)",
    warning   => 0.05,
    critical  => 0.1,
    from      => '3minutes',
    desc      => "${title} nginx 5xx rate too high",
    host_name => $::fqdn,
    notes_url => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html?highlight=nagios#nginx-5xx-rate-too-high-for-many-apps-boxes',
  }

}
