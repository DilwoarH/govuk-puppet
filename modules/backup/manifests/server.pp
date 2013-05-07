class backup::server {

  include backup::client

  file { ['/data/backups',
          '/etc/backup',
          '/etc/backup/daily',
          '/etc/backup/weekly',
          '/etc/backup/monthly']:
    ensure  => directory,
    owner   => 'govuk-backup',
    mode    => '0700',
  }

  # Parent dir is provided by govuk::user in backup::client.
  file {'/home/govuk-backup/.ssh/id_rsa':
    ensure  => file,
    owner   => 'govuk-backup',
    mode    => '0600',
    content => extlookup('govuk-backup_key_private', ''),
    require => Class['backup::client'],
  }

  cron { 'cron_govuk-backup_daily':
    command => 'run-parts /etc/backup/daily',
    user    => 'govuk-backup',
    # Every day at 0300
    hour    => '3',
    minute  => '0',
  }

  cron { 'cron_govuk-backup_weekly':
    command => 'run-parts /etc/backup/weekly',
    user    => 'govuk-backup',
    # Sunday morning at 0400
    weekday => '0',
    hour    => '4',
    minute  => '0',
  }

  cron { 'cron_govuk-backup_monthly':
    command  => 'run-parts /etc/backup/monthly',
    user     => 'govuk-backup',
    # 1st day of the month at 0500
    monthday => '1',
    hour     => '5',
    minute   => '0',
  }

  @nagios::plugin { 'check_backup_age':
    source  => 'puppet:///modules/backup/check_backup_age',
  }

  @nagios::nrpe_config { 'check_backup_age':
    source  => 'puppet:///modules/backup/nrpe_check_backup_age.cfg',
  }

  @@nagios::check { "check_backup_age_${::hostname}":
    check_command       => 'check_nrpe_1arg!check_backup_age',
    service_description => "backup not run recently",
    host_name           => $::fqdn,
  }

  Backup::Directory   <<||>> { }
}
