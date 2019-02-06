# nservicebusservicecontrol

[![Puppet Forge](http://img.shields.io/puppetforge/v/tragiccode/nservicebusservicecontrol.svg)](https://forge.puppetlabs.com/tragiccode/nservicebusservicecontrol)
[![Puppet Forge](http://img.shields.io/puppetforge/pdk-version/tragiccode/nservicebusservicecontrol.svg)](https://forge.puppetlabs.com/tragiccode/nservicebusservicecontrol)

#### Table of Contents

1. [Description](#description)
1. [Setup requirements](#setup-requirements)
    * [Beginning with nservicebusservicecontrol](#beginning-with-nservicebusservicecontrol)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Service Control Instances](#service-control-instances)
    * [Service Control Monitoring Instances](#service-control-monitoring-instances)
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
* Windows Server 2012/2012R2/2016.

### Beginning with nservicebusservicecontrol

To get started with the nservicebusservicecontrol module simply include the following in your manifest:

```puppet
include nservicebusservicecontrol
```

This example downloads, installs, and configures the latest version of servicecontrol.  After running this you should be able to begin to create service control instances and perform other tasks using the `nservicebusservicecontrol::instance` defined type.

**NOTE: By default this module pulls the package from chocolatey (https://chocolatey.org/packages/servicecontrol)**

## Usage

All parameters for the nservicebusservicecontrol module are contained within the main `nservicebusservicecontrol` class, so for any function of the module, set the options you want. See the common usages below for examples.

### Install a specific version of service control from chocolatey

```puppet
class { 'nservicebusservicecontrol':
  package_ensure     => '3.6.2',
}
```

**NOTE: We recommend always specifying a specific version so that it's easily viewable and explicit in code.  The default value is present which just grabs whatever version happens to be the latest at the time your first puppet run happened with this code**

### Automatically install newer versions as they are released on chocolatey

```puppet
class { 'nservicebusservicecontrol':
  package_ensure     => 'latest',
}
```

**NOTE: Use this with caution.  New versions could contain a bug and since servicecontrol sometimes performs migrations on upgrades it's impossible to downgrade without going through the hassle of uninstalling and reinstalling the package**

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

### Service Control Instances

#### Create a Service Control Instance using the MSMQ Transport

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure    => 'present',
  transport => 'MSMQ',
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

#### Service Control Instance with forward error & audit queues

```puppet
nservicebusservicecontrol::instance { 'Particular.ServiceControl.Development':
  ensure                 => 'present',
  transport              => 'RabbitMQ',
  connection_string      => 'host=localhost;username=guest;password=guest',
  forward_audit_messages => true,
  audit_log_queue        => 'audit.log',
  forward_error_messages => true,
  error_log_queue        => 'error.log',
}
```

**NOTE: If external integration is not required, it is highly recommend to turn forwarding queues off. Otherwise, messages will accumulate unprocessed in the forwarding queue until eventually all available disk space is consume**

### Service Control Monitoring Instances

#### Create a Service Control Monitoring Instance using the MSMQ Transport

```puppet
nservicebusservicecontrol::monitoring_instance { 'Particular.Monitoring.Development':
  ensure    => 'present',
  transport => 'MSMQ',
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
  ensure            => 'present',
  transport         => 'Azure Storage Queue',
  # connection_string => 'UseDevelopmentStorage=true',
  connection_string => 'DefaultEndpointsProtocol=https;AccountName=[ACCOUNT];AccountKey=[KEY];',
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

## Reference

See [REFERENCE.md](REFERENCE.md)

## Limitations

### Unable to detect failing to create servicecontrol instance

There is a bug in the New-ServiceControlInstance powershell cmdlet that ships with servicecontrol that causes any failure to not be propogated to the caller correctly. This makes it impossible
to determine if the instance creation was successful or failed.  Therefore, failed puppet runs could be misleading and the resulting errors might be caused from this situation. 

https://github.com/Particular/ServiceControl/issues/1565

### Forwarding queues are created only at servicecontrol instance creation time only

If you try and a forwarding queue ( error or audit ) after a service control instance is created these queues will not get created.  It's therefore your responsibility to manually create these and set them up if you
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