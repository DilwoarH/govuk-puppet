node default {

  if $::govuk_class == '' {
    $warn_head = '$::govuk_class is blank, not doing any initialization!'
    $warn_body = 'Consider sourcing `/etc/environment` or running with `sudo -i`'

    warning($warn_head)
    notify { "${warn_head} ${warn_body}": }
  } else {
    case $::govuk_class {
      'elms-sky-frontend':  { include govuk::node::s_licensify_frontend }
      'elms-sky-backend':   { include govuk::node::s_licensify_backend }
      'elms-mongo':         { include govuk::node::s_licensify_mongo }

      'ertp-api-citizen':   { include ertp_base::api_server::citizen }
      'ertp-api-dwp':       { include ertp_base::api_server::dwp }
      'ertp-api-ero':       { include ertp_base::api_server::ero }
      'ertp-api':           { include ertp_base::api_server::all }
      'ertp-development':   { include ertp_base::development }
      'ertp-frontend':      { include ertp_base::frontend_server }
      'ertp-mongo':         { include ertp_base::mongo_server }
      'graylog':            { include govuk::node::s_logging }
      'places-api':         { include places_base::api_server }
      'places-mongo':       { include places_base::mongo_server }

      'feedex':             { notify {'placeholder for including feedex module when it gets written':}}

      default: {
        $underscored_govuk_class = regsubst($::govuk_class, '-', '_')
        $node_class_name = "govuk::node::s_${underscored_govuk_class}"
        include $node_class_name
      }
    }
  }
}
