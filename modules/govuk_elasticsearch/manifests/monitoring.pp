# == Class govuk_elasticsearch::monitoring
#
# Setup monitoring for an elasticsearch node
#
# === Parameters
#
# FIXME: Document missing parameters
#
# [*legacy_elasticsearch*]
#   Whether this is a pre-1.x elasticsearch installation.  Defaults to false
#
class govuk_elasticsearch::monitoring (
  $host_count,
  $cluster_name,
  $http_port,
  $log_index_type_count,
  $disable_gc_alerts,
  $legacy_elasticsearch = false,
) {

  validate_bool($disable_gc_alerts)

  class { 'collectd::plugin::elasticsearch':
    es_port              => $http_port,
    log_index_type_count => $log_index_type_count,
    legacy_elasticsearch => $legacy_elasticsearch,
  }

  unless $disable_gc_alerts {
    @@icinga::check::graphite { "check_elasticsearch_jvm_gc_old_collection_time_in_millis-${::hostname}":
      target    => "summarize(${::fqdn_underscore}.curl_json-elasticsearch.counter-jvm_gc_collectors_old_collection_time_in_millis,\"5minutes\",\"max\",true)",
      desc      => 'Prolonged GC collection times: old',
      warning   => 150,
      critical  => 300,
      host_name => $::fqdn,
      notes_url => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#prolonged-gc-collection-times-check',
    }
    @@icinga::check::graphite { "check_elasticsearch_jvm_gc_young_collection_time_in_millis-${::hostname}":
      target    => "summarize(${::fqdn_underscore}.curl_json-elasticsearch.counter-jvm_gc_collectors_young_collection_time_in_millis,\"5minutes\",\"max\",true)",
      desc      => 'Prolonged GC collection times: young',
      warning   => 150,
      critical  => 300,
      host_name => $::fqdn,
      notes_url => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#prolonged-gc-collection-times-check',
    }
  }

  @icinga::nrpe_config { 'check_elasticsearch_cluster_health':
    source => 'puppet:///modules/govuk_elasticsearch/check_elasticsearch_cluster_health.cfg',
  }

  # Check against the total number of hosts, not the minimum, else the alert
  # won't fire correctly
  @@icinga::check { "check_elasticsearch-${cluster_name}_cluster_health_running_on_${::hostname}":
    check_command       => "check_nrpe!check_elasticsearch_cluster_health!${host_count}",
    service_description => 'elasticsearch cluster is not healthy',
    host_name           => $::fqdn,
    notes_url           => 'https://github.gds/pages/gds/opsmanual/2nd-line/nagios.html#elasticsearch-cluster-health',
  }
}
