Break

<##### Overview ###############################################>
# Powershell modules for sql server #
Get-Module -ListAvailable | Select-Object Name -Unique | Sort-Object Name

# Import the SQL Server module
Clear-Host
Import-Module SqlServer
Get-Command -Module SqlServer
(Get-Command -Module SqlServer).Count

# Import the SQL Server module
Import-Module dbatools
Get-Command -Module dbatools -CommandType Cmdlet, Function
(Get-Command -Module dbatools -CommandType Cmdlet, Function).Count


















<##### Connectivity ###########################################>

$server = 'yourserver1'
$server2 = 'yourserver2'

# Using the SMO classes
$ServerManual = New-Object Microsoft.SqlServer.Management.Smo.Server $server
$ServerManual

# Example using the SMO classes with logins
$ServerManual = New-Object Microsoft.SqlServer.Management.Smo.Server $server
$cred = Get-Credential
$ServerManual.ConnectionContext.LoginSecure = $false
$ServerManual.ConnectionContext.set_Login($cred.username)
$ServerManual.ConnectionContext.set_SecurePassword($cred.password)
$ServerManual.ConnectionContext.Connect()

# Get the databases
$ServerManual.Databases.Name

# Using dbatools
$ServerDbatools = Connect-DbaInstance -SqlInstance $server
$ServerDbatools

# Get the databases from the object
$ServerDbatools.Databases.Name

# Test the connection
Test-DbaConnection -SqlInstance $server















<##### General      ###########################################>

# Power plan
Test-DbaPowerPlan -ComputerName $server2

# Build reference
Get-DbaBuildReference -SqlInstance $server

# Test the compatibility
Test-DbaDbCompatibility -SqlInstance $server | Format-Table

# Upgrade the databases to the latest compatibility mode
Invoke-DbaDbUpgrade -SqlInstance $server -Database DB1

# Test the compatibility level again
Test-DbaDbCompatibility -SqlInstance $server -Database DB1

# Test the collation
Test-DbaDbCollation -SqlInstance $server -Database DB2

# Test the tempdb configuration
Test-DbaTempdbConfig -SqlInstance $server

# Get the instance configurations
Get-DbaSpConfigure -SqlInstance $server | Out-GridView
Get-DbaSpConfigure -SqlInstance $server -ConfigName XPCmdShellEnabled
# Set it differently
Set-DbaSpConfigure -SqlInstance $server -ConfigName XPCmdShellEnabled -Value $false

# Get the databases
Get-DbaDatabase -SqlInstance $server | Out-GridView

# Test the owners of the databases
Test-DbaDbOwner -SqlInstance SQLDB1 | Out-GridView

# Get the tables for a database
Get-DbaDbTable -SqlInstance $server -Database DB1 | Out-GridView
Get-DbaDbTable -SqlInstance $server -Database WideWorldImporters | Out-GridView

# Find a stored procedure
Find-DbaStoredProcedure -SqlInstance $server -Database WideWorldImporters -Pattern "Change"
$database = Get-DbaDatabase -SqlInstance $server -Database WideWorldImporters
$database.StoredProcedures.Count

# Test your database for deprecated features
Test-DbaDeprecatedFeature -SqlInstance $server -ExcludeDatabase "SamplingApp-Tests"

























<##### Backups      ###########################################>

Get-DbaLastBackup -SqlInstance $server | Format-Table

# Testing backups
Backup-DbaDatabase -SqlInstance $server -Database DB1 -Type Full

Test-DbaLastBackup -SqlInstance $server -Database DB1

Backup-DbaDatabase -SqlInstance $server -Database DB1 -Type Full
Backup-DbaDatabase -SqlInstance $server -Database DB1 -Type Diff

Test-DbaLastBackup -SqlInstance $server -Database DB1
























<##### Events       ###########################################>

Get-DbaErrorLog -SqlInstance $server -After (Get-Date).AddDays(-1)
Get-DbaErrorLog -SqlInstance $server -After (Get-Date).AddHours(-1)























<##### Processes    ###########################################>

Get-DbaService -ComputerName $server2

Stop-DbaService -ComputerName $server2 -Type Agent

Get-DbaService -ComputerName $server2 -Type Agent

Start-DbaService -ComputerName $server2 -Type Agent



Get-DbaProcess -SqlInstance $server | Out-GridView

Get-DbaProcess -SqlInstance $server -Database DB1 | Out-GridView

Stop-DbaProcess -SqlInstance $server -Spid xx
























<##### Integrity    ###########################################>


Get-DbaLastGoodCheckDb -SqlInstance $server -Database DB1

Invoke-DbaQuery -SqlInstance $server -Database master -Query "DBCC CHECKDB(DB1)"

Get-DbaLastGoodCheckDb -SqlInstance $server -Database DB1























<##### Indexes      ###########################################>

Get-DbaHelpIndex -SqlInstance $server -Database WideWorldImporters | Out-GridView

Get-DbaHelpIndex -SqlInstance $server -Database WideWorldImporters | Where-Object {$_.KeyColumns -contains 'CustomerID' } | Format-Table























<##### Security     ###########################################>

Get-DbaLogin -SqlInstance $server | Out-GridView

# Only show non-system logins
Get-DbaLogin -SqlInstance $server -ExcludeFilter "##*" | Out-GridView

Get-DbaUserPermission -SqlInstance $server -Database DB1 | Out-GridView
























<##### Agent        ###########################################>

# Get all the jobs
Get-DbaAgentJob -SqlInstance $server | Out-GridView

# Get all the schedules
Get-DbaAgentSchedule -SqlInstance $server | Out-GridView

# Create a new job with a schedule
New-DbaAgentJob -SqlInstance $server -Job TestJob1
New-DbaAgentSchedule -SqlInstance $server -Schedule TestSchedule1Daily -FrequencyType Daily -FrequencyInterval EveryDay -StartTime 060000 -EndTime 235959 -StartDate 20170915 -EndDate 99991231
Set-DbaAgentJob -SqlInstance $server -Job TestJob1 -Schedule TestSchedule1Daily

# Create a new job step
New-DbaAgentJobStep -SqlInstance $server -Job TestJob1 -StepName Step1 -Subsystem TransactSql -Command "SELECT 'STEP 1' "

# Remove the job
Remove-DbaAgentJob -SqlInstance $server -Job TestJob1

# Agin get all the jobs
Get-DbaAgentJob -SqlInstance $server | Out-GridView


























<##### Extras       ###########################################>
# Find databases
Find-DbaDatabase -SqlInstance $server -Pattern "DB" | Out-GridView
Find-DbaDatabase -SqlInstance $server, $server2 -Pattern "DB" | Out-GridView

# Find database events for growth
Find-DbaDbGrowthEvent -SqlInstance $server | Out-GridView

# See what features are used
Get-DbaDbFeatureUsage -SqlInstance $server

# Execute queries
Invoke-DbaQuery -SqlInstance $server -Database DB1 -Query "SELECT * FROM Person" | Out-GridView

# Install Ola's maintenance solution
Install-DbaMaintenanceSolution -SqlInstance $server -Database master

# Install sp_whoisactive
Install-DbaWhoIsActive -SqlInstance $server -Database master

# Execute sp_whoisactive
<# $server = 'SQLDB1'
$query = '
USE DB1;
DECLARE @i TINYINT = 0;

WHILE @i < 1
BEGIN
	SELECT *
	FROM dbo.Person;
	WAITFOR DELAY ''00:01'';
END;
'
Invoke-DbaQuery -SqlInstance $server -Database DB1 -Query $query #>

Invoke-DbaWhoIsActive -SqlInstance $server

# Install Brent's responder kit
Install-DbaFirstResponderKit -SqlInstance $server

# Log shipping setup
Invoke-DbaDbLogShipping -SourceSqlInstance 'SQLDB1' -DestinationSqlInstance 'SQLDB1' -Database 'DB1' -BackupNetworkPath "\\sqldb1\LogShipping\backup" -CopyDestinationFolder "\\sqldb1\LogShipping\copy" -CompressBackup -GenerateFullBackup -SecondaryDatabasePrefix 'LS_'

# Log shipping recovery
Invoke-DbaDbLogShipRecovery -SqlInstance $server -Database 'LS_DB1'

