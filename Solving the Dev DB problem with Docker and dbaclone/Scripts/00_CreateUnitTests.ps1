[CmdLetbinding()]

# URL for SSDT project template
# "https://github.com/sanderstad/SSDT-With-tSQLt-Template"

# EXAMPLE
# .\00_CreateUnitTests.ps1 -SqlInstance localhost -Database DB1 -OutputPath C:\projects\DB1\DB1-Tests\TestBasic\
# Get all the objects from database "DB1" and create the basic unit tests to the
# basic test folder of the test project within solution created with the SSDT-With-tSQLt-Template

param(
    [string]$SqlInstance,
    [pscredential]$SqlCredential,
    [string]$Database,
    [string]$OutputPath
)

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

if (-not (Get-Module -ListAvailable -Name 'PStSQLtTestGenerator')) {
    Write-Warning "Please install PStSQLtTestGenerator using 'Install-Module PStSQLtTestGenerator'"
    return
}

if (-not $SqlInstance) {
    Stop-PSFFunction -Message "Please enter a sql server instance" -Continue
}

$server = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential

if (-not $Database) {
    Stop-PSFFunction -Message "Please enter a database" -Continue
}
else {
    if ($server.Databases.Name -notcontains $Database) {
        Stop-PSFFunction -Message "Database [$($database)] does not exists on $($server.DomainInstanceName)" -Continue
    }
}

if (-not $OutputPath) {
    Stop-PSFFunction -Message "Please enter an output path" -Continue
}
else {
    if (-not (Test-Path -Path $OutputPath)) {
        Stop-PSFFunction -Message "Output path '$($OutputPath)' does not exist" -Target $OutputPath -Continue
    }
}

Invoke-PSTGTestGenerator -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database $Database -OutputPath $OutputPath