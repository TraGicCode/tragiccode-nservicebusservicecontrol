# @summary
#   This class handles the configuration of servicecontrol.
#
# @api private
#
class nservicebusservicecontrol::config {
  $_license_ensure = $nservicebusservicecontrol::license_xml ? {
    undef      => 'absent',
    default => 'present'
  }

  registry_value { 'HKLM\SOFTWARE\ParticularSoftware\License':
    ensure => $_license_ensure,
    type   => string,
    data   => $nservicebusservicecontrol::license_xml,
  }

  file { 'C:\ProgramData\ParticularSoftware':
    ensure => 'directory',
  }

  file { 'C:\ProgramData\ParticularSoftware\license.xml':
    ensure  => $_license_ensure,
    content => $nservicebusservicecontrol::license_xml,
  }
}
