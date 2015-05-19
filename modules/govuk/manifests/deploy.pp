# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::deploy (
    $setup_actionmailer_ses_config = true,
    $aws_ses_smtp_host = 'UNSET',
    $aws_ses_smtp_username = 'UNSET',
    $aws_ses_smtp_password = 'UNSET',
){
  include govuk::logging
  include govuk::python
  include harden
  include unicornherder

  validate_bool($setup_actionmailer_ses_config)

  anchor { 'govuk::deploy::begin': }

  # These resources are required, but should not refresh apps.
  class { 'govuk::deploy::setup':
    setup_actionmailer_ses_config => $setup_actionmailer_ses_config,
    aws_ses_smtp_host             => $aws_ses_smtp_host,
    aws_ses_smtp_username         => $aws_ses_smtp_username,
    aws_ses_smtp_password         => $aws_ses_smtp_password,
    require                       => Anchor['govuk::deploy::begin'],
  }

  # These resources should refresh apps.
  class { 'govuk::deploy::config':
    require => Class['govuk::deploy::setup'],
  }

  anchor { 'govuk::deploy::end':
    # FIXME: Uncomment this subscribe line once deployed to all environments
    #subscribe => Class['govuk::deploy::config'],
    require   => Class['unicornherder'],
  }
}
