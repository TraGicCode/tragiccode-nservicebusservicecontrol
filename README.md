# nservicebusservicecontrol

[![Puppet Forge Version](http://img.shields.io/puppetforge/v/tragiccode/nservicebusservicecontrol.svg)](https://forge.puppetlabs.com/tragiccode/nservicebusservicecontrol)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/tragiccode/nservicebusservicecontrol.svg)](https://forge.puppetlabs.com/tragiccode/nservicebusservicecontrol)
[![Puppet Forge Pdk Version](http://img.shields.io/puppetforge/pdk-version/tragiccode/nservicebusservicecontrol.svg)](https://forge.puppetlabs.com/tragiccode/nservicebusservicecontrol)

#### Table of Contents

1. [Description](#description)
1. [Setup requirements](#setup-requirements)
    * [Beginning with nservicebusservicecontrol](#beginning-with-nservicebusservicecontrol)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Service Control Deployment Topologies](#service-control-deployment-topologies)
    * [Service Control Instances](#service-control-instances)
    * [Service Control Audit Instances](#service-control-audit-instances)
    * [Service Control Monitoring Instances](#service-control-monitoring-instances)
    * [Reimport failed errror/audit messages](#reimport-failed-error/audit-messages)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Contributing](#contributing)

## Description

The nservicebusservicecontrol module installs and manages Service Control along with Service Control Instances.

ServiceControl is the backend web api used for monitoring and replaying of messages for nservicebus endpoints.

### Setup Requirements

The nservicebusservicecontrol module requires the following:

* Puppet Agent 4.7.1 or later.
* Access to the internet.
* Microsoft .NET 4.6.1 Runtime.
* Windows Server 2012/2012R2/2016/2019.

### Beginning with nservicebusservicecontrol

To get started with the nservicebusservicecontrol module simply include the following in your manifest:

```puppet
include nservicebusservicecontrol
```

This example downloads, installs, and configures the latest version of servicecontrol.  After running this you should be able to begin to create service control instances and perform other tasks using the `nservicebusservicecontrol::instance`, `nservicebusservicecontrol::audit_instance`, and `nservicebusservicecontrol::monitoring_instance` defined types.

**NOTE: By default this module pulls the package from chocolatey (https://chocolatey.org/packages/servicecontrol)**

## Usage

All parameters for the nservicebusservicecontrol module are contained within the main `nservicebusservicecontrol` class, so for any function of the module, set the options you want. See the common usages below for examples.

### Install a specific version of service control from chocolatey

```puppet
class { 'nservicebusservicecontrol':
  package_ensure     => '4.3.3',
}
```

**NOTE: We recommend always specifying a specific version so that it's easily viewable and explicit in code.  The default value is present which just grabs whatever version happens to be the latest at the time your first puppet run happened with this code**

### Automatically install newer versions as they are released on chocolatey

```puppet
class { 'nservicebusservicecontrol':
  package_ensure     => 'latest',
}
```

**NOTE: Put simply, never use this in production ( or really anywhere to be honest ).  New versions could contain major breaking changes that this module is incompatible possibly putting servicecontrol in a unknown/undefined state.**

### Install your license

```puppet
$license_xml = @(LICENSE)
<?xml version="1.0" encoding="utf-8"?>
<license type="Commercial" DeploymentType="Elastic Cloud" Quantity="4" Edition="Enterprise" Applications="All" RenewalType="Subscription" expiration="2020-01-23" Notes="BlueSnap" id="7d26ad59-8805-4da6-8dad-f3540213ca">
...
</license>
LICENSE

class { 'nservicebusservicecontrol':
  package_ensure     => 'present',
  license_xml        => $license_xml,
}
```

### Service Control Deployment Topologies

When installing and configuring service control in your environment you have multiple deployment topologies available depending on your needs.

**NOTE: Read more about deployment topologies here https://docs.particular.net/servicecontrol/servicecontrol-instances/remotes**

#### Default Deployment

This deployment is the most typical and contains 1 primary/main service control instance and 1 service control audit instance.

```puppet
$primary_service_control_instance = 'Particular.ServiceControl.Development'

nservicebusservicecontrol::instance { $primary_service_control_instance:
  ensure            => 'present',
  transport         => 'RabbitMQ - Conventional routing topology',
  connection_string => 'host=localhost;username=guest;password=guest',
  remote_instances  => ['http://localhost:44444/api'],
}

nservicebusservicecontrol::audit_instance { "${primary_service_control_instance}.Audit":
  ensure                        => 'present',
  port                          => 44444, # This is the default but added here for clarity
  transport                     => 'RabbitMQ - Conventional routing topology',
  connection_string             => 'host=localhost;username=guest;password=guest',
  service_control_queue_address => $primary_service_control_instance,
}
```

**NOTE: The primary/main servicecontrol instance must be created first.  This is because in order to create a servicecontrol audit instance you must pass in the queue name of the primary service control instance in which to send notifications to (https://docs.particular.net/servicecontrol/audit-instances/installation-powershell#servicecontrol-audit-instance-cmdlets-and-aliases-adding-an-instance )**

#### Sharding Audit Messages With Competing Consumers

This deployment is commonly used when you have a high number of messages and need to use the competing consumers pattern on the your audit queue.

```puppet
$primary_service_control_instance = 'Particular.ServiceControl.Development'

nservicebusservicecontrol::instance { $primary_service_control_instance:
  ensure            => 'present',
  transport         => 'RabbitMQ - Conventional routing topology',
  connection_string => 'host=localhost;username=guest;password=guest',
  remote_instances  => ['http://localhost:44444/api', 'http://localhost:44445/api'],
}

nservicebusservicecontrol::audit_instance { "${primary_service_control_instance}.Audit":
  ensure                        => 'present',
  port                          => 44444, # This is the default but added here for clarity
  transport                     => 'RabbitMQ - Conventional routing topology',
  connection_string             => 'host=localhost;username=guest;password=guest',
  service_control_queue_address => $primary_service_control_instance,
}

nservicebusservicecontrol::audit_instance { "${primary_service_control_instance}.Audit2":
  ensure                        => 'present',
  port                          => 44445,
  database_maintenance_port     => 44446,
  transport                     => 'RabbitMQ - Conventional routing topology',
  connection_string             => 'host=localhost;username=guest;password=guest',
  service_control_queue_address => $primary_service_control_instance,
}
```

#### Sharding Audit Messages With Split Audit Queue

This deployment is commonly used when you have endpoints whos audit messages should have different retention periods.

```puppet
$primary_service_control_instance = 'Particular.ServiceControl.Development'

nservicebusservicecontrol::instance { $primary_service_control_instance:
  ensure            => 'present',
  transport         => 'RabbitMQ - Conventional routing topology',
  connection_string => 'host=localhost;username=guest;password=guest',
  remote_instances  => ['http://localhost:44444/api', 'http://localhost:44445/api'],
}

nservicebusservicecontrol::audit_instance { "${primary_service_control_instance}.Audit":
  ensure                        => 'present',
  port                          => 44444, # This is the default but added here for clarity
  transport                     => 'RabbitMQ - Conventional routing topology',
  connection_string             => 'host=localhost;username=guest;password=guest',
  service_control_queue_address => $primary_service_control_instance,
}

nservicebusservicecontrol::audit_instance { "${primary_service_control_instance}.CustomerRelations.Audit":
  ensure                        => 'present',
  port                          => 44445,
  database_maintenance_port     => 44446,
  transport                     => 'RabbitMQ - Conventional routing topology',
  connection_string             => 'host=localhost;username=guest;password=guest',
  audit_queue                   => 'audit.customerrelations',
  service_control_queue_address => $primary_service_control_instance,
}

```

### Service Control Instances

This represents the primary/main service control instance that ingests messages from your centralized error queue.

**NOTE: In most cases users will install both a primary/main service control instance to ingest from their error queue with one or more audit instances ( remote instances ) to ingest from their audit queue.  The examples below this point highlight specifically the main/primary service control instance and therefore the audit instance resource you typically declare next to it is left out for brevity**

#### Create a Service Control Instance using the MSMQ Transport

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure           => 'present',
  transport        => 'MSMQ',
}
```

**NOTE: Ensure the MSMQ Windows Feature is is already installed.  ServiceControl by default will take care of creating the tables for using as queues**

#### Create a Service Control Instance using the RabbitMQ Conventional Routing Topology Transport

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure            => 'present',
  transport         => 'RabbitMQ - Conventional routing topology',
  connection_string => 'host=localhost;username=guest;password=guest',
}
```

#### Create a Service Control Instance using the SQLServer Transport ( SQL Authentication )

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure            => 'present',
  transport         => 'SQL Server',
  connection_string => 'Data Source=.; Database=Particular.ServiceControl.Development; User Id=svc-servicecontrol; Password=super-secret-password;',
}
```

**NOTE: Ensure the database is already created and the user can connect.  ServiceControl by default will take care of creating the tables for using as queues.**

#### Create a Service Control Instance using the SQLServer Transport ( Windows Authentication )

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure                   => 'present',
  transport                => 'SQL Server',
  connection_string        => 'Data Source=.; Database=Particular.ServiceControl.Development; Trusted_Connection=True;',
  service_account          => 'DOMAIN\svc-servicecontrol',
  service_account_password => 'super-secret-password',
}
```

**NOTE: Ensure the database is already created and the user can connect.  ServiceControl by default will take care of creating the tables for using as queues.**

#### Create a Service Control Instance using the Azure Storage Queue Transport

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure            => 'present',
  transport         => 'Azure Storage Queue',
  # connection_string => 'UseDevelopmentStorage=true',
  connection_string => 'DefaultEndpointsProtocol=https;AccountName=[ACCOUNT];AccountKey=[KEY];',
  ...
}
```

#### Create a Service Control Instance using the Azure Service Bus Transport

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure            => 'present',
  transport         => 'Azure Service Bus',
  connection_string => 'Endpoint=sb://[NAMESPACE].servicebus.windows.net/;SharedAccessKeyName=[KEYNAME];SharedAccessKey=[KEY]',
  ...
}
```

#### Create a Service Control Instance using the Amazon SQS Transport

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure    => 'present',
  transport => 'AmazonSQS',
  ...
}
```

#### Service Control Instance with forward error queues

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure                 => 'present',
  transport              => 'RabbitMQ - Conventional routing topology',
  connection_string      => 'host=localhost;username=guest;password=guest',
  forward_error_messages => true,
  error_log_queue        => 'error.log',
}
```

**NOTE: If external integration is not required, it is highly recommend to turn forwarding queues off. Otherwise, messages will accumulate unprocessed in the forwarding queue until eventually all available disk space is consume**

#### Enable ability to edit message body & headers in Service Pulse

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure                 => 'present',
  transport              => 'RabbitMQ - Conventional routing topology',
  connection_string      => 'host=localhost;username=guest;password=guest',
  allow_message_editing  => true,
}
```

### Service Control Audit Instances

This represents the 1 or more service control audit instance that ingests messages from your centralized audit queue.  This is also needed if you plan on utilizing the Particular
Service Insight tool for debugging.

#### Create a Service Control Audit Instance using the MSMQ Transport

```puppet
nservicebusservicecontrol::audit_instance { 'Particular.ServiceControl.Development.Audit':
  ensure                        => 'present',
  transport                     => 'MSMQ',
  service_control_queue_address => 'Particular.ServiceControl.Development', # The queue name of the primary/main service control instance
}
```

**NOTE: Ensure the MSMQ Windows Feature is is already installed.  ServiceControl by default will take care of creating the tables for using as queues**

#### Create a Service Control Audit Instance using the RabbitMQ Conventional Routing Topology Transport

```puppet
nservicebusservicecontrol::audit_instance { 'Particular.ServiceControl.Development.Audit':
  ensure                        => 'present',
  transport                     => 'RabbitMQ - Conventional routing topology',
  connection_string             => 'host=localhost;username=guest;password=guest',
  service_control_queue_address => 'Particular.ServiceControl.Development', # The queue name of the primary/main service control instance
}
```

#### Create a Service Control Audit Instance using the SQLServer Transport ( SQL Authentication )

```puppet
nservicebusservicecontrol::audit_instance { 'Particular.ServiceControl.Development.Audit':
  ensure                        => 'present',
  transport                     => 'SQL Server',
  connection_string             => 'Data Source=.; Database=Particular.ServiceControl.Development; User Id=svc-servicecontrol; Password=super-secret-password;',
  service_control_queue_address => 'Particular.ServiceControl.Development', # The queue name of the primary/main service control instance
}
```

**NOTE: Ensure the database is already created and the user can connect.  ServiceControl by default will take care of creating the tables for using as queues.**

#### Create a Service Control Audit Instance using the SQLServer Transport ( Windows Authentication )

```puppet
nservicebusservicecontrol::audit_instance { 'Particular.ServiceControl.Development.Audit':
  ensure                        => 'present',
  transport                     => 'SQL Server',
  connection_string             => 'Data Source=.; Database=Particular.ServiceControl.Development; Trusted_Connection=True;',
  service_account               => 'DOMAIN\svc-servicecontrol',
  service_account_password      => 'super-secret-password',
  service_control_queue_address => 'Particular.ServiceControl.Development', # The queue name of the primary/main service control instance
}
```

**NOTE: Ensure the database is already created and the user can connect.  ServiceControl by default will take care of creating the tables for using as queues.**

#### Create a Service Control Audit Instance using the Azure Storage Queue Transport

```puppet
nservicebusservicecontrol::audit_instance { 'Particular.ServiceControl.Development.Audit':
  ensure                        => 'present',
  transport                     => 'Azure Storage Queue',
  # connection_string           => 'UseDevelopmentStorage=true',
  connection_string             => 'DefaultEndpointsProtocol=https;AccountName=[ACCOUNT];AccountKey=[KEY];',
  service_control_queue_address => 'Particular.ServiceControl.Development', # The queue name of the primary/main service control instance
  ...
}
```

#### Create a Service Control Audit Instance using the Azure Service Bus Transport

```puppet
nservicebusservicecontrol::audit_instance { 'Particular.ServiceControl.Development.Audit':
  ensure                        => 'present',
  transport                     => 'Azure Service Bus',
  connection_string             => 'Endpoint=sb://[NAMESPACE].servicebus.windows.net/;SharedAccessKeyName=[KEYNAME];SharedAccessKey=[KEY]',
  service_control_queue_address => 'Particular.ServiceControl.Development', # The queue name of the primary/main service control instance
  ...
}
```

#### Create a Service Control Audit Instance using the Amazon SQS Transport

```puppet
nservicebusservicecontrol::audit_instance { 'Particular.ServiceControl.Development.Audit':
  ensure                        => 'present',
  transport                     => 'AmazonSQS',
  service_control_queue_address => 'Particular.ServiceControl.Development', # The queue name of the primary/main service control instance
  ...
}
```

#### Service Control Audit Instance with forward audit queues

```puppet
nservicebusservicecontrol::audit_instance { 'Particular.ServiceControl.Development.Audit':
  ensure                        => 'present',
  transport                     => 'RabbitMQ - Conventional routing topology',
  connection_string             => 'host=localhost;username=guest;password=guest',
  forward_audit_messages        => true,
  audit_log_queue               => 'audit.log',
  service_control_queue_address => 'Particular.ServiceControl.Development', # The queue name of the primary/main service control instance
}
```

**NOTE: If external integration is not required, it is highly recommend to turn forwarding queues off. Otherwise, messages will accumulate unprocessed in the forwarding queue until eventually all available disk space is consume**

### Service Control Monitoring Instances

#### Create a Service Control Monitoring Instance using the MSMQ Transport

```puppet
nservicebusservicecontrol::monitoring_instance { 'Particular.Monitoring.Development':
  ensure                        => 'present',
  transport                     => 'MSMQ',
  service_control_queue_address => 'Particular.ServiceControl.Development' # the name of the control queue
}
```

**NOTE: Ensure the MSMQ Windows Feature is is already installed.  ServiceControl by default will take care of creating the tables for using as queues**

#### Create a Service Control Monitoring Instance using the RabbitMQ Conventional Routing Topology Transport

```puppet
nservicebusservicecontrol::monitoring_instance { 'Particular.Monitoring.Development':
  ensure            => 'present',
  transport         => 'RabbitMQ - Conventional routing topology',
  connection_string => 'host=localhost;username=guest;password=guest',
}
```

#### Create a Service Control Monitoring Instance using the SQLServer Transport ( SQL Authentication )

```puppet
nservicebusservicecontrol::monitoring_instance { 'Particular.Monitoring.Development':
  ensure            => 'present',
  transport         => 'SQL Server',
  connection_string => 'Data Source=.; Database=Particular.Monitoring.Development; User Id=svc-servicecontrol; Password=super-secret-password;',
}
```

**NOTE: Ensure the database is already created and the user can connect.  ServiceControl by default will take care of creating the tables for using as queues.**

#### Create a Service Control Monitoring Instance using the SQLServer Transport ( Windows Authentication )

```puppet
nservicebusservicecontrol::monitoring_instance { 'Particular.Monitoring.Development':
  ensure                   => 'present',
  transport                => 'SQL Server',
  connection_string        => 'Data Source=.; Database=Particular.Monitoring.Development; Trusted_Connection=True;',
  service_account          => 'DOMAIN\svc-servicecontrol',
  service_account_password => 'super-secret-password',
}
```

**NOTE: Ensure the database is already created and the user can connect.  ServiceControl by default will take care of creating the tables for using as queues.**

#### Create a Service Control Monitoring Instance using the Azure Storage Queue Transport

```puppet
nservicebusservicecontrol::monitoring_instance { 'Particular.Monitoring.Development':
  ensure              => 'present',
  transport           => 'Azure Storage Queue',
  # connection_string => 'UseDevelopmentStorage=true',
  connection_string   => 'DefaultEndpointsProtocol=https;AccountName=[ACCOUNT];AccountKey=[KEY];',
  ..
}
```

#### Create a Service Control Instance using the Azure Service Bus Transport

```puppet
nservicebusservicecontrol::monitoring_instance { 'Particular.Monitoring.Development':
  ensure            => 'present',
  transport         => 'Azure Service Bus',
  connection_string => 'Endpoint=sb://[NAMESPACE].servicebus.windows.net/;SharedAccessKeyName=[KEYNAME];SharedAccessKey=[KEY]',
  ...
}
```

#### Create a Service Control Instance using the Amazon SQS Transport

```puppet
nservicebusservicecontrol::monitoring_instance { 'Particular.Monitoring.Development':
  ensure    => 'present',
  transport => 'AmazonSQS',
  ...
}
```

### Reimport failed errror/audit messages

When you have messages that fail to be imported you can easily re-import them in an automated and painless way using the `nservicebusservicecontrol::import_failed_messages` bolt plan.

**NOTE: This plan requires the puppet agent installed on the remote.**

```
$ bolt plan show nservicebusservicecontrol::import_failed_messages

nservicebusservicecontrol::import_failed_messages - Imports failed error or audit message.

USAGE:
bolt plan run nservicebusservicecontrol::import_failed_messages targets=<value> instance_name=<value> instance_type=<value>

PARAMETERS:
- targets: TargetSpec
    Targets to import failed messags on.
- instance_name: String
    The name of the servicecontrol instance.
- instance_type: Enum['error', 'audit']
    The servicecontrol instance type (Audit or Error).
```

#### Workflow followed by plan

Below is the documented workflow of the above `nservicebusservicecontrol::import_failed_messages` plan so that you, as an administrator, have a better understanding on what to expect and what is happening.

1. Disable the puppet agent
1. Wait for any currently active puppet agent runs to finish
1. Stop the specificed service control instance
1. Import the failed error or audit messages
1. Start the specified service control instance
2. Enable the puppet agent

## Reference

See [REFERENCE.md](https://github.com/tragiccode/tragiccode-nservicebusservicecontrol/blob/master/REFERENCE.md)

## Limitations

### Unable to detect failing to create servicecontrol instance

There is a bug in the New-ServiceControlInstance powershell cmdlet that ships with servicecontrol that causes any failure to not be propogated to the caller correctly. This makes it impossible
to determine if the instance creation was successful or failed.  Therefore, failed puppet runs could be misleading and the resulting errors might be caused from this situation. 

https://github.com/Particular/ServiceControl/issues/1565

### Forwarding queues are created only at servicecontrol instance creation time only

If you enable the error or audit forwarding queue features after a service control instance is created these queues will not get created.  It's therefore your responsibility to manually create these and set them up if you
decide to change your mind after a servicecontrol instance has been created.  This is a limitation of servicecontrol itself.

### Unsupported transports

I have selectively chosen not to support what appears to be old or deprecated transports.  If you need one feel free to open an issue and if your feeling lucky submitting a pull-request.

* Azure Service Bus - Forwarding topology (Legacy)
* Azure Service Bus - Forwarding topology (Old)
* Azure Service Bus - Endpoint-oriented topology (Legacy)
* Azure Service Bus - Endpoint-oriented topology (Old)
* RabbitMQ - Direct routing topology (Old)

## Contributing

1. Fork it ( https://github.com/tragiccode/tragiccode-nservicebusservicecontrol/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request