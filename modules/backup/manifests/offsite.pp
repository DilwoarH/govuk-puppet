# == Class: backup::offsite
#
# Transfer onsite backups to an offsite machine. Some are encrypted against
# a public GPG key, for which the private key to retrieve them can be found
# in the creds store.
#
# === Parameters
#
# [*enable*]
#   Whether to enable the generation and sending of encrypted backups
#   Default: False
#
# [*jobs*]
#   Hash of `backup::offsite::job` resources. `ensure` parameter will be
#   added.
#
# [*dest_host*]
#    Hostname or IP of the machine to send the backups to.
#
# [*dest_host_key*]
#    The SSH key to use to authenticate to the destination machine.
#
class backup::offsite(
  $enable = false,
  $jobs,
  $dest_host,
  $dest_host_key,
) {
  validate_hash($jobs)
  validate_bool($enable)
  $ensure_backup = $enable ? {
    true    => present,
    default => absent,
  }

  include backup::client

  sshkey { $dest_host:
    ensure => present,
    type   => 'ssh-rsa',
    key    => $dest_host_key,
  }

  create_resources('backup::offsite::job', $jobs, {
    'ensure' => $ensure_backup,
  })

  # FIXME: Remove when deployed.
  backup::offsite::job { 'offsite-govuk-datastores':
    ensure      => absent,
    sources     => '',
    destination => '',
    hour        => 0,
    minute      => 0,
    user        => '',
    gpg_key_id  => '',
  }
}
