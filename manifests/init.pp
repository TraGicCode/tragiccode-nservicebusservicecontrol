# @summary Installs and configures Particular's Service Control Monitoring Tool.
#
# @param package_ensure
#   Whether to install the ServiceControl package.
#
# @param remote_file_path
#   The location to store the downloaded installer on the local system.
#
# @param remote_file_source
#   The http/https location in which a specific version of servicecontrol can be downloaded from.
#
# @param license_xml
#   A valid NServiceBus XML License. 
#
class nservicebusservicecontrol(
  Enum['present', 'installed', 'absent'] $package_ensure = 'present',
  Stdlib::Absolutepath $remote_file_path                 = 'C:\\Particular.ServiceControl-3.6.1.exe',
  Stdlib::Httpsurl $remote_file_source                   = 'https://github.com/Particular/ServiceControl/releases/download/3.6.1/Particular.ServiceControl-3.6.1.exe',
  Optional[String] $license_xml                          = '',
  ) {

  contain nservicebusservicecontrol::install
  contain nservicebusservicecontrol::config

  Class['nservicebusservicecontrol::install']
  -> Class['nservicebusservicecontrol::config']
  -> Nservicebusservicecontrol::Instance <| |>

}
