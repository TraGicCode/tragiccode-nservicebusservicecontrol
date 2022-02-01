Import-Module "${env:ProgramFiles(x86)}\Particular Software\ServiceControl Management\ServiceControlMgmt"  4>$null

$result = @()

$errorInstances = Get-ServiceControlInstances
foreach($instance in $errorInstances)
{
    $result += [PSCustomObject] @{
        Name        = $instance.Name
        InstallPath = $instance.InstallPath
        DBPath      = $instance.DBPath
        ExecutablePath = Join-Path -Path $instance.InstallPath -ChildPath "ServiceControl.exe"
        Type = 'error'
    }
}

$auditInstances = Get-ServiceControlAuditInstances
foreach($instance in $auditInstances)
{
    $result += [PSCustomObject] @{
        Name        = $instance.Name
        InstallPath = $instance.InstallPath
        DBPath      = $instance.DBPath
        ExecutablePath = Join-Path -Path $instance.InstallPath -ChildPath "ServiceControl.Audit.exe"
        Type = 'audit'
    }
}

$monitoringInstances = Get-MonitoringInstances
foreach($instance in $monitoringInstances)
{
    $result += [PSCustomObject] @{
        Name        = $instance.Name
        InstallPath = $instance.InstallPath
        ExecutablePath = Join-Path -Path $instance.InstallPath -ChildPath "ServiceControl.Monitoring.exe"
        Type = 'monitor'
    }
}

ConvertTo-Json -InputObject @{"_items" = $result} -Compress 