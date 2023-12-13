# @summary
#   This class handles the management of the servicecontrol installer and package.
#
# @api private
#
class nservicebusservicecontrol::install {
  package { 'Particular.ServiceControl.Management':
    ensure   => '5.0.0',
    source   => 'PSGallery',
    provider => 'powershellcore',
  }
  package { 'servicecontrol':
    ensure   => $nservicebusservicecontrol::package_ensure,
    source   => $nservicebusservicecontrol::package_source,
    provider => 'chocolatey',
  }
}
