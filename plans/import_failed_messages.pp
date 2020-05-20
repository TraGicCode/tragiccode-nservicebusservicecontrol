# Imports failed error or audit messages.
#
# @param targets Targets to import failed messags on.
# @param instance_name The name of the servicecontrol instance.
# @param instance_type The servicecontrol instance type (Audit or Error).
plan nservicebusservicecontrol::import_failed_messages (
  TargetSpec $targets,
  String[1] $instance_name,
  Enum['error', 'audit'] $instance_type,
) {

  get_targets($targets).each |$target| {
    # Cannot trust user input so lets validate their data instead
    # Maybe perform more validations?
    out::message('Probing system for specified servicecontrol instance')
    $instance_details_result = run_task('nservicebusservicecontrol::get_instances', $target)
    $items = $instance_details_result.map |$r| { $r['_items'] }
    $found_instance = $items.reduce([]) |$agg, $res| {
      $agg + $res.filter |$instance| { $instance["Name"] == $instance_name }
    }

    if $found_instance.empty() {
      fail_plan("A servicecontrol instance with the name of '${instance_name}' and type of '${instance_type}' could not be found.", 'nservicebusservicecontrol/servicecontrol-instance-not-found')
    }
    out::message("Probing Complete.  Found the servicecontrol instance with the name of '${instance_name}' and type of '${instance_type}'.")
    # Shortcircuit if monitoring instance
    if $found_instance[0]['Type'] == 'monitor' {
      out::message('Importing of failed messages cannot be done for monitoring instances.')
    }

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
    run_task('service::windows', $target, action => 'stop', name => $instance_name)
    ctrl::do_until( 'limit' => 5 ) || {
      $results = run_task('service::windows', $target, action => 'status', name => $instance_name)
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

    run_command("& '${found_instance[0]['ExecutablePath']}' --portable --serviceName=${found_instance[0]['Name']} --import-failed-${found_instance[0]['Type']}s", $target)
    run_task('service::windows', $target, action => 'start', name => $instance_name)
    run_task('agent_disenable', $target, action => 'enable')
  }
}
