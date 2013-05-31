# TODO: rename the 'mapit_server' govuk_class to simply 'mapit'
class govuk::node::s_mapit_server inherits govuk::node::s_base {

  include postgres
  include postgres::postgis

  include mapit

  curl::fetch { 'mapit_dbdump_download':
    source      => 'http://gds-public-readable-tarballs.s3.amazonaws.com/mapit.sql.gz',
    destination => '/data/vhost/mapit/data/mapit.sql.gz',
    require     => File['/data/vhost/mapit/data'],
  }

  postgres::user {'mapit':
    password => 'mapit',
  }

  postgres::database { 'mapit':
    ensure   => present,
    owner    => 'mapit',
    encoding => 'UTF8',
    template => 'template0',
  }

  postgres::exec { 'zcat -f /data/vhost/mapit/data/mapit.sql.gz | psql':
    database => 'mapit',
    unless   => 'psql -Atc "select count(*) from pg_catalog.pg_tables WHERE tablename=\'mapit_area\'" | grep -qvF 0',
    require  => Curl::Fetch['mapit_dbdump_download'],
  }

}
