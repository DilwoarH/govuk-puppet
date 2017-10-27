# == Class: govuk_ghe_vpn
#
# Configure the VPN connection to GitHub Enterprise (GHE)
#
# === Parameters
#
# Document parameters here.
#
# [*url*]
#   VPN endpoint to connect to
#
# [*username*]
#   VPN username
#
# [*password*]
#   VPN password
#
class govuk_ghe_vpn (
  $url,
  $username,
  $password,
  $openconnect_version = 'present',
) {

  host { 'github.digital.cabinet-office.gov.uk':
    ensure  => 'absent',
    ip      => '192.168.9.110',
    comment => 'Ignore VPN DNS and set static host for GHE',
  }

  class { '::openconnect':
    ensure    => 'absent',
    url       => $url,
    user      => $username,
    pass      => $password,
    dnsupdate => false,
    version   => $openconnect_version,
  }

  @@icinga::check { "check_openconnect_upstart_up_${::hostname}":
    ensure              => 'absent',
    check_command       => 'check_nrpe!check_upstart_status!openconnect',
    service_description => 'openconnect upstart up',
    host_name           => $::fqdn,
  }

  @icinga::nrpe_config { 'check_ghe_responding':
    ensure => 'absent',
    source => 'puppet:///modules/govuk_ghe_vpn/nrpe_check_ghe.cfg',
  }

  @@icinga::check { "check_ghe_connection_on_${::hostname}":
    ensure              => 'absent',
    check_command       => 'check_nrpe_1arg!check_ghe_responding',
    notes_url           => monitoring_docs_url(github-enterprise-connectivity),
    service_description => 'Connection to GitHub Enterprise over HTTPS',
    host_name           => $::fqdn,
  }
}
