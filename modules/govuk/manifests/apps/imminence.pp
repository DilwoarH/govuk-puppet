class govuk::apps::imminence( $port = 3002 ) {
  govuk::app { 'imminence':
    app_type          => 'rack',
    port              => $port,
    vhost_ssl_only    => true,
    health_check_path => '/',
  }

  govuk::delayed_job::worker { 'imminence': }
}
