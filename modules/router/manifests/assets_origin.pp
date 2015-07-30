# = Class: router::assets_origin
#
# Configure vhost for serving external-facing assets.
#
# === Parameters
#
# [*asset_routes*]
#   Hash of paths => vhost_names.  Each entry will be added as a route in the vhost
#
class router::assets_origin(
  $asset_routes = {},
  $real_ip_header = '',
) {
  $app_domain = hiera('app_domain')
  $enable_ssl = hiera('nginx_enable_ssl', true)

  $vhost_name = "assets-origin.${app_domain}"
  $vhost_alias = 'assets.digital.cabinet-office.gov.uk'

  # suspect we want `protected => false` here
  # once appropriate firewalling is in place?
  nginx::config::site { $vhost_name:
    content => template('router/assets_origin.conf.erb'),
  }

  nginx::config::ssl { $vhost_name:
    certtype => 'wildcard_alphagov'
  }

  nginx::log {
    "${vhost_name}-json.event.access.log":
      json          => true,
      logstream     => present,
      statsd_metric => "${::fqdn_metrics}.nginx_logs.assets-origin.http_%{@fields.status}",
      statsd_timers => [{metric => "${::fqdn_metrics}.nginx_logs.assets-origin.time_request",
                          value => '@fields.request_time'}];
    "${vhost_name}-error.log":
      logstream => present;
  }
}
