# == Define: monitoring::checks::rds_config
#
# Nagios alert config for AWS RDS.
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
define monitoring::checks::rds_config (
  $region = undef,
  $cpu_warning = 80,
  $cpu_critical = 90,
  $memory_warning = 5,
  $memory_critical = 2,
  $storage_warning = 20,
  $storage_critical = 10,
  ){
  icinga::check { "check_aws_rds_cpu-${title}":
    check_command       => "check_aws_rds_cpu!${region}!${cpu_warning}!${cpu_critical}!${::aws_stackname}-${title}",
    use                 => 'govuk_urgent_priority',
    host_name           => $::fqdn,
    service_description => 'AWS RDS CPU Utilization',
    notes_url           => monitoring_docs_url(aws-rds-cpu),
    require             => Icinga::Check_config['check_aws_rds_cpu'],
  }

  icinga::check { "check_aws_rds_memory-${title}":
    check_command       => "check_aws_rds_memory!${region}!${memory_warning}!${memory_critical}!${::aws_stackname}-${title}",
    use                 => 'govuk_urgent_priority',
    host_name           => $::fqdn,
    service_description => 'AWS RDS Memory Utilization',
    notes_url           => monitoring_docs_url(aws-rds-memory),
    require             => Icinga::Check_config['check_aws_rds_memory'],
  }

  icinga::check { "check_aws_rds_storage-${title}":
    check_command       => "check_aws_rds_storage!${region}!${storage_warning}!${storage_critical}!${::aws_stackname}-${title}",
    use                 => 'govuk_urgent_priority',
    host_name           => $::fqdn,
    service_description => 'AWS RDS Storage Utilization',
    notes_url           => monitoring_docs_url(aws-rds-storage),
    require             => Icinga::Check_config['check_aws_rds_storage'],
  }
}
