class base::packages {

  ensure_packages([
      'ack-grep',
      'bzip2',
      'dnsutils',
      'dstat',
      'fish',
      'gettext',
      'git-core',
      'htop',
      'iotop',
      'iptraf',
      'less',
      'libc6-dev',
      'libcurl4-openssl-dev',
      'libreadline-dev',
      'libreadline5',
      'libsqlite3-dev',
      'libxml2-dev',
      'libxslt1-dev',
      'logtail',
      'mailutils',
      'man-db',
      'manpages',
      'pv',
      'tar',
      'tree',
      'unzip',
      'vim-nox',
      'xz-utils',
      'zip'
    ])

  if $::lsbdistcodename == 'precise' {
    package { 'ruby1.9.1-dev':
      ensure => installed,
    }

    include nodejs
  }
}
