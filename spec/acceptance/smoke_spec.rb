require 'spec_helper_acceptance'

# Test Cases
## Create Error Instance
## Create Audit Instance
## Create Monitoring Instance
#
# Get Last 2 latest package versions
# choco list servicecontrol --all-versions -r | ConvertFrom-Csv -Delimiter '|' -Header Package,Version | Sort-Object | Sort-Object { [System.Version]$_.Version } | Select-Object -Last 2
describe 'Installing ServiceControl and configuring Error, Audit, and Monitoring Instance' do
  let(:pp) do
    <<-MANIFEST
    class { 'nservicebusservicecontrol':
      package_ensure     => '4.21.5',
    }

    $primary_service_control_instance = 'Particular.ServiceControl.Development'

    nservicebusservicecontrol::instance { $primary_service_control_instance:
      ensure            => 'present',
      port              => 33333, # This is the default but added here for clarity
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

    nservicebusservicecontrol::monitoring_instance { "${primary_service_control_instance}.Monitoring":
      ensure            => 'present',
      port              => 33633, # This is the default but added here for clarity
      transport         => 'RabbitMQ - Conventional routing topology',
      connection_string => 'host=localhost;username=guest;password=guest',
    }
    MANIFEST
  end

  it 'applies idempotently' do
    idempotent_apply(pp)
  end

  #   describe file("/etc/feature.conf") do
  #     it { is_expected.to be_file }
  #     its(:content) { is_expected.to match %r{key = default value} }
  #   end

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

  # it 'returns success' do
  #   result = run_bolt_task('pe_databases::reset_pgrepack_schema')
  #   expect(result.stdout).to contain(%r{success})
  # end
end