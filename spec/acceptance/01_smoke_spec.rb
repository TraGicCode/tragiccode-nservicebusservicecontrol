require 'spec_helper_acceptance'

# Test Cases
## Create Error Instance
## Create Audit Instance
## Create Monitoring Instance
#
# rubocop:disable RSpec/InstanceVariable
describe 'Installing ServiceControl and configuring Error, Audit, and Monitoring Instance' do
  before(:all) do
    @older_package_version = run_shell(interpolate_powershell(get_version_before_latest_of_choco_package('servicecontrol'))).stdout.strip
  end

  let(:pp) do
    <<-MANIFEST
    class { 'nservicebusservicecontrol':
      package_ensure              => '#{@older_package_version}',
    }

    $primary_service_control_instance = 'Particular.ServiceControl.Development'

    nservicebusservicecontrol::instance { $primary_service_control_instance:
      ensure                                       => 'present',
      port                                         => 33333, # This is the default but added here for clarity
      transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
      instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
      connection_string                            => 'host=localhost;username=guest;password=guest',
      remote_instances                             => ['http://localhost:44444/api'],
    }

    nservicebusservicecontrol::audit_instance { "${primary_service_control_instance}.Audit":
      ensure                                       => 'present',
      port                                         => 44444, # This is the default but added here for clarity
      transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
      instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
      connection_string                            => 'host=localhost;username=guest;password=guest',
      service_control_queue_address                => $primary_service_control_instance,
    }

    nservicebusservicecontrol::monitoring_instance { "${primary_service_control_instance}.Monitoring":
      ensure                                       => 'present',
      port                                         => 33633, # This is the default but added here for clarity
      transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
      instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
      connection_string                            => 'host=localhost;username=guest;password=guest',
    }

    nservicebusservicecontrol::retry_redirect { 'Ordering.Endpoint':
      ensure              => present,
      destination_queue   => 'SomeOtherEndpoint',
      service_control_url => 'http://localhost:33333',
    }

    MANIFEST
  end

  it 'applies idempotently' do
    idempotent_apply(pp)
  end

  describe port(33_333) do
    it { is_expected.to be_listening }
  end

  describe port(44_444) do
    it { is_expected.to be_listening }
  end

  describe port(33_633) do
    it { is_expected.to be_listening }
  end

  describe service('Particular.ServiceControl.Development') do
    it { is_expected.to be_running }
  end

  describe service('Particular.ServiceControl.Development.Audit') do
    it { is_expected.to be_running }
  end

  describe service('Particular.ServiceControl.Development.Monitoring') do
    it { is_expected.to be_running }
  end

  context 'with an updated version of the package' do
    before(:all) do
      @latest_package_version = run_shell(interpolate_powershell(get_latest_version_of_choco_package('servicecontrol'))).stdout.strip
    end

    let(:pp) do
      <<-MANIFEST
      class { 'nservicebusservicecontrol':
        package_ensure              => '#{@latest_package_version}',
      }

      $primary_service_control_instance = 'Particular.ServiceControl.Development'

      nservicebusservicecontrol::instance { $primary_service_control_instance:
        ensure                                       => 'present',
        port                                         => 33333, # This is the default but added here for clarity
        transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
        instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
        connection_string                            => 'host=localhost;username=guest;password=guest',
        remote_instances                             => ['http://localhost:44444/api'],
      }

      nservicebusservicecontrol::audit_instance { "${primary_service_control_instance}.Audit":
        ensure                                       => 'present',
        port                                         => 44444, # This is the default but added here for clarity
        transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
        instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
        connection_string                            => 'host=localhost;username=guest;password=guest',
        service_control_queue_address                => $primary_service_control_instance,
      }

      nservicebusservicecontrol::monitoring_instance { "${primary_service_control_instance}.Monitoring":
        ensure                                       => 'present',
        port                                         => 33633, # This is the default but added here for clarity
        transport                                    => 'RabbitMQ - Conventional routing topology (quorum queues)',
        instance_create_and_upgrade_acknowledgements => 'RabbitMQBrokerVersion310',
        connection_string                            => 'host=localhost;username=guest;password=guest',
      }

      nservicebusservicecontrol::retry_redirect { 'Ordering.Endpoint':
        ensure              => present,
        destination_queue   => 'SomeOtherEndpoint',
        service_control_url => 'http://localhost:33333',
      }
      MANIFEST
    end

    it 'applies idempotently' do
      idempotent_apply(pp)
    end

    describe port(33_333) do
      it { is_expected.to be_listening }
    end

    describe port(44_444) do
      it { is_expected.to be_listening }
    end

    describe port(33_633) do
      it { is_expected.to be_listening }
    end

    describe service('Particular.ServiceControl.Development') do
      it { is_expected.to be_running }
    end

    describe service('Particular.ServiceControl.Development.Audit') do
      it { is_expected.to be_running }
    end

    describe service('Particular.ServiceControl.Development.Monitoring') do
      it { is_expected.to be_running }
    end
  end
end
