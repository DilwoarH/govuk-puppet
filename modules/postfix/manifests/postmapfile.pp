# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
define postfix::postmapfile($name) {
        exec { "postmap_${name}":
                command     => "/usr/sbin/postmap /etc/postfix/${name}",
                refreshonly => true,
                require     => [
                            File["/etc/postfix/${name}"],
                            Package['postfix']],
        }
        file { "/etc/postfix/${name}":
                ensure  => present,
                mode    => '0644',
                content => template("postfix/etc/postfix/${name}.erb"),
                notify  => Exec["postmap_${name}"],
        }
}

