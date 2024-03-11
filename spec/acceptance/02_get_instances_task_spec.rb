# require 'spec_helper_acceptance'

# # Test Cases
# ## Create Error Instance
# ## Create Audit Instance
# ## Create Monitoring Instance
# #
# describe 'nservicebusservicecontrol::get_instances' do
#   before(:all) do
#     @older_package_version = run_shell(interpolate_powershell(get_version_before_latest_of_choco_package('servicecontrol'))).stdout.strip
#   end

#   it 'returns 3 instances' do
#     result = run_bolt_task('nservicebusservicecontrol::get_instances')
#     expect(result.exit_code).to eq(0)
#     expect(result.stdout).to contain(%r{Particular.ServiceControl.Development})
#     expect(result.stdout).to contain(%r{Particular.ServiceControl.Development.Audit})
#     expect(result.stdout).to contain(%r{Particular.ServiceControl.Development.Monitoring})
#   end
# end
