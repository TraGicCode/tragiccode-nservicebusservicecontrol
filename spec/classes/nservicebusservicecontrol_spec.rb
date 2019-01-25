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
            is_expected.to contain_package('servicecontrol')
              .with(ensure: 'present')
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
            is_expected.to contain_package('servicecontrol')
              .with(ensure: 'absent')
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
