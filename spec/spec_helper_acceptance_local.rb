

# This method allows a block to be passed in and if an exception is raised
# that matches the 'error_matcher' matcher, the block will wait a set number
# of seconds before retrying.
# Params:
# - max_retry_count - Max number of retries
# - retry_wait_interval_secs - Number of seconds to wait before retry
# - error_matcher - Matcher which the exception raised must match to allow retry
# Example Usage:
# retry_on_error_matching(3, 5, /OpenGPG Error/) do
#   apply_manifest(pp, :catch_failures => true)
# end

def retry_on_error_matching(max_retry_count = MAX_RETRY_COUNT, retry_wait_interval_secs = RETRY_WAIT, error_matcher = ERROR_MATCHER)
  try = 0
  begin
    puts "retry_on_error_matching: try #{try}" unless try.zero?
    try += 1
    yield
  rescue StandardError => e
    raise('Attempted this %{value0} times. Raising %{value1}' % { value0: max_retry_count, value1: e }) unless try < max_retry_count && (error_matcher.nil? || e.message =~ error_matcher)
    sleep retry_wait_interval_secs
    retry
  end
end

# Get Last 2 latest package versions
# choco list servicecontrol --all-versions -r | ConvertFrom-Csv -Delimiter '|' -Header Package,Version | Sort-Object { [System.Version]$_.Version } | Select-Object -Last 2
def get_latest_version_of_choco_package(_package_name)
  <<-powershell
        $pageNumber = 1;
        $latestVersion = $null
        $previousLastVersion = $null
        $serviceControlTags = @()

        Do
        {
            $tags = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/TraGicCode/chocolatey-packages/tags?page=$pageNumber&per_page=100"
            $serviceControlTags += $tags | Where-Object -FilterScript { $PSItem.name -like "*servicecontrol*" } | Select-Object -ExpandProperty name | ForEach-Object { $PSItem -replace "servicecontrol-", ""}
            $pageNumber++;
        }
        While($tags.Count -ne 0)

        $sortedServiceControlTags = $serviceControlTags | Sort-Object { [version] $_ } -Descending
        $latestVersion = $sortedServiceControlTags | Select-Object -First 1
        Write-Output $latestVersion
    powershell
end

def get_version_before_latest_of_choco_package(_package_name)
  <<-powershell
        $pageNumber = 1;
        $latestVersion = $null
        $previousLastVersion = $null
        $serviceControlTags = @()

        Do
        {
            $tags = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/TraGicCode/chocolatey-packages/tags?page=$pageNumber&per_page=100"
            $serviceControlTags += $tags | Where-Object -FilterScript { $PSItem.name -like "*servicecontrol*" } | Select-Object -ExpandProperty name | ForEach-Object { $PSItem -replace "servicecontrol-", ""}
            $pageNumber++;
        }
        While($tags.Count -ne 0)

        $sortedServiceControlTags = $serviceControlTags | Sort-Object { [version] $_ } -Descending
        $previousLastVersion = $sortedServiceControlTags | Select-Object -First 1 -Skip 1
        Write-Output $previousLastVersion
    powershell
end

def encode_command(command)
  Base64.strict_encode64(command.encode('UTF-16LE'))
end

def interpolate_powershell(command)
  "powershell.exe -EncodedCommand #{encode_command(command)}"
end
