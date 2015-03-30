# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::apps::govuk_crawler_worker (
  $airbrake_api_key = '',
  $airbrake_endpoint = '',
  $airbrake_env = '',
  $amqp_pass = 'guest',
  $enabled   = false,
  $mirror_root = '/mnt/crawler_worker',
  $port = 3074,
) {
  if $enabled {
    Govuk::App::Envvar {
      app => 'govuk_crawler_worker',
    }

    $blacklist_paths = ['/trade-tariff', '/licence-finder',
      '/business-finance-support-finder', '/government/uploads',
      '/apply-for-a-licence', '/search', '/government/announcements.atom',
      '/government/publications.atom']

    govuk::app::envvar {
      'AIRBRAKE_API_KEY':
        value => $airbrake_api_key;
      'AIRBRAKE_ENDPOINT':
        value => $airbrake_endpoint;
      'AIRBRAKE_ENV':
        value => $airbrake_env;
      'AMQP_ADDRESS':
        value => "amqp://govuk_crawler_worker:${amqp_pass}@rabbitmq-1:5672/";
      'AMQP_EXCHANGE':
        value => 'govuk_crawler_exchange';
      'AMQP_MESSAGE_QUEUE':
        value => 'govuk_crawler_queue';
      'BLACKLIST_PATHS':
        value => join($blacklist_paths, ',');
      'HTTP_PORT':
        value => $port;
      'REDIS_ADDRESS':
        value => 'redis-1:6379';
      'REDIS_KEY_PREFIX':
        value => 'govuk_crawler_worker';
      'ROOT_URLS':
        value => 'https://www.gov.uk/,https://assets.digital.cabinet-office.gov.uk/';
      'MIRROR_ROOT':
        value => $mirror_root;
      'TTL_EXPIRE_TIME':
        value => '24h';
    }

    file { $mirror_root:
      ensure => directory,
      mode   => '0755',
      owner  => 'deploy',
      group  => 'deploy',
    }

    govuk::app { 'govuk_crawler_worker':
      app_type           => 'bare',
      log_format_is_json => true,
      port               => $port,
      command            => './govuk_crawler_worker -json',
      health_check_path  => '/healthcheck',
    }
  }
}
