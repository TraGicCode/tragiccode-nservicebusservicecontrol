require 'spec_helper'

describe 'nservicebusservicecontrol::instance' do
  let(:title) do
    'Particular.ServiceControl.Development'
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
          is_expected.to contain_exec('create-service-control-instance-Particular.ServiceControl.Development')
            .with(
              provider: 'pwsh',
              logoutput: 'true',
            )
            .with_command(%r{Particular\.ServiceControl\.Development})
            .with_command(%r{C:\\Program Files \(x86\)\\Particular Software\\Particular\.ServiceControl\.Development})
            .with_command(%r{C:\\ProgramData\\Particular\\ServiceControl\\Particular\.ServiceControl\.Development\\DB})
        }
        # TODO: Look at how to do a not here
        # .with_command(/-ForwardErrorMessages/) }

        it {
          is_expected.to contain_file('C:\Program Files (x86)\Particular Software\Particular.ServiceControl.Development\ServiceControl.exe.config')
            .with(ensure: 'file')
            .that_requires('Exec[create-service-control-instance-Particular.ServiceControl.Development]')
        }
      end
    end
  end
end
