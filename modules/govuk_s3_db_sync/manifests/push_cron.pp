# == Class: govuk_s3_db_sync::push_cron
#
# Runs a backup of MongoDB to Amazon S3 as a cron job.
#
# [*user*]
#   The user to run the cronjob as.
#
class govuk_s3_db_sync::push_cron(
  $user = 'govuk-backup', 
  $databases,
  $s3_bucket,
  $s3_prefix,
  $hour = 0,
  $minute = 0,
) {

  require awscli

  validate_array($databases)

  $pushcommand = shellquote([
    '/usr/bin/ionice','-c','2','-n','6',
    '/usr/bin/setlock','/etc/unattended-reboot/no-reboot/mongodb-s3-push',
    '/usr/local/bin/mongo-to-s3.sh',
    '-d',join($databases, ' -d '),
    '-b',$s3_bucket,
    '-p',$s3_prefix
    ])

  cron { 'mongodb-s3-push':
    command => Spushcommand, 
    user    => $user,
    hour    => $hour,
    minute  => $minute,
  }
}
