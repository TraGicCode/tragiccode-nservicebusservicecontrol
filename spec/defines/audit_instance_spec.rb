require 'spec_helper'

describe 'nservicebusservicecontrol::audit_instance' do
  let(:title) do
    'Particular.ServiceControl.Development.Audit'
  end
  let(:params) do
    {
      ensure: 'present',
      service_control_queue_address: 'Particular.ServiceControl.Development',
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
            service_control_queue_address: 'Particular.ServiceControl.Development',
          }
        end

        # TODO: not sure how to do command attribute part
        it {
          is_expected.to contain_exec('create-service-control-instance-Particular.ServiceControl.Development.Audit')
            .with(
              provider: 'pwsh',
              logoutput: 'true',
            )
            .with_command(%r{Particular\.ServiceControl\.Development\.Audit})
            .with_command(%r{C:\\Program Files \(x86\)\\Particular Software\\Particular\.ServiceControl\.Development\.Audit})
            .with_command(%r{C:\\ProgramData\\Particular\\ServiceControl\\Particular\.ServiceControl\.Development\.Audit\\DB})
        }
        # TODO: Look at how to do a not here
        # .with_command(/-ForwardErrorMessages/) }

        it {
          is_expected.to contain_file('C:\Program Files (x86)\Particular Software\Particular.ServiceControl.Development.Audit\ServiceControl.Audit.exe.config')
            .with(ensure: 'file')
            .that_requires('Exec[create-service-control-instance-Particular.ServiceControl.Development.Audit]')
        }
      end
    end
  end
end
