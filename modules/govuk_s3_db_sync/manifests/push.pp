# == Class: govuk_s3_db_sync::push 
#
# Push a MongoDB to AWS S3
#
# === Parameters:
#
# [*aws_access_key_id*]
#   AWS access key
#
# [*aws_secret_access_key*]
#   AWS secret access key
#
# [*aws_region*]
#   AWS region for the S3 bucket
#
# [*cron*]
#   Defines whether to enable the cron job. Value
#   should be true or false
#
# [*backup_dir*]
#   Defines local directory to write data to
#
# [*env_dir*]
#   Defines directory for the environment
#   variables
#
# [*s3_bucket*]
#   Defines the AWS S3 bucket where the backups
#   will be uploaded. It should be created by the
#   user
#
# [*user*]
#   Defines the system user that will be created
#   to run the backups
#
# [*alert_hostname*]
#   The hostname of the alert service, to send ncsa notifications.
#
class govuk_s3_db_sync::push(
  $aws_access_key_id = undef,
  $aws_secret_access_key = undef,
  $aws_region = 'eu-west-1',
  $backup_dir = '/var/lib/mongo/.dumps'
  $cron = true,
  $env_dir = '/etc/govuk_s3_db_sync',
  $s3_bucket  = undef,
  $user = 'govuk-backup',
  $alert_hostname = 'alert.cluster',
){

  file { $backup_dir:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0750',
  }

  file { [$env_dir,"${env_dir}/env.d"]:
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0770',
  }

  file { "${env_dir}/env.d/AWS_SECRET_ACCESS_KEY":
    content => $aws_secret_access_key,
    owner   => $user,
    group   => $user,
    mode    => '0640',
  }

  file { "${env_dir}/env.d/AWS_ACCESS_KEY_ID":
    content => $aws_access_key_id,
    owner   => $user,
    group   => $user,
    mode    => '0640',
  }

  file { "${env_dir}/env.d/AWS_REGION":
    content => $aws_region,
    owner   => $user,
    group   => $user,
    mode    => '0640',
  }

  # cron
  if $govuk_s3_db_sync::add_push_cron {
    include govuk_s3_db_sync::push_cron
  }

  # monitoring
  $threshold_secs = 28 * 3600
  $service_desc = 'Mongodb s3backup'

  # push script
  file { '/usr/local/bin/mongo-to-s3.sh':
    ensure => present,
    mode   => '0755',
    owner  => 'govuk-backup',
    group  => 'govuk-backup',
    source => 'puppet:///modules/govuk_s3_db_sync/mongo-to-s3.sh',
  }

  @@icinga::passive_check { "check_mongodb_s3backup-${::hostname}":
    service_description => $service_desc,
    freshness_threshold => $threshold_secs,
    host_name           => $::fqdn,
    notes_url           => monitoring_docs_url(backup-passive-checks),
  }
}
