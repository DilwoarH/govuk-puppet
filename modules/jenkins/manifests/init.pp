class jenkins {
  include jenkins::ssh_key

  #TODO:
  # also need to install fabric and cloth which are needed by private-utils,
  # possibly this would be better done in the private-utils/jenkins.sh

  $jenkins_home = '/home/jenkins'
  user { 'jenkins':
    ensure     => present,
    home       => $jenkins_home,
    managehome => true,
    shell      => '/bin/bash'
  }

  # Parents created in `jenkins::ssh_key`.
  # Contents overridden in `jenkins::slave`.
  file { "${jenkins_home}/.ssh/authorized_keys":
    ensure  => absent,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
  }

  # This facter fact can be set on slave machines to signal that the slave should install and
  # use java 7 rather than java 6.
  if $::govuk_java_version == 'oracle7' {

    include java::oracle7::jdk
    include java::oracle7::jre

    class { 'java::set_defaults':
      jdk => 'oracle7',
      jre => 'oracle7',
    }

  } else {

    include java::sun6::jdk
    include java::sun6::jre

    class { 'java::set_defaults':
      jdk => 'sun6',
      jre => 'sun6',
    }

  }

  package { 'brakeman':
    ensure   => 'installed',
    provider => gem,
  }

  package { 'ghtools':
    ensure   => '0.20.0',
    provider => pip,
  }

  package { [
    'sqlite3',
    'gnuplot',
    'python-virtualenv',
    'python-paramiko',
    'ant'
    ]:
      ensure => installed,
  }

  # Required for redirector-deploy
  package { 's3cmd':
    ensure   => 'installed',
    provider => 'pip',
  }

  # This is required for the redirector-deploy job
  package { 'libtext-csv-perl':
    ensure => installed,
  }

  # This is required for the redirector-integration job
  package { 'libcrypt-ssleay-perl':
    ensure => installed,
  }

  # This is required for the gov.uk spider job
  package { 'scrapy':
    ensure   => '0.14.4',
    provider => 'pip',
  }

  package { 'twisted':
    ensure   => '10.0.0',
    provider => 'pip',
  }

  # Required for running whitehall tests (uses pdfinfo)
  package { 'poppler-utils':
    ensure   => 'installed',
  }

  file { '/home/jenkins/.gitconfig':
    source  => 'puppet:///modules/jenkins/dot-gitconfig',
    owner   => jenkins,
    group   => jenkins,
    mode    => '0644',
    require => User['jenkins'],
  }

  file { '/mnt/jenkins':
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    mode    => '0644',
    require => User['jenkins'],
  }

  file { '/var/lib/jenkins':
    ensure  => link,
    target  => '/mnt/jenkins',
    require => File['/mnt/jenkins'],
  }

  include golang
}
