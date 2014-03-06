class monitoring {

  package { 'python-rrdtool':
    ensure => 'installed',
  }

  include icinga
  include nsca::server

  include govuk::htpasswd

  # Include monitoring-server-only checks
  include monitoring::checks

  $enable_ssl = str2bool(extlookup('nginx_enable_ssl', 'yes'))

  nginx::config::ssl { 'monitoring':
    certtype => 'wildcard_alphagov_mgmt',
  }
  nginx::config::site { 'monitoring':
    content => template('monitoring/nginx.conf.erb'),
  }
  nginx::log {
    'monitoring-json.event.access.log':
      json      => true,
      logstream => present;
    'monitoring-access.log':
      logstream => absent;
    'monitoring-error.log':
      logstream => present;
  }

  file { '/var/www/monitoring':
    ensure => directory,
  }

  file { '/var/www/monitoring/index.html':
    ensure  => present,
    source  => 'puppet:///modules/monitoring/index.html',
    require => File['/var/www/monitoring'],
  }

}
