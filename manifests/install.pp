# @summary
#   This class handles the management of the servicecontrol installer and package.
#
# @api private
#
class nservicebusservicecontrol::install {

  $_remote_file_ensure = $nservicebusservicecontrol::package_ensure ? {
      'installed' => 'present',
      'present'   => 'present',
      default     => 'absent',
  }

  remote_file { $nservicebusservicecontrol::remote_file_path:
    ensure => $_remote_file_ensure,
    source => $nservicebusservicecontrol::remote_file_source,
  }

  package { 'ServiceControl':
    ensure            => $nservicebusservicecontrol::package_ensure,
    source            => $nservicebusservicecontrol::remote_file_path,
    install_options   => ['/Quiet'],
    uninstall_options => ['/Quiet'],
    require           => Remote_file[$nservicebusservicecontrol::remote_file_path],
  }

}
