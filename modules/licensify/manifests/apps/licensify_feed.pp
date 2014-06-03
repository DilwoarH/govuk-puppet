class licensify::apps::licensify_feed(
  $port = 9400,
  $aws_ses_access_key = '',
  $aws_ses_secret_key = '',
) inherits licensify::apps::base {

  govuk::app { 'licensify-feed':
    app_type        => 'procfile',
    port            => $port,
    vhost_protected => true,
    require         => File['/etc/licensing'],
  }

  licensify::apps::envvars { 'licensify-feed':
    app                => 'licensify-feed',
    aws_ses_access_key => $aws_ses_access_key,
    aws_ses_secret_key => $aws_ses_secret_key,
  }

  licensify::build_clean { 'licensify-feed': }
}
