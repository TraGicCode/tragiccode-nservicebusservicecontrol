require 'spec_helper'

describe 'nservicebusservicecontrol' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      context 'with default values for all parameters' do
        it { is_expected.to contain_class('nservicebusservicecontrol') }
        it { is_expected.to contain_class('nservicebusservicecontrol::install') }
        it {
          is_expected.to contain_class('nservicebusservicecontrol::config')
            .that_requires('Class[nservicebusservicecontrol::install]')
        }
      end

      describe 'nservicebusservicecontrol::install' do
        context 'with default values for all parameters' do
          it { is_expected.to contain_class('nservicebusservicecontrol') }
          it { is_expected.to contain_class('nservicebusservicecontrol::install') }

          it {
            is_expected.to contain_remote_file('C:\Particular.ServiceControl-3.6.1.exe')
              .with(ensure: 'present',
                    source: 'https://github.com/Particular/ServiceControl/releases/download/3.6.1/Particular.ServiceControl-3.6.1.exe')
          }

          it {
            is_expected.to contain_package('ServiceControl')
              .with(ensure: 'present',
                    source: 'C:\Particular.ServiceControl-3.6.1.exe',
                    install_options: [
                      '/Quiet',
                    ])
              .that_requires('Remote_file[C:\Particular.ServiceControl-3.6.1.exe]')
          }
        end
        context 'with package_ensure => absent' do
          let(:params) do
            {
              package_ensure: 'absent',
            }
          end

          it { is_expected.to contain_class('nservicebusservicecontrol') }
          it { is_expected.to contain_class('nservicebusservicecontrol::install') }

          it {
            is_expected.to contain_remote_file('C:\Particular.ServiceControl-3.6.1.exe')
              .with(ensure: 'absent',
                    source: 'https://github.com/Particular/ServiceControl/releases/download/3.6.1/Particular.ServiceControl-3.6.1.exe')
          }

          it {
            is_expected.to contain_package('ServiceControl')
              .with(ensure: 'absent',
                    source: 'C:\Particular.ServiceControl-3.6.1.exe',
                    install_options: [
                      '/Quiet',
                    ],
                    uninstall_options: [
                      '/Quiet',
                    ])
              .that_requires('Remote_file[C:\Particular.ServiceControl-3.6.1.exe]')
          }
        end
      end

      describe 'nservicebusservicecontrol::config' do
        context 'with default values for all parameters' do
          it { is_expected.to contain_class('nservicebusservicecontrol') }
          it { is_expected.to contain_class('nservicebusservicecontrol::config') }

          it {
            is_expected.to contain_registry_value('HKLM\SOFTWARE\ParticularSoftware\License')
              .with(ensure: 'absent')
          }
        end

        context 'with license_xml => <license>...</license>' do
          let(:params) do
            {
              license_xml: '<license>...</license>',
            }
          end

          it {
            is_expected.to contain_registry_value('HKLM\SOFTWARE\ParticularSoftware\License')
              .with(ensure: 'present',
                    type: 'string',
                    data: '<license>...</license>')
          }
        end
      end
    end
  end
end
