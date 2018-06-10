# == Define: monitoring::checks::cache_config
#
# Nagios alert config for AWS Elastic Cache.
#
# === Parameters
#
# [*region*]
#   Which AWS region should be checked ['us-east-1','eu-west-1']
#
# [*enabled*]
#   Should we enable the monitoring check?
#
# [*warning*]
#   What percentage or value should trigger a warning?
#
# [*critical*]
#   What percentage or value should trigger a critical?
#
#
define monitoring::checks::cache_config (
  $region = undef,
  $cpu_warning = 80,
  $cpu_critical = 90,
  $memory_warning = 5,
  $memory_critical = 2,
  ){
  icinga::check { "check_aws_cache_cpu-${title}":
    check_command       => "check_aws_cache_cpu!${region}!${cpu_warning}!${cpu_critical}!${::aws_stackname}-${title}",
    use                 => 'govuk_urgent_priority',
    host_name           => $::fqdn,
    service_description => 'AWS ElasticCache CPU Utilization',
    notes_url           => monitoring_docs_url(aws-cache-cpu),
    require             => Icinga::Check_config['check_aws_cache_cpu'],
  }

  icinga::check { "check_aws_cache_memory-${title}":
    check_command       => "check_aws_cache_memory!${region}!${memory_warning}!${memory_critical}!${::aws_stackname}-${title}",
    use                 => 'govuk_urgent_priority',
    host_name           => $::fqdn,
    service_description => 'AWS ElasticCache Memory Utilization',
    notes_url           => monitoring_docs_url(aws-cache-memory),
    require             => Icinga::Check_config['check_aws_cache_memory'],
  }
}
