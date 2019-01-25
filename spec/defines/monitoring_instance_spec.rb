require 'spec_helper'

describe 'nservicebusservicecontrol::monitoring_instance' do
  let(:title) do
    'Particular.Monitoring.Development'
  end
  let(:params) do
    {
      ensure: 'present',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with ensure => present' do
        let(:params) do
          {
            ensure: 'present',
          }
        end

        # TODO: not sure how to do command attribute part
        it {
          is_expected.to contain_exec('create-service-control-monitoring-instance-Particular.Monitoring.Development')
            .with(
              provider: 'powershell',
              logoutput: 'true',
            )
            .with_command(%r{Particular\.Monitoring\.Development})
            .with_command(%r{C:\\Program Files \(x86\)\\Particular Software\\Particular\.Monitoring\.Development})
        }

        it {
          is_expected.to contain_file('C:\Program Files (x86)\Particular Software\Particular.Monitoring.Development\ServiceControl.Monitoring.exe.config')
            .with(ensure: 'file')
            .that_requires('Exec[create-service-control-monitoring-instance-Particular.Monitoring.Development]')
        }
      end
    end
  end
end
