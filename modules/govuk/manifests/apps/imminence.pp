# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::apps::imminence( $port = '3002', $enable_procfile_worker = true ) {
  govuk::app { 'imminence':
    app_type           => 'rack',
    port               => $port,
    vhost_ssl_only     => true,
    health_check_path  => '/',
    log_format_is_json => true,
    asset_pipeline     => true,
  }

  govuk::procfile::worker { 'imminence':
    enable_service => $enable_procfile_worker,
  }
}
