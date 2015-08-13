# == Class: govuk_jenkins::job::production::run_govuk_complaint_rate_report
#
# Create a file on disk that can be parsed by jenkins-job-builder
#
# === Parameters
#
# [*performanceplatform_dataset_token*]
#   Token to POST data to the Performance Platform
#
class govuk_jenkins::job::production::run_govuk_complaint_rate_report (
  $performanceplatform_dataset_token = undef,
) {
  file { '/etc/jenkins_jobs/jobs/run_govuk_complaint_rate_report.yaml':
    ensure  => present,
    content => template('govuk_jenkins/jobs/production/run_govuk_complaint_rate_report.yaml.erb'),
    notify  => Exec['jenkins_jobs_update'],
  }
}
