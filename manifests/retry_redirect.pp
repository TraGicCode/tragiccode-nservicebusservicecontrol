# @summary Manages Retry Redirects.
#
# @param ensure
#   Specifies whether the retry redirect should exist.
#
# @param source_queue
#   Specify the queue for which this redirect will be applied.
#
# @param service_control_url
#   Url for servicecontrol in format of 'http://localhost:33333'.
#
#
# @param destination_queue
#   Specify the queue that will be the new destination when retrying.
#
define nservicebusservicecontrol::retry_redirect (
  Enum['present', 'absent'] $ensure,
  String $destination_queue,
  String $service_control_url,
  String $source_queue = $title,
) {
  if $ensure == 'present' {
    exec { "create-retry-redirect-${source_queue}":
      command   => epp("${module_name}/create-or-update-retry-redirect.ps1.epp", {
          'source_queue'        => $source_queue,
          'destination_queue'   => $destination_queue,
          'service_control_url' => $service_control_url,
      }),
      onlyif    => epp("${module_name}/query-retry-redirect.ps1.epp", {
          'source_queue'        => $source_queue,
          'destination_queue'   => $destination_queue,
          'service_control_url' => $service_control_url,
      }),
      logoutput => true,
      provider  => 'pwsh',
    }
  } else {
    exec { "delete-retry-redirect-${source_queue}":
      command   => epp("${module_name}/delete-retry-redirect.ps1.epp", {
          'source_queue'        => $source_queue,
          'destination_queue'   => $destination_queue,
          'service_control_url' => $service_control_url,
      }),
      unless    => epp("${module_name}/query-retry-redirect.ps1.epp", {
          'source_queue'        => $source_queue,
          'destination_queue'   => $destination_queue,
          'service_control_url' => $service_control_url,
      }),
      logoutput => true,
      provider  => 'pwsh',
    }
  }
}
