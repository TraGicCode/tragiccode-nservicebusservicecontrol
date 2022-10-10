# @summary Manages Service Control Monitoring Instances.
#
# @param ensure
#   Specifies whether the monitoring instance should exist.
#
# @param instance_name
#   Specify the name of the ServiceControl Monitoring Instance (title).
#
# @param install_path
#   Specify the directory to use for this ServiceControl Monitoring Instance.
#
# @param log_path
#   Specify the directory to use for this ServiceControl Monitoring Logs.
#
# @param instance_log_level
#   Specify the level of logging that should be used in ServiceControl Monitoring logs.
#
# @param host_name
#   Specify the hostname to use in the URLACL.
#
# @param port
#   Specify the port number to listen on. If this is the only ServiceControl Monitoring instance then 33633 is recommended.
#
# @param maximum_concurrency_level
#   This setting controls how many messages can be processed concurrently (in parallel) by ServiceControl.
#
# @param endpoint_uptime_grace_period
#   The grace period for endpoint uptime.
#
# @param error_queue
#   Specify the ErrorQueue name.
#
# @param transport
#   Specify the NServiceBus Transport to use.
#
# @param display_name
#   Specify the Windows Service Display name. If unspecified the monitoring instance name will be used.
#
# @param connection_string
#   Specify the connection string to use to connect to the queuing system.
#
# @param description
#   Specify the description to use on the Windows Service for this instance.
#
# @param service_account
#   The Account to run the Windows service.
#
# @param service_account_password
#   The password for the ServiceAccount.
#
# @param service_restart_on_config_change
#   Specify if the servicecontrol monitoring instance's windows service should be restarted to pick up changes to its configuration file.
#
# @param service_manage
#   Specifies whether or not to manage the desired state of the windows service for this instance.
#
# @param skip_queue_creation
#   Normally an instance will attempt to create the queues that it uses. If this flag is set, queue creation will be skipped.
#
# @param remove_logs_on_delete
#   Specifies if the service control logs should be deleted with the instance.
#
# @param automatic_instance_upgrades
#   Automatically upgrade the service control monitoring instance when a new version of servicecontrol is installed.
#
# @param instance_create_and_upgrade_acknowledgements
#   Acknowledge mandatory requirements have been met during instance creation and upgrades.
#
define nservicebusservicecontrol::monitoring_instance (
  Enum['present', 'absent'] $ensure,
  String $instance_name                                    = $title,
  Stdlib::Absolutepath $install_path                       = "C:\\Program Files (x86)\\Particular Software\\${instance_name}",
  Stdlib::Absolutepath $log_path                           = "C:\\ProgramData\\Particular\\ServiceControl\\${instance_name}\\Logs",
  Nservicebusservicecontrol::Log_level $instance_log_level = 'Warn',
  Stdlib::Fqdn $host_name                                  = 'localhost',
  Stdlib::Port $port                                       = 33633,
  Integer $maximum_concurrency_level                       = 32,
  String $endpoint_uptime_grace_period                     = '00:00:40',
  String $error_queue                                      = 'error',
  Nservicebusservicecontrol::Transport $transport          = 'MSMQ',
  String $display_name                                     = $instance_name,
  Optional[String] $connection_string                      = undef,
  String $description                                      = 'A Monitoring Instance',
  String $service_account                                  = 'LocalSystem',
  Optional[String] $service_account_password               = undef,
  Boolean $service_restart_on_config_change                = true,
  Boolean $service_manage                                  = true,
  Boolean $skip_queue_creation                             = false,
  Boolean $remove_logs_on_delete                           = false,
  Boolean $automatic_instance_upgrades                     = true,
  Optional[String] $instance_create_and_upgrade_acknowledgements = undef,
  ) {

  if $ensure == 'present' {

    if $transport == 'MSMQ' or $transport == 'AmazonSQS' {
      if $connection_string != undef {
        fail('Cannot provide connection_string when using the MSMQ transport')
      }
    }

    exec { "create-service-control-monitoring-instance-${instance_name}":
      # I could also maybe look at the following to determine idempotence of create
      # 1.) Does a service exist with the name of the instance
      # 2.) Does the following folder exist $install_path
      command   => epp("${module_name}/create-monitoring-instance.ps1.epp", {
        'instance_name'                                => $instance_name,
        'install_path'                                 => $install_path,
        'log_path'                                     => $log_path,
        'host_name'                                    => $host_name,
        'port'                                         => $port,
        'error_queue'                                  => $error_queue,
        'transport'                                    => $transport,
        'display_name'                                 => $display_name,
        'connection_string'                            => $connection_string,
        'description'                                  => $description,
        'service_account'                              => $service_account,
        'service_account_password'                     => $service_account_password,
        'skip_queue_creation'                          => $skip_queue_creation,
        'instance_create_and_upgrade_acknowledgements' => $instance_create_and_upgrade_acknowledgements,
      }),
      onlyif    => epp("${module_name}/query-monitoring-instance.ps1.epp", {
        'instance_name' => $instance_name,
        }),
      logoutput => true,
      provider  => 'powershell',
    }

    if $automatic_instance_upgrades {
      exec { "automatic-monitoring-instance-upgrade-${instance_name}":
        command   => epp("${module_name}/upgrade-monitoring-instance.ps1.epp", {
          'instance_name'                                => $instance_name,
          'instance_create_and_upgrade_acknowledgements' => $instance_create_and_upgrade_acknowledgements,
        }),
        onlyif    => epp("${module_name}/query-monitoring-instance-upgrade.ps1.epp", {
          'instance_name' => $instance_name,
          'install_path'  => $install_path,
        }),
        logoutput => true,
        provider  => 'powershell',
        require   => Exec["create-service-control-monitoring-instance-${instance_name}"],
      }
    }

    $_transport_type = $transport ? {
      'RabbitMQ - Conventional routing topology'                  => 'ServiceControl.Transports.RabbitMQ.RabbitMQConventionalRoutingTransportCustomization, ServiceControl.Transports.RabbitMQ',
      'RabbitMQ - Conventional routing topology (classic queues)' => 'ServiceControl.Transports.RabbitMQ.RabbitMQClassicConventionalRoutingTransportCustomization, ServiceControl.Transports.RabbitMQ',
      'RabbitMQ - Conventional routing topology (quorum queues)'  => 'ServiceControl.Transports.RabbitMQ.RabbitMQQuorumConventionalRoutingTransportCustomization, ServiceControl.Transports.RabbitMQ',
      'SQL Server'                                                => 'ServiceControl.Transports.SQLServer.ServiceControlSQLServerTransport, ServiceControl.Transports.SQLServe',
      'MSMQ'                                                      => 'NServiceBus.MsmqTransport, NServiceBus.Transport.Msmq',
      'Azure Storage Queue'                                       => 'ServiceControl.Transports.AzureStorageQueues.ServiceControlAzureStorageQueueTransport, ServiceControl.Transports.AzureStorageQueues',
      'Azure Service Bus'                                         => 'ServiceControl.Transports.AzureServiceBus.AzureServiceBusTransport, ServiceControl.Transports.AzureServiceBus',
      'AmazonSQS'                                                 => 'ServiceControl.Transports.AmazonSQS.ServiceControlSqsTransport, ServiceControl.Transports.AmazonSQSS',
      # lint:ignore:140chars
      default                                                     => fail("${transport} is not a known or valid transport that can be used with this module.  If this is a mistake please open a ticket on github."),
      # lint:endignore
    }

  file { "${install_path}\\ServiceControl.Monitoring.exe.config":
    ensure  => 'file',
    content => unix2dos(epp("${module_name}/ServiceControl.Monitoring.exe.config.epp", {
      'endpoint_name'                => $instance_name,
      'host_name'                    => $host_name,
      'port'                         => $port,
      'maximum_concurrency_level'    => $maximum_concurrency_level,
      'endpoint_uptime_grace_period' => $endpoint_uptime_grace_period,
      'log_path'                     => $log_path,
      'instance_log_level'           => $instance_log_level,
      'error_queue'                  => $error_queue,
      '_transport_type'              => $_transport_type,
      'connection_string'            => $connection_string,
    })),
    require => Exec["create-service-control-monitoring-instance-${instance_name}"],
  }

  if $service_manage {

    if $service_restart_on_config_change {
      File["${install_path}\\ServiceControl.Monitoring.exe.config"] ~> Exec["restart-slow-service-control-monitoring-service-${instance_name}"]
    }

    exec { "restart-slow-service-control-monitoring-service-${instance_name}":
      # lint:ignore:140chars
      command     => "try { Restart-Service -Name ${instance_name} -ErrorAction Stop; exit 0 } catch { Write-Output \$_.Exception.Message; exit 1 }",
      # lint:endignore
      logoutput   => true,
      refreshonly => true,
      provider    => 'powershell',
      subscribe   => File["${install_path}\\ServiceControl.Monitoring.exe.config"],
    }

    service { $instance_name:
      ensure => running,
      enable => true,
    }
  }

  } else {
    exec { "delete-service-control-monitoring-instance-${instance_name}":
      command   => epp("${module_name}/delete-monitoring-instance.ps1.epp", {
        'instance_name'         => $instance_name,
        'remove_logs_on_delete' => $remove_logs_on_delete,
      }),
      unless    => epp("${module_name}/query-monitoring-instance.ps1.epp", {
        'instance_name' => $instance_name,
      }),
      logoutput => true,
      provider  => 'powershell',
    }
  }
}
