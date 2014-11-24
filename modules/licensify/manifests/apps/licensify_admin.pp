# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class licensify::apps::licensify_admin(
  $port = 9500,
  $aws_ses_access_key = '',
  $aws_ses_secret_key = '',
) inherits licensify::apps::base {

  govuk::app { 'licensify-admin':
    app_type          => 'procfile',
    port              => $port,
    health_check_path => '/login',
    require           => File['/etc/licensing'],
  }

  licensify::apps::envvars { 'licensify-admin':
    app                => 'licensify-admin',
    aws_ses_access_key => $aws_ses_access_key,
    aws_ses_secret_key => $aws_ses_secret_key,
  }

  licensify::build_clean { 'licensify-admin': }
}
