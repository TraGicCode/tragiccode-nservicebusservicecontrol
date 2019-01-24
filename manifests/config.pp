# @summary
#   This class handles the configuration of servicecontrol.
#
# @api private
#
class nservicebusservicecontrol::config {

  $_registry_key_ensure = $nservicebusservicecontrol::license_xml ? {
    ''      => 'absent',
    default => 'present'
  }

  registry_value { 'HKLM\SOFTWARE\ParticularSoftware\License':
    ensure => $_registry_key_ensure,
    type   => string,
    data   => $nservicebusservicecontrol::license_xml,
  }
}
