# @summary Manages Service Control Instances.
#
# @param ensure
#   Specifies whether the instance should exist.
#
# @param instance_name
#   Specify the name of the ServiceControl Instance (title).
#
# @param install_path
#   Specify the directory to use for this ServiceControl Instance.
#
# @param log_path
#   Specify the directory to use for this ServiceControl Logs.
#
# @param db_path
#   Specify the directory that will contain the nservicebusservicecontrol database for this ServiceControl Instance.
#
# @param db_index_storage_path
#   Specify the path for the indexes on disk.
#
# @param db_logs_path
#   Specify the path for the Esent logs on disk.
#
# @param instance_log_level
#   Specify the level of logging that should be used in ServiceControl logs.
#
# @param host_name
#   Specify the hostname to use in the URLACL.
#
# @param port
#   Specify the port number to listen on. If this is the only ServiceControl instance then 33333 is recommended.
#
# @param database_maintenance_port
#   Specify the database maintenance port number to listen on. If this is the only ServiceControl instance then 33334 is recommended.
#
# @param maximum_concurrency_level
#   This setting controls how many messages can be processed concurrently (in parallel) by ServiceControl.
#
# @param retry_history_depth
#   The depth of retry history.
#
# @param remote_instances
#   Specify an optional array of remote instances.
#
# @param expose_ravendb
#   Specify if the embedded ravendb database should be accessible outside of maintenance mode.
#
# @param ravendb_log_level
#   Specify the level of logging that should be used in ravendb logs.
#
# @param error_queue
#   Specify ErrorQueue name to consume messages from.
#
# @param error_log_queue
#   Specify Queue name to forward error messages to.
#
# @param transport
#   Specify the NServiceBus Transport to use.
#
# @param display_name
#   Specify the Windows Service Display name. If unspecified the instance name will be used.
#
# @param connection_string
#   Specify the connection string to use to connect to the queuing system.
#
# @param description
#   Specify the description to use on the Windows Service for this instance.
#
# @param forward_error_messages
#   Specify if audit messages are forwarded to the queue specified by ErrorLogQueue.
#
# @param service_account
#   The Account to run the Windows service.
#
# @param service_account_password
#   The password for the ServiceAccount.
#
# @param service_restart_on_config_change
#   Specify if the service control instance's windows service should be restarted to pick up changes to its configuration file.
#
# @param error_retention_period
#   Specify thd grace period that faulted messages are kept before they are deleted.
#
# @param time_to_restart_error_ingestion_after_failure
#   Specify the maximum time delay to wait before restarting the error ingestion pipeline after detecting a connection problem. This setting was introduced in ServiceControl version 4.4.1.
#
# @param disable_external_integrations_publishing
#   Disable external integrations publishing.
#
# @param enable_full_text_search_on_bodies
#   Allows full text searches to happen on the body of messages. This setting was introduced in ServiceControl version 4.17.0.
#
# @param event_retention_period
#   Specifies the period to keep event logs before they are deleted.
#
# @param expiration_process_timer_in_seconds
#   Specifies the number of seconds to wait between checking for expired messages.
#
# @param expiration_process_batch_size
#   Specifies the batch size to use when checking for expired messages.
#
# @param data_space_remaining_threshold
#   The percentage threshold for the Message database storage space check. If the remaining hard drive space drops below this threshold (as a percentage of the total space on the drive), then the check will fail, alerting the user.
#
# @param http_default_connection_limit
#   Specifies the maximum number of concurrent connections allowed by ServiceControl.
#
# @param heartbeat_grace_period
#   Specifies the period that defines whether an endpoint is considered alive or not since the last received heartbeat.
#
# @param allow_message_editing
#   Enables the ability for servicepulse to allow users to edit failed messages before being retried.
#
# @param notifications_filter
#   Configures notificaiton filters.
#
# @param service_manage
#   Specifies whether or not to manage the desired state of the windows service for this instance.
#
# @param skip_queue_creation
#   Normally an instance will attempt to create the queues that it uses. If this flag is set, queue creation will be skipped.
#
# @param remove_db_on_delete
#   Remove service control instance ravendb database when instance is deleted.
#
# @param remove_logs_on_delete
#   Remove service control instance logs when instance is deleted.
#
# @param automatic_instance_upgrades
#   Automatically upgrade the service control monitoring instance when a new version of servicecontrol is installed.
#
# @param instance_create_and_upgrade_acknowledgements
#   Acknowledge mandatory requirements have been met during instance creation and upgrades.
#
define nservicebusservicecontrol::instance (
  Enum['present', 'absent'] $ensure,
  String $instance_name                                          = $title,
  Stdlib::Absolutepath $install_path                             = "C:\\Program Files (x86)\\Particular Software\\${instance_name}",
  Stdlib::Absolutepath $log_path                                 = "C:\\ProgramData\\Particular\\ServiceControl\\${instance_name}\\Logs",
  Stdlib::Absolutepath $db_path                                  = "C:\\ProgramData\\Particular\\ServiceControl\\${instance_name}\\DB",
  Stdlib::Absolutepath $db_index_storage_path                    = "${db_path}\\Indexes",
  Stdlib::Absolutepath $db_logs_path                             = "${db_path}\\logs",
  Nservicebusservicecontrol::Log_level $instance_log_level       = 'Warn',
  Stdlib::Fqdn $host_name                                        = 'localhost',
  Stdlib::Port $port                                             = 33333,
  Stdlib::Port $database_maintenance_port                        = 33334,
  Integer $maximum_concurrency_level                             = 10,
  Integer $retry_history_depth                                   = 10,
  Optional[Array[String]] $remote_instances                      = [],
  Boolean $expose_ravendb                                        = false,
  Nservicebusservicecontrol::Log_level $ravendb_log_level        = 'Warn',
  String $error_queue                                            = 'error',
  Optional[String] $error_log_queue                              = 'error.log',
  Nservicebusservicecontrol::Transport $transport                = 'MSMQ',
  String $display_name                                           = $instance_name,
  Optional[String] $connection_string                            = undef,
  String $description                                            = 'A ServiceControl Instance',
  Boolean $forward_error_messages                                = false,
  String $service_account                                        = 'LocalSystem',
  Optional[String] $service_account_password                     = undef,
  Boolean $service_restart_on_config_change                      = true,
  String $error_retention_period                                 = '15.00:00:00',
  String $time_to_restart_error_ingestion_after_failure          = '00.00:01:00',
  Boolean $disable_external_integrations_publishing              = false,
  String $event_retention_period                                 = '14.00:00:00',
  Boolean $enable_full_text_search_on_bodies                     = true,
  Integer $expiration_process_timer_in_seconds                   = 600,
  Integer $expiration_process_batch_size                         = 65512,
  Integer $data_space_remaining_threshold                        = 20,
  Integer $http_default_connection_limit                         = 100,
  String $heartbeat_grace_period                                 = '00:00:40',
  Boolean $allow_message_editing                                 = false,
  String $notifications_filter                                   = '',
  Boolean $service_manage                                        = true,
  Boolean $skip_queue_creation                                   = false,
  Boolean $remove_db_on_delete                                   = false,
  Boolean $remove_logs_on_delete                                 = false,
  Boolean $automatic_instance_upgrades                           = true,
  Optional[String] $instance_create_and_upgrade_acknowledgements = undef,
) {
  if $ensure == 'present' {
    if $transport == 'MSMQ' or $transport == 'AmazonSQS' {
      if $connection_string != undef {
        fail('Cannot provide connection_string when using the MSMQ transport')
      }
    }

    exec { "create-service-control-instance-${instance_name}":
      # I could also maybe look at the following to determine idempotence of create
      # 1.) Does a service exist with the name of the instance
      # 2.) Does the following folder exist $install_path
      command   => epp("${module_name}/create-instance.ps1.epp", {
          'instance_name'                                => $instance_name,
          'install_path'                                 => $install_path,
          'log_path'                                     => $log_path,
          'db_path'                                      => $db_path,
          'host_name'                                    => $host_name,
          'port'                                         => $port,
          'database_maintenance_port'                    => $database_maintenance_port,
          'error_queue'                                  => $error_queue,
          'error_log_queue'                              => $error_log_queue,
          'transport'                                    => $transport,
          'display_name'                                 => $display_name,
          'connection_string'                            => $connection_string,
          'description'                                  => $description,
          'forward_error_messages'                       => $forward_error_messages,
          'service_account'                              => $service_account,
          'service_account_password'                     => $service_account_password,
          'error_retention_period'                       => $error_retention_period,
          'skip_queue_creation'                          => $skip_queue_creation,
          'enable_full_text_search_on_bodies'            => $enable_full_text_search_on_bodies,
          'instance_create_and_upgrade_acknowledgements' => $instance_create_and_upgrade_acknowledgements,
      }),
      onlyif    => epp("${module_name}/query-instance.ps1.epp", {
          'instance_name' => $instance_name,
      }),
      logoutput => true,
      provider  => 'powershell',
    }

    if $automatic_instance_upgrades {
      exec { "automatic-instance-upgrade-${instance_name}":
        command   => epp("${module_name}/upgrade-instance.ps1.epp", {
            'instance_name'                                => $instance_name,
            'instance_create_and_upgrade_acknowledgements' => $instance_create_and_upgrade_acknowledgements,
        }),
        onlyif    => epp("${module_name}/query-instance-upgrade.ps1.epp", {
            'instance_name' => $instance_name,
            'install_path'  => $install_path,
        }),
        logoutput => true,
        provider  => 'powershell',
        require   => Exec["create-service-control-instance-${instance_name}"],
      }
    }

    $_transport_type = $transport ? {
      'RabbitMQ - Conventional routing topology'                  => 'ServiceControl.Transports.RabbitMQ.RabbitMQConventionalRoutingTransportCustomization, ServiceControl.Transports.RabbitMQ',
      'RabbitMQ - Conventional routing topology (classic queues)' => 'ServiceControl.Transports.RabbitMQ.RabbitMQClassicConventionalRoutingTransportCustomization, ServiceControl.Transports.RabbitMQ',
      'RabbitMQ - Conventional routing topology (quorum queues)'  => 'ServiceControl.Transports.RabbitMQ.RabbitMQQuorumConventionalRoutingTransportCustomization, ServiceControl.Transports.RabbitMQ',
      'SQL Server'                                                => 'ServiceControl.Transports.SqlServer.SqlServerTransportCustomization, ServiceControl.Transports.SqlServer',
      'MSMQ'                                                      => 'ServiceControl.Transports.Msmq.MsmqTransportCustomization, ServiceControl.Transports.Msmq',
      'Azure Storage Queue'                                       => 'ServiceControl.Transports.ASQ.ASQTransportCustomization, ServiceControl.Transports.ASQ',
      'Azure Service Bus'                                         => 'ServiceControl.Transports.ASBS.ASBSTransportCustomization, ServiceControl.Transports.ASBS',
      'AmazonSQS'                                                 => 'ServiceControl.Transports.SQS.SQSTransportCustomization, ServiceControl.Transports.SQS',
      # lint:ignore:140chars
      default                                                     => fail("${transport} is not a known or valid transport that can be used with this module.  If this is a mistake please open a ticket on github."),
      # lint:endignore
    }

    file { "${install_path}\\ServiceControl.exe.config":
      ensure  => 'file',
      content => unix2dos(epp("${module_name}/ServiceControl.exe.config.epp", {
            'instance_log_level'                            => $instance_log_level,
            'db_path'                                       => $db_path,
            'db_index_storage_path'                         => $db_index_storage_path,
            'db_logs_path'                                  => $db_logs_path,
            'log_path'                                      => $log_path,
            'host_name'                                     => $host_name,
            'port'                                          => $port,
            'database_maintenance_port'                     => $database_maintenance_port,
            'maximum_concurrency_level'                     => $maximum_concurrency_level,
            'retry_history_depth'                           => $retry_history_depth,
            'remote_instances'                              => $remote_instances,
            'expose_ravendb'                                => $expose_ravendb,
            'ravendb_log_level'                             => $ravendb_log_level,
            'error_queue'                                   => $error_queue,
            'error_log_queue'                               => $error_log_queue,
            '_transport_type'                               => $_transport_type,
            'connection_string'                             => $connection_string,
            'forward_error_messages'                        => $forward_error_messages,
            'error_retention_period'                        => $error_retention_period,
            'enable_full_text_search_on_bodies'             => $enable_full_text_search_on_bodies,
            'time_to_restart_error_ingestion_after_failure' => $time_to_restart_error_ingestion_after_failure,
            'disable_external_integrations_publishing'      => $disable_external_integrations_publishing,
            'event_retention_period'                        => $event_retention_period,
            'expiration_process_timer_in_seconds'           => $expiration_process_timer_in_seconds,
            'expiration_process_batch_size'                 => $expiration_process_batch_size,
            'data_space_remaining_threshold'                => $data_space_remaining_threshold,
            'http_default_connection_limit'                 => $http_default_connection_limit,
            'heartbeat_grace_period'                        => $heartbeat_grace_period,
            'allow_message_editing'                         => $allow_message_editing,
            'notifications_filter'                          => $notifications_filter,
      })),
      require => Exec["create-service-control-instance-${instance_name}"],
    }

    if $service_manage {
      if $service_restart_on_config_change {
        File["${install_path}\\ServiceControl.exe.config"] ~> Exec["restart-slow-service-${instance_name}"]
      }

      exec { "restart-slow-service-${instance_name}":
        # lint:ignore:140chars
        command     => "try { Restart-Service -Name ${instance_name} -ErrorAction Stop; exit 0 } catch { Write-Output \$_.Exception.Message; exit 1 }",
        # lint:endignore
        logoutput   => true,
        refreshonly => true,
        provider    => 'powershell',
        subscribe   => File["${install_path}\\ServiceControl.exe.config"],
      }

      service { $instance_name:
        ensure => running,
        enable => true,
      }
    }
  } else {
    exec { "delete ServiceControl Instance ${instance_name}":
      command   => epp("${module_name}/delete-instance.ps1.epp", {
          'instance_name'         => $instance_name,
          'remove_db_on_delete'   => $remove_db_on_delete,
          'remove_logs_on_delete' => $remove_logs_on_delete,
      }),
      unless    => epp("${module_name}/query-instance.ps1.epp", {
          'instance_name' => $instance_name,
      }),
      logoutput => true,
      provider  => 'powershell',
    }
  }
}
