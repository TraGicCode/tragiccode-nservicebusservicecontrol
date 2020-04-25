# Reboots targets and waits for them to be available again.
#
# @param targets Targets to reboot.
# @param message Message to log with the reboot (for platforms that support it).
# @param reboot_delay How long (in seconds) to wait before rebooting. Defaults to 1.
# @param disconnect_wait How long (in seconds) to wait before checking whether the server has rebooted. Defaults to 10.
# @param reconnect_timeout How long (in seconds) to attempt to reconnect before giving up. Defaults to 180.
# @param retry_interval How long (in seconds) to wait between retries. Defaults to 1.
# @param fail_plan_on_errors Raise an error if any targets do not successfully reboot. Defaults to true.
plan nservicebusservicecontrol::import_failed_messages (
  TargetSpec $targets,
  String $instance_name,
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
  $target_objects = get_targets($targets)

  run_task('agent_disenable', $targets, action => 'disable', message => 'Importing failed messages.')
  run_task('agent_disenable', $targets, action => 'enable')

}
