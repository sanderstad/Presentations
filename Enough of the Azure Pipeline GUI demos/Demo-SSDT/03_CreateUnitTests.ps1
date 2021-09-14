# URL for PowerShell module
# https://github.com/sanderstad/PStSQLtTestGenerator

. ".\variables.ps1"

########################################################################################
# DON'T CHANGE ANYTHING BELOW                                                          #
########################################################################################
if (-not (Get-Module -ListAvailable -Name 'dbatools')) {
    Write-Warning "Please install the dbatools PowerShell module. 'Install-Module dbatools'"
    return
}

if (-not (Get-Module -ListAvailable -Name 'PSFrameWork')) {
    Write-Warning "Please install the PSFrameWork PowerShell module. 'Install-Module PSFrameWork'"
    return
}

if ((Get-Module -ListAvailable).Name -notcontains 'PStSQLtTestGenerator') {
    Write-Warning "Please install PStSQLtTestGenerator using 'Install-Module PStSQLtTestGenerator'"
    return
}

$server = Connect-DbaInstance -SqlInstance $instance -SqlCredential $cred

if (-not $database) {
    Stop-PSFFunction -Message "Please enter a database" -Continue
}
else {
    if ($server.Databases.Name -notcontains $database) {
        Stop-PSFFunction -Message "Database [$($database)] does not exists on $($server.DomainInstanceName)" -Continue
    }
}

if (-not $destination) {
    Stop-PSFFunction -Message "Please enter an output path" -Continue
}
else {
    if (-not (Test-Path -Path $destination)) {
        Stop-PSFFunction -Message "Output path '$($destination)' does not exist" -Target $destination -Continue
    }
}

Invoke-PSTGTestGenerator -SqlInstance $instance -SqlCredential $cred -Database $database -OutputPath $destination