

# Get Last 2 latest package versions
# choco list servicecontrol --all-versions -r | ConvertFrom-Csv -Delimiter '|' -Header Package,Version | Sort-Object | Sort-Object { [System.Version]$_.Version } | Select-Object -Last 2
def get_latest_version_of_choco_package(package_name)
  <<-powershell
        choco list #{package_name} --all-versions -r | ConvertFrom-Csv -Delimiter '|' -Header Package,Version | Sort-Object | Sort-Object { [System.Version]$_.Version } | Select-Object -ExpandProperty Version -Last 1
    powershell
end

def get_version_before_latest_of_choco_package(package_name)
  <<-powershell
        choco list #{package_name} --all-versions -r | ConvertFrom-Csv -Delimiter '|' -Header Package,Version | Sort-Object | Sort-Object { [System.Version]$_.Version } | Select-Object -ExpandProperty Version -Last 1 -Skip 1
    powershell
end

def encode_command(command)
  Base64.strict_encode64(command.encode('UTF-16LE'))
end

def interpolate_powershell(command)
  "powershell.exe -EncodedCommand #{encode_command(command)}"
end
