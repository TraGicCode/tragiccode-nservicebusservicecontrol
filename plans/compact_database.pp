# Compacts the servicecontrol instance's RavenDB Database.
#
# @param targets Targets to compact databases.
# @param instance_name The name of the servicecontrol instance.
plan nservicebusservicecontrol::compact_database (
  TargetSpec $targets,
  String[1] $instance_name,
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
      fail_plan("A servicecontrol instance with the name of '${instance_name}' could not be found.", 'nservicebusservicecontrol/servicecontrol-instance-not-found')
    }
    out::message("Probing Complete. Found the servicecontrol instance with the name of '${instance_name}'.")
    # Shortcircuit if monitoring instance
    if $found_instance[0]['Type'] == 'monitor' {
      fail_plan('Importing of failed messages cannot be done for monitoring instances.', 'nservicebusservicecontrol/servicecontrol-instance-operation-not-allowed')
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
    # Check database is in a consistent state and ready for defragmentation
    out::message('Checking to ensure database is in a consistent state and ready for defragmentation.')
    run_command("cd '${found_instance[0]['DBPath']}'; & esentutl.exe /r RVN /l logs /s system", $target)
    out::message('Check completed.  Database is ready for defragmentation.')

    out::message('Starting defragmentation.')
    run_command("cd '${found_instance[0]['DBPath']}'; & esentutl.exe /d Data", $target)
    out::message('Defragmentation completed.')

    run_task('service::windows', $target, action => 'start', name => $instance_name)
    run_task('agent_disenable', $target, action => 'enable')
  }
}
