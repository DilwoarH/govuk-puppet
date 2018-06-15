# == Class: govuk_s3_db_sync::pull_cron
#
# Runs a backup of MongoDB to Amazon S3 as a cron job.
#
# [*user*]
#   The user to run the cronjob as.
#
class govuk_s3_db_sync::pull_cron(
  $user = 'govuk-backup', 
  $databases,
  $s3_bucket,
  $s3_prefix,
  $hour = 0,
  $minute = 0,
) {

  require awscli

  validate_array($databases)

  $pullcommand = shellquote([
    '/usr/bin/ionice','-c','2','-n','6',
    '/usr/bin/setlock','/etc/unattended-reboot/no-reboot/mongodb-s3-pull',
    '/usr/local/bin/s3-to-mongo.sh',
    '-d',join($databases,' -d '),
    '-b',$s3_bucket,
    '-p',$s3_prefix
    ])

  cron { 'mongodb-s3-pull':
    command => Spullcommand, 
    user    => $user,
    hour    => $hour,
    minute  => $minute,
  }
}
