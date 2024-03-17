# Fix the environment

# Get activity events

Let's use the `Get-PowerBIActivityEvent` cmdlet to get the activity events for the last 30 days.

```powershell
Get-PowerBIActivityEvent -StartDateTime ((Get-Date).AddDays(-30) -f "yyyy-MM-dd HH:mm:ss") -EndDateTime ((Get-Date) -f "yyyy-MM-dd HH:mm:ss")
```

This is going to end up with an error similar to this:

```console
Get-PowerBIActivityEvent : Operation returned an invalid status code 'BadRequest'
At line:1 char:1
+ Get-PowerBIActivityEvent -StartDateTime ((Get-Date).AddMinutes(-30) - ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : WriteError: (Microsoft.Power...BIActivityEvent:GetPowerBIActivityEvent) [Get-PowerBIAc
   tivityEvent], HttpOperationException
    + FullyQualifiedErrorId : Operation returned an invalid status code 'BadRequest',Microsoft.PowerBI.Commands.Admi
   n.GetPowerBIActivityEvent
```

This is because the API does not allow you to get the activities for multiple days. You can only get the activities for a single day.

We're going to help you out with this in the next section.

We're  going to use the command in the PSPowerBITools.

```powershell
Get-PSBIActivityEvent -StartDate ((Get-Date).AddDays(-30) -f "yyyy-MM-dd HH:mm:ss") -EndDate ((Get-Date) -f "yyyy-MM-dd HH:mm:ss") | Format-Table
```

This will give you a list of all the activities for the last 30 days.

```console

Id                                   RecordType CreationTime         Operation                    OrganizationId
--                                   ---------- ------------         ---------                    --------------
689873ca-1be3-4285-8fb5-fccca0bab2c0         20 2024-02-15T13:49:47Z ViewReport                   82f5898c-77e7-4a...
580a29cc-642a-485c-9f67-2db015259aff         20 2024-02-15T13:52:55Z ViewReport                   82f5898c-77e7-4a...
ca9359ae-ce4c-4b4c-b51d-d8c68805f9b6         20 2024-02-15T13:53:11Z ViewReport                   82f5898c-77e7-4a...
c7d9c4b4-7cba-4368-b905-81cb57678a57         20 2024-02-15T13:53:13Z GetSnapshots                 82f5898c-77e7-4a...
82be77c3-edf6-4661-ab98-ca3651fad170         20 2024-02-15T13:54:05Z GetSnapshots                 82f5898c-77e7-4a...
94ca7dae-42f8-452a-bb34-6d1e78b5f97c         20 2024-02-15T13:54:06Z GetCloudSupportedDatasources 82f5898c-77e7-4a...
ee145bf2-b8ce-484f-8142-97372ff742c9         20 2024-02-15T13:53:48Z GetGroupsAsAdmin             82f5898c-77e7-4a...
...........................................
...........................................
```

# Set the values in the workspace

We can use the `Set-PSBIWorkspace` cmdlet to set the values in the workspace.

```powershell
Set-PSBIWorkspace -WorkspaceId 82f5898c-77e7-4a... -Name "New Workspace Name" -CapacityId 82f5898c-77e7-4a...
```
