# == Class: Govuk_mysql::Xtrabackup::Backup
#
# Creates base and incremental backups which are streamed to an S3 bucket.
# Based upon this MariaDB blog post: https://mariadb.com/blog/streaming-mariadb-backups-cloud
#
# === Parameters
#
# [*aws_access_key_id*]
#   The AWS access key used to access the S3 bucket.
#
# [*aws_secret_access_key*]
#   The AWS secret access key used to access the S3 bucket.
#
# [*aws_region*]
#   The region where the S3 bucket lives.
#
# [*s3_bucket_name*]
#   The unique name of the S3 bucket.
#
# [*encryption_key*]
#   The encryption key used to encrypt the backups.
#
# [*base_backup_cron_minute*]
#   The minute(s) that the daily base backup(s) run(s).
#
# [*base_backup_cron_hour*]
#   The hour(s) that the daily base backup(s) run(s).
#
# [*incremental_backup_cron_minute*]
#   The minute(s) that the incremental backup(s) run(s).
#
# [*enabled*]
#   If this is true then the packages are installed and backups are triggered.
#
class govuk_mysql::xtrabackup::backup (
  $aws_access_key_id = undef,
  $aws_secret_access_key = undef,
  $aws_region = 'eu-west-1',
  $s3_bucket_name = undef,
  $encryption_key = undef,
  $base_backup_cron_minute = 10,
  $base_backup_cron_hour = 6,
  $incremental_backup_cron_minute = '*/15',
  $enabled = false,
) {
  if $enabled {
    include govuk_mysql::xtrabackup::packages

    file {['/etc/mysql/xtrabackup', '/etc/mysql/xtrabackup/env.d']:
      ensure => 'directory',
      mode   => '0755',
    }

    file { '/etc/mysql/xtrabackup/env.d/AWS_ACCESS_KEY_ID':
      ensure  => 'present',
      content => $aws_access_key_id,
      mode    => '0440',
    }

    file { '/etc/mysql/xtrabackup/env.d/AWS_SECRET_ACCESS_KEY':
      ensure  => 'present',
      content => $aws_secret_access_key,
      mode    => '0440',
    }

    $base_threshold_secs = 28 * 3600
    $base_service_desc = 'MySQL Xtrabackup daily base push'

    file { '/usr/local/bin/xtrabackup_s3_base':
      ensure  => 'present',
      content => template('govuk_mysql/usr/local/bin/xtrabackup_s3_base'),
      mode    => '0755',
    }

    @@icinga::passive_check { "check_mysql_xtrabackup_daily_base_push-${::hostname}":
      service_description => $base_service_desc,
      freshness_threshold => $base_threshold_secs,
      host_name           => $::fqdn,
    }

    $incremental_threshold_secs = 15 * 60
    $incremental_service_desc = 'MySQL Xtrabackup incremental push'

    file { '/usr/local/bin/xtrabackup_s3_incremental':
      ensure  => 'present',
      content => template('govuk_mysql/usr/local/bin/xtrabackup_s3_incremental'),
      mode    => '0755',
    }

    @@icinga::passive_check { "check_mysql_xtrabackup_incremental_push-${::hostname}":
      service_description => $incremental_service_desc,
      freshness_threshold => $incremental_threshold_secs,
      host_name           => $::fqdn,
    }

    file { '/etc/cron.d/xtrabackup_s3':
      ensure  => 'present',
      content => template('govuk_mysql/etc/cron.d/xtrabackup_s3'),
      mode    => '0755',
    }
  }
}
