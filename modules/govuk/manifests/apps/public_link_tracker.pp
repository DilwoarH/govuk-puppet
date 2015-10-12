# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::apps::public_link_tracker {
  $app_domain = hiera('app_domain')

  $private_external_link_tracker = "external-link-tracker.${app_domain}"

  $app_name = 'public-link-tracker'
  $full_domain = "${app_name}.${app_domain}"

  nginx::config::vhost::proxy { $full_domain:
    ensure    => absent,
    to        => [$private_external_link_tracker],
    to_ssl    => true,
    protected => false,
    ssl_only  => false,
  }
}
