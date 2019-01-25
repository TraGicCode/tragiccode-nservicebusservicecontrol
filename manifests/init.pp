# @summary Installs and configures Particular's Service Control Monitoring Tool.
#
# @param package_ensure
#   Whether to install the ServiceControl package.
#
# @param package_source
#   The package source for the package.
#
# @param license_xml
#   A valid NServiceBus XML License. 
#
class nservicebusservicecontrol(
  String $package_ensure           = 'present',
  Optional[String] $package_source = undef,
  Optional[String] $license_xml    = '',
  ) {

  contain nservicebusservicecontrol::install
  contain nservicebusservicecontrol::config

  Class['nservicebusservicecontrol::install']
  -> Class['nservicebusservicecontrol::config']
  -> Nservicebusservicecontrol::Instance <| |>
  -> Nservicebusservicecontrol::Monitoring_instance <| |>

}
