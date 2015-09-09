# == Class: fail2ban::config
#
# This class sets up fail2ban configuration.
#
class fail2ban::config {

  file { '/etc/fail2ban/fail2ban.local':
    source => 'puppet:///modules/fail2ban/etc/fail2ban/fail2ban.local',
  }

  file { '/etc/fail2ban/jail.local':
    source => 'puppet:///modules/fail2ban/etc/fail2ban/jail.local',
  }

}
