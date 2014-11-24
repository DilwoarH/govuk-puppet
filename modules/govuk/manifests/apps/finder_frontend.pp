# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::apps::finder_frontend(
  $port = 3062,
  $enabled = false,
) {

  if str2bool($enabled) {
    govuk::app { 'finder-frontend':
      app_type              => 'rack',
      port                  => $port,
      health_check_path     => '/cma-cases',
      log_format_is_json    => true,
      asset_pipeline        => true,
      asset_pipeline_prefix => 'finder-frontend',
    }
  }
}
