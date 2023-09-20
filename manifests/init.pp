# @summary Installs and configures Particular's Service Control Monitoring Tool.
#
# @param package_ensure
#   Whether to install the ServiceControl package.
#
# @param package_source
#   The package source for the package.
#
# @param powershell_package_provider
#   Whether to use Windows PowerShell or PowerShell Core to install the Particular.ServiceControl.Management PowerShell module.
#
# @param license_xml
#   A valid NServiceBus XML License. 
#
class nservicebusservicecontrol (
  String $package_ensure           = 'present',
  Optional[String] $package_source = undef,
  Optional[Enum['windowspowershell', 'powershellcore']] $powershell_package_provider = 'windowspowershell',
  Optional[String] $license_xml    = '',
) {
  contain nservicebusservicecontrol::install
  contain nservicebusservicecontrol::config

  if $package_ensure != 'absent' {
    Class['nservicebusservicecontrol::install']
    -> Class['nservicebusservicecontrol::config']
    ~> Nservicebusservicecontrol::Instance <| |>
    -> Nservicebusservicecontrol::Audit_instance <| |>
    -> Nservicebusservicecontrol::Monitoring_instance <| |>
  }
  else {
    Nservicebusservicecontrol::Instance <| |>
    -> Nservicebusservicecontrol::Audit_instance <| |>
    -> Nservicebusservicecontrol::Monitoring_instance <| |>
    -> Class['nservicebusservicecontrol::config']
    -> Class['nservicebusservicecontrol::install']
  }
}
