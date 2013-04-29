# == Type: loadbalancer::balance
#
# Install a loadbalancer configuration for the specified hosts.
#
# By default, this will install an Nginx load balancing proxy configuration
# for "$title.$app_domain". You can specify additional server names to listen
# to using the `aliases` parameter.
#
# === Parameters
#
# [*servers*]
#   Array of IPs or hostname of the upstream servers.
#
# [*aliases*]
#   Additional server names for the loadbalanced service.
#
# [*https_only*]
#   Only serve the loadbalanced service over HTTPS.
#   Default: false
#
# [*internal_only*]
#   Limit access to the loadbalanced service to internal IP address only.
#   Default: false
#
# [*maintenance*]
#   File path under `/usr/share/nginx/html` which will be served with a 503
#   response for all requests. Intended to be triggered with a feature flag
#   by the module caller.
#   FIXME: Revert this hack after Licensify maint (30/04/13)
#   Default: ''
#
define loadbalancer::balance(
    $servers,
    $aliases = [],
    $https_only = false,
    $internal_only = false,
    $vhost = $title,
    $read_timeout = 60,
    $maintenance = ''
) {
  $vhost_suffix = extlookup('app_domain')
  $vhost_real = "${vhost}.${vhost_suffix}"

  nginx::config::ssl { $vhost_real:
    certtype => 'wildcard_alphagov',
  }

  nginx::config::site { $vhost_real:
    content => template('loadbalancer/nginx_balance.conf.erb'),
  }

  nginx::log {
    "${vhost_real}-json.event.access.log":
      json      => true,
      logstream => true;
    "${vhost_real}-access.log":
      logstream => false;
    "${vhost_real}-error.log":
      logstream => true;
  }
}
