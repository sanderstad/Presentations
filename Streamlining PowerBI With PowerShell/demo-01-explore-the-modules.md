# Explore the modules

## First we need to check if the Power BI Management module is installed.

```powershell
if(Get-Module -ListAvailable -Name MicrosoftPowerBIMgmt) {
    Write-Host "Power BI Management module is installed."
} else {
    Install-Module -Name MicrosoftPowerBIMgmt -Scope CurrentUser -Force
}
```

## Which modules are installed?
```powershell
Get-Module -Name MicrosoftPowerBIMgmt -ListAvailable
```

The result should be something like this:
```console
    Directory: C:\Users\SanderStad\Documents\WindowsPowerShell\Modules


ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Manifest   1.2.1111   MicrosoftPowerBIMgmt
Binary     1.2.1111   MicrosoftPowerBIMgmt.Admin          {Add-PowerBIEncryptionKey, Get-PowerBIEncryptionKey, Get-PowerBIWorkspaceEncryptionStatus, Switch-PowerBIEncryptionKey...}
Binary     1.2.1111   MicrosoftPowerBIMgmt.Capacities     Get-PowerBICapacity
Binary     1.2.1111   MicrosoftPowerBIMgmt.Data           {Add-PowerBIDataset, Set-PowerBITable, New-PowerBIDataset, New-PowerBITable...}
Binary     1.2.1111   MicrosoftPowerBIMgmt.Profile        {Connect-PowerBIServiceAccount, Disconnect-PowerBIServiceAccount, Invoke-PowerBIRestMethod, Get-PowerBIAccessToken...}
Binary     1.2.1111   MicrosoftPowerBIMgmt.Reports        {Get-PowerBIReport, New-PowerBIReport, Export-PowerBIReport, Get-PowerBIDashboard...}
Binary     1.2.1111   MicrosoftPowerBIMgmt.Workspaces     {Get-PowerBIWorkspace, Get-PowerBIWorkspaceMigrationStatus, Add-PowerBIWorkspaceUser, Remove-PowerBIWorkspaceUser...}
```

## Now we need to import the Power BI Management module. 
```powershell
Import-Module MicrosoftPowerBIMgmt
```

## Let's explore the module and see what commands are available.
```powershell
Get-Command -Module MicrosoftPowerBIMgmt.Admin
```
The result should be something like this:
```console
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           Get-PowerBIActivityEvents                          1.2.1111   MicrosoftPowerBIMgmt.Admin
Alias           Rotate-PowerBIEncryptionKey                        1.2.1111   MicrosoftPowerBIMgmt.Admin
Cmdlet          Add-PowerBIEncryptionKey                           1.2.1111   MicrosoftPowerBIMgmt.Admin
Cmdlet          Get-PowerBIActivityEvent                           1.2.1111   MicrosoftPowerBIMgmt.Admin
Cmdlet          Get-PowerBIEncryptionKey                           1.2.1111   MicrosoftPowerBIMgmt.Admin
Cmdlet          Get-PowerBIWorkspaceEncryptionStatus               1.2.1111   MicrosoftPowerBIMgmt.Admin
Cmdlet          Set-PowerBICapacityEncryptionKey                   1.2.1111   MicrosoftPowerBIMgmt.Admin
Cmdlet          Switch-PowerBIEncryptionKey                        1.2.1111   MicrosoftPowerBIMgmt.Admin
```

## Let's explore the module and see what commands are available.
```powershell
Get-Command -Module MicrosoftPowerBIMgmt.Capacities
Get-Command -Module MicrosoftPowerBIMgmt.Data
Get-Command -Module MicrosoftPowerBIMgmt.Profile
Get-Command -Module MicrosoftPowerBIMgmt.Reports
Get-Command -Module MicrosoftPowerBIMgmt.Workspaces
```
