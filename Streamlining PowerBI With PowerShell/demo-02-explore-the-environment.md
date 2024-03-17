# Explore the environment

# Import the MicrosoftPowerBiMgt module
Import-Module MicrosoftPowerBiMgt

# Connect to the Power BI service
Connect-PowerBIServiceAccount

The result should be something like this:
```console
Environment : Public
TenantId    : REDACTED
UserName    : REDACTED
```

# Retrieve a list of workspaces
Get-PowerBIWorkspace

The result should be something like this:
```console
Id                    : 224f3434-2f9b-4286-851e-78be60256620
Name                  : sfasfasdfasfasd??
Type                  : Workspace
IsReadOnly            : False
IsOrphaned            : False
IsOnDedicatedCapacity : False
CapacityId            :
```

# Lets look at the other information we can get from the workspace

```powershell
Get-PowerBIWorkspace | Get-Member
```

This will give you a list of all the properties and methods that are available for the workspace.

```console
   TypeName: Microsoft.PowerBI.Common.Api.Workspaces.Workspace

Name                  MemberType Definition
----                  ---------- ----------
Equals                Method     bool Equals(System.Object obj)
GetHashCode           Method     int GetHashCode()
GetType               Method     type GetType()
ToString              Method     string ToString()
CapacityId            Property   string CapacityId {get;set;}
Dashboards            Property   System.Collections.Generic.IEnumerable[Microsoft.PowerBI.Common.Api.Reports.Dashb...
Dataflows             Property   System.Collections.Generic.IEnumerable[Microsoft.PowerBI.Common.Api.Dataflows.Dat...
Datasets              Property   System.Collections.Generic.IEnumerable[Microsoft.PowerBI.Common.Api.Datasets.Data...
Description           Property   string Description {get;set;}
Id                    Property   guid Id {get;set;}
IsOnDedicatedCapacity Property   System.Nullable[bool] IsOnDedicatedCapacity {get;set;}
IsOrphaned            Property   bool IsOrphaned {get;}
IsReadOnly            Property   System.Nullable[bool] IsReadOnly {get;set;}
Name                  Property   string Name {get;set;}
Reports               Property   System.Collections.Generic.IEnumerable[Microsoft.PowerBI.Common.Api.Reports.Repor...
State                 Property   string State {get;set;}
Type                  Property   string Type {get;set;}
Users                 Property   System.Collections.Generic.IEnumerable[Microsoft.PowerBI.Common.Api.Workspaces.Wo...
Workbooks             Property   System.Collections.Generic.IEnumerable[Microsoft.PowerBI.Common.Api.Workbooks.Wor...
```


# Now retrieve a list of all the workspaces within the organization

```powershell
Get-PowerBIWorkspace -Scope Organization | Format-Table -Property Name, Id, Type, IsOrphaned
```

The result should be something like this:
```console
Name                                                          Type           IsOrphaned
----                                                          ----           ----------
PersonalWorkspace lindatorrang@sandersqlstad.onmicrosoft.com  PersonalGroup       False
Sales                                                         Workspace           False
My workspace                                                  PersonalGroup       False
sfasfasdfasfasd??                                             Workspace           False
HR                                                            Workspace           False
Very special reports                                          Workspace           False
COVID-19 US Tracking Report                                   Workspace           False
PersonalWorkspace JoeyTribbiani@sandersqlstad.onmicrosoft.com PersonalGroup       False
PersonalWorkspace MonicaGeller@sandersqlstad.onmicrosoft.com  PersonalGroup       False
PersonalWorkspace RachelGreen@sandersqlstad.onmicrosoft.com   PersonalGroup       False
Microsoft Fabric Capacity Metrics                             Workspace           False
PersonalWorkspace PhoebeBuffay@sandersqlstad.onmicrosoft.com  PersonalGroup       False
PersonalWorkspace RossGeller@sandersqlstad.onmicrosoft.com    PersonalGroup       False
Admin monitoring                                              AdminWorkspace      False
Ross Own workspace                                            Workspace            True
Oprhaned workspace                                            Workspace           False
```


# Lets look at the user information we can get from the workspace

```powershell
Get-PowerBIWorkspace -Scope Organization| Select-Object Name, Users
```

We would like to introduce to you our own PowerShell module from Data Masterminds. This module is called PSPowerBiTools and is available on the PowerShell Gallery. This module is a wrapper for the Power BI REST API and the MicrosoftPowerBiMgt module, and is designed to make it easier to work with the Power BI service in PowerShell. The module is open source and available on GitHub.

```powershell
Install-Module -Name PSPowerBiTools
```

# Connect to the Power BI service
```powershell
Connect-PSBI
```

# Retrieve a list of workspaces
```powershell
Get-PSBIWorkspace
```

# Lets look at the user information we can get from the workspace

```powershell
Get-PSBIWorkspace -Detailed | Select-Object Name, Users
```

We can also do that another way with another commandlet

```powershell
Get-PSBIWorkspaceUser
```

It doesn't return the detailed information because most of the time we don't need that. But if we do, we can use the -Detailed switch.

```powershell
Get-PSBIWorkspaceUser -Detailed
```

# What are the reports that are connected to the workspace?

```powershell
Get-PSBIWorkspace -Detailed | Select-Object Name, Reports
```

# What are the data sets that are connected to the workspace?

```powershell
Get-PSBIWorkspace | Select Name, Datasets
```

