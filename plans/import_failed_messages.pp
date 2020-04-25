# Imports failed error or audit message.
#
# @param targets Targets to import failed messags on.
# @param instance_name The name of the servicecontrol instance.
# @param instance_type The servicecontrol instance type (Audit or Error).
plan nservicebusservicecontrol::import_failed_messages (
  TargetSpec $targets,
  String $instance_name,
  Enum['error', 'audit'] $instance_type,
) {

  # Steps to import
  # 1. StopServiceControl Service
  # 2. run servicecontrol from cli with --import-failed-errors or --import-failed-audits
  # 3. Start Service

  # Full workflow
  # X. Disable agent with hardcoded message
  # 2. Wait for existing run to finish if one is in progress
  # 3. Perform work ('Steps to import' from above)
  # X. Enable agent again
  # $target_objects = get_targets($targets)
  # C:\ProgramData\PuppetLabs\puppet\cache\state\agent_disabled.lock
  get_targets($targets).each |$target| {
    run_task('agent_disenable', $target, action => 'disable', message => 'Importing failed messages.')
    ctrl::do_until( 'limit' => 20 ) || {
      $results = run_command("Test-Path -Path 'C:\\ProgramData\\PuppetLabs\\puppet\\cache\\state\\agent_catalog_run.lock'", $target)
      $results.each |$result| {
        if $result['stdout'] == 'True' {
          ctrl::sleep(10)
          true
        }
        else {
          false
        }
      }
    }
    run_task('service::windows', $targets, action => 'stop', name => $instance_name)
    ctrl::do_until( 'limit' => 5 ) || {
      $results = run_task('service::windows', $targets, action => 'status', name => $instance_name)
      $results.each |$result| {
        if $result['status'] == 'Stopped' {
          true
        }
        else {
          false
        }
      }
    }
    # For some reason if you don't wait just a little bit servicecontrol
    # will throw an unhandled exception on import...
    ctrl::sleep(10)
    if $instance_type == 'audit' {
      $root_command = "C:\\Program Files (x86)\\Particular Software\\Particular.ServiceControl.Audit\\ServiceControl.Audit.exe"
    } else {
      $root_command = "C:\\Program Files (x86)\\Particular Software\\Particular.ServiceControl\\ServiceControl.exe"
    }

    run_command("& '${root_command}' --serviceName=${instance_name} --import-failed-${instance_type}s", $targets)
    run_task('service::windows', $targets, action => 'start', name => $instance_name)
    run_task('agent_disenable', $targets, action => 'enable')
  }
}
