# @summary
#   This class handles the management of the servicecontrol installer and package.
#
# @api private
#
class nservicebusservicecontrol::install {
  package { 'Particular.ServiceControl.Management':
    ensure   => $nservicebusservicecontrol::package_ensure,
    source   => 'PSGallery',
    provider => $nservicebusservicecontrol::powershell_package_provider,
  }
  package { 'servicecontrol':
    ensure   => $nservicebusservicecontrol::package_ensure,
    source   => $nservicebusservicecontrol::package_source,
    provider => 'chocolatey',
  }
}
