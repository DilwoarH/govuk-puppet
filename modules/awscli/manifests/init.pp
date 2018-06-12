# == Class: awscli 
#
# Installs awscli from local aptly resource
#
# === Parameters
#
# [*apt_mirror_hostname*]
#   The hostname of an APT mirror
#
class awscli (
  $apt_mirror_hostname = undef,
){

  apt::source { 'awscli':
    location     => "http://${apt_mirror_hostname}/awscli",
    release      => 'stable',
    architecture => $::architecture,
    key          => '3803E444EB0235822AA36A66EC5FE1A937E3ACBB',
  }

  package { 'awscli':
    require => Apt::Source['awscli'],
  }

}
