# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::apps::collections_api(
  $enabled = true,
  $port = 3084,
) {
  if $enabled {
    govuk::app { 'collections-api':
      app_type           => 'rack',
      port               => $port,
      vhost_ssl_only     => true,
      health_check_path  => '/healthcheck',
      json_health_check  => true,
      log_format_is_json => true,
      deny_framing       => true,
    }
  }

}
