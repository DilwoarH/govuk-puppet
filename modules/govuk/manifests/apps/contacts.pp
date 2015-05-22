# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::apps::contacts(
  $enabled = true,
  $vhost = 'contacts',
  $port = 3051,
  $vhost_protected = undef,
  $extra_aliases = []
) {

  validate_array($extra_aliases)

  if $enabled {
    govuk::app { 'contacts':
      app_type              => 'rack',
      vhost                 => $vhost,
      port                  => $port,
      health_check_path     => '/healthcheck',
      vhost_protected       => $vhost_protected,
      asset_pipeline        => true,
      asset_pipeline_prefix => 'contacts-assets',
      vhost_aliases         => $extra_aliases,
      nginx_extra_config    => '
        # Don\'t ask for basic auth on SSO API pages so we can sync
        # permissions.
        location /auth/gds {
          auth_basic off;
          try_files $uri @app;
        }
      ',
    }
  }
}
