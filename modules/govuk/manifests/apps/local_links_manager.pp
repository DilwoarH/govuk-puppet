# Class: govuk::apps::local_links_manager
#
# App to manage the local links within GOV.UK so that
# they can be used for local transactions.
# https://github.com/alphagov/local-links-manager
#
# [*port*]
#   What port should the app run on?
#
# [*enabled*]
#   Should the app exist?
#
# [*errbit_api_key*]
#   Errbit API key used by airbrake
#   Default: undef
#
# [*secret_key_base*]
#   Used to set the app ENV var SECRET_KEY_BASE which is used to configure
#   rails 4.x signed cookie mechanism. If unset the app will be unable to
#   start.
#   Default: undef
#
# [*db_hostname*]
#   The hostname of the database server to use in the DATABASE_URL.
#   Default: undef
#
# [*db_username*]
#   The username to use in the DATABASE_URL.
#
# [*db_password*]
#   The password for the database.
#   Default: undef
#
# [*db_name*]
#   The database name to use in the DATABASE_URL.
#
class govuk::apps::local_links_manager(
  $port = 3121,
  $enabled = false,
  $errbit_api_key = undef,
  $secret_key_base = undef,
  $db_hostname = undef,
  $db_username = 'local_links_manager',
  $db_password = undef,
  $db_name = 'local-links-manager_production',
) {
  $app_name = 'local-links-manager'

  if $enabled {
    govuk::app { $app_name:
      app_type          => 'rack',
      port              => $port,
      vhost_ssl_only    => true,
      health_check_path => '/healthcheck',
    }

    Govuk::App::Envvar {
      app    => $app_name,
    }

    govuk::app::envvar {
      "${title}-ERRBIT_API_KEY":
        varname => 'ERRBIT_API_KEY',
        value   => $errbit_api_key;
      "${title}-SECRET_KEY_BASE":
        varname => 'SECRET_KEY_BASE',
        value   => $secret_key_base;
    }

    if $::govuk_node_class != 'development' {
      govuk::app::envvar::database_url { $app_name:
        type     => 'postgresql',
        username => $db_username,
        password => $db_password,
        host     => $db_hostname,
        database => $db_name,
      }
    }
  }
}
