# == Class: govuk_s3_db_sync::pull
#
# Restore a MongoDB backup to a server from s3
#
# === Parameters:
#
# [*aws_access_key_id*]
#   Key used to sign programmatic requests in AWS
#
# [*aws_secret_access_key*]
#   Key used to sign programmatic requests in AWS
#
# [*backup_dir*]
#   Defines the directory to restore the backups
#
# [*env_dir*]
#   Defines directory for the environment
#   variables
#
# [*private_gpg_key*]
#   Defines the ascii exported private gpg to
#   use for decrypting backups. This key should
#   be created by the user and encrypted with eyaml
#
# [*private_gpg_key_fingerprint*]
#   Defines the fingerprint of the gpg private
#   key to dencrypt the backups. The fingerprint
#   should be 40 characters without spaces
#
# [*s3_bucket*]
#   Defines the AWS S3 bucket where the backups
#   will be downloaded from. It should be created by the
#   user
#
# [*cron*]
#   Defines whether to enable the cron job. Value
#   should be true or false
class govuk_s3_db_sync::pull(
  $user = 'govuk-backup',
  $aws_access_key_id = undef,
  $aws_secret_access_key = undef,
  $env_dir = '/etc/govuk_s3_db_sync',
  $databases,
  $s3_bucket,
  $s3_prefix,
  $backup_dir = '/var/lib/mongo/.dumps/',
){

 # push script
 file { '/usr/local/bin/s3-to-mongo.sh':
    ensure => present,
    mode   => '0755',
    owner  => 'govuk-backup',
    group  => 'govuk-backup',
    source => 'puppet:///modules/govuk_s3_db_sync/s3-to-mongo.sh',
  }
 
  if $govuk_s3_db_sync::add_pull_cron {
    include govuk_s3_db_sync::pull_cron
  } 

}
