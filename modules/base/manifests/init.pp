# == Class: base
#
# Pull in a standard set of modules for all machines. Used everywhere, by
# both `govuk::node::s_base` and `govuk::node::s_development`.
#
class base {
  include apparmor
  include apt
  include apt::unattended_upgrades
  include base::packages
  include base::supported_kernel
  include cron
  include gcc
  include logrotate
  include ntp
  include screen
  include shell
  include ssh
  include motd
  include govuk_apt::unused_kernels
  include govuk_sudo
  include timezone
  include tmpreaper
  include wget
  include curl
}
