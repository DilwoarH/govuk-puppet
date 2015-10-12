# == Class: govuk::deploy::config
#
# Configuration resources for apps. Changes to the contents of these will
# require an app to be restarted. For example, to pick up changes to
# environment variables or centralised unicorn options.
#
# === Parameters
#
# [*errbit_environment_name*]
#   Name of the environment to be included in Errbit error reports.
#
# [*govuk_env*]
#   GOV.UK environment
#   Default: 'production'
#
class govuk::deploy::config(
  $errbit_environment_name = '',
  $govuk_env = 'production',
){
  harden::limit { 'deploy-nofile':
    domain => 'deploy',
    type   => '-', # set both hard and soft limits
    item   => 'nofile',
    value  => '16384',
  }

  harden::limit { 'deploy-nproc':
    domain => 'deploy',
    type   => '-',
    item   => 'nproc',
    value  => '1024',
  }

  file { '/etc/govuk/unicorn.rb':
    ensure  => present,
    source  => 'puppet:///modules/govuk/etc/govuk/unicorn.rb',
    require => File['/etc/govuk'],
  }

  # govuk_spinup is a wrapper script used to start up apps that form part of
  # the GOV.UK stack. It exports various environment variables used by
  # Rails/A. N. Other Application Framework, and starts up either
  # Procfile-based or unicorn applications.
  file { '/usr/local/bin/govuk_spinup':
    ensure => present,
    source => 'puppet:///modules/govuk/bin/govuk_spinup',
    mode   => '0755',
  }

  # govuk_setenv is a simple script that loads the environment for a GOV.UK
  # application and execs its arguments
  # daemontools provides envdir, used by govuk_setenv
  file { '/usr/local/bin/govuk_setenv':
    ensure  => present,
    content => template('govuk/bin/govuk_setenv'),
    mode    => '0755',
    require => Package['daemontools'],
  }

  # /etc/govuk/env.d is an envdir. Each file and its contents should denote
  # the name and value of an environment variable that should be exported
  file { '/etc/govuk/env.d':
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
    require => File['/etc/govuk'],
  }

  $app_domain = hiera('app_domain')
  $asset_root = hiera('asset_root')
  $website_root = hiera('website_root')

  govuk::envvar {
    'GOVUK_ENV': value => $govuk_env;
    'NODE_ENV': value => $govuk_env;
    'RACK_ENV':  value => $govuk_env;
    'RAILS_ENV': value => $govuk_env;

    'ERRBIT_ENVIRONMENT_NAME': value   => $errbit_environment_name;
    'GOVUK_APP_DOMAIN': value          => $app_domain;
    'GOVUK_ASSET_HOST': value          => $asset_root;
    'GOVUK_ASSET_ROOT': value          => $asset_root;
    'GOVUK_WEBSITE_ROOT': value        => $website_root;
  }
}
