require 'spec_helper_acceptance'

# NOTE
# I am currently unable to test uninstalling the package because of package removal failing
# when deleting servicecontrol instances in the same puppet run.  My hunch is there is some
# file locking happening that is causing this but needs further investigation
describe 'Uninstalling ServiceControl and configuring Error, Audit, and Monitoring Instance' do
  let(:pp) do
    <<-MANIFEST
    $primary_service_control_instance = 'Particular.ServiceControl.Development'

    nservicebusservicecontrol::instance { $primary_service_control_instance:
      ensure                                       => 'absent',
      port                                         => 33333, # This is the default but added here for clarity
      transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
      instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
      connection_string                            => 'host=localhost;username=guest;password=guest',
      remote_instances                             => ['http://localhost:44444/api'],
    }

    nservicebusservicecontrol::audit_instance { "${primary_service_control_instance}.Audit":
      ensure                                       => 'absent',
      port                                         => 44444, # This is the default but added here for clarity
      transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
      instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
      connection_string                            => 'host=localhost;username=guest;password=guest',
      service_control_queue_address                => $primary_service_control_instance,
    }

    nservicebusservicecontrol::monitoring_instance { "${primary_service_control_instance}.Monitoring":
      ensure                                       => 'absent',
      port                                         => 33633, # This is the default but added here for clarity
      transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
      instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
      connection_string                            => 'host=localhost;username=guest;password=guest',
    }

    nservicebusservicecontrol::retry_redirect { 'Ordering.Endpoint':
      ensure => absent,
      destination_queue => 'SomeOtherEndpoint',
      service_control_url => 'http://localhost:33333',
    }
    MANIFEST
  end

  it 'applies idempotently' do
    idempotent_apply(pp)
  end

  describe port(33_333) do
    it { is_expected.not_to be_listening }
  end

  describe port(44_444) do
    it { is_expected.not_to be_listening }
  end

  describe port(33_633) do
    it { is_expected.not_to be_listening }
  end

  describe service('Particular.ServiceControl.Development') do
    it { is_expected.not_to be_running }
  end

  describe service('Particular.ServiceControl.Development.Audit') do
    it { is_expected.not_to be_running }
  end

  describe service('Particular.ServiceControl.Development.Monitoring') do
    it { is_expected.not_to be_running }
  end
end
