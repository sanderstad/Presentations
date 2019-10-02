
$instance = "sql1"
$database = "UnitTesting"

$cred = Get-Credential

$tableCount = 10
$maxColumns = 20

$server = Connect-DbaInstance -SqlInstance $instance -SqlCredential $cred


if ($server.Databases.Name -contains $database) {
    try {
        Write-PSFMessage -Level Host -Message "Removing database"
        $null = Remove-DbaDatabase -SqlInstance $instance -SqlCredential $cred -Database $database -Confirm:$false
    }
    catch {
        Stop-PSFFunction -Message "Could not remove database" -Target $database -ErrorRecord $_ -Continue
        return
    }
}

try {
    Write-PSFMessage -Level Host -Message "Creating database"
    $query = "CREATE DATABASE [$($database)]"

    Invoke-DbaQuery -SqlInstance $instance -SqlCredential $cred -Query $query
}
catch {
    Stop-PSFFunction -Message "Could not create database" -Target $database -ErrorRecord $_ -Continue
    return
}


$procedureNames = @('Create', 'Delete', 'GetAll', 'GetByID', 'Update')
$procedureCount = 0

# Create the tables
Write-PSFMessage -Level Host -Message "Creating tables"
for ($i = 1; $i -le $tableCount; $i++) {
    $tableName = "Table$($i)"

    Write-PSFMessage -Level Host -Message "- Creating table '$tableName'"

    $columnCount = Get-Random -Maximum $maxColumns

    $query = "DROP TABLE IF EXISTS dbo.$($tableName); CREATE TABLE dbo.$($tableName) ("

    $columns = @()
    for ($j = 1; $j -le $columnCount; $j++) {
        $columns += "Column$($j) VARCHAR(100) NULL"
    }

    $query += $columns -join ','

    $query += "); "

    Invoke-DbaQuery -SqlInstance $instance -SqlCredential $cred -Database $database -Query $query


    # Create the procedures for the table
    Write-PSFMessage -Level Host -Message "- Creating procedures for table '$tableName'"
    foreach ($name in $procedureNames) {
        $procedureName = "$($tableName)_$($name)"

        $query = "DROP TABLE IF EXISTS dbo.$($procedureName);"

        Invoke-DbaQuery -SqlInstance $instance -SqlCredential $cred -Database $database -Query $query

        $query = "CREATE PROCEDURE dbo.$($procedureName)`n"

        $paramCount = Get-Random -Maximum $maxColumns

        $parameters = @()
        for ($k = 1; $k -le $paramCount; $k++) {
            $parameters += "@param$($k) VARCHAR(100)"
        }

        $query += $parameters -join ','

        $query += "
AS
BEGIN
    SELECT '$procedureName'
END
GO "

        Invoke-DbaQuery -SqlInstance $instance -SqlCredential $cred -Database $database -Query $query
        $procedureCount++
    }
}

Write-PSFMessage -Level Host -Message "Created:"
Write-PSFMessage -Level Host -Message "Tables:      $tableCount"
Write-PSFMessage -Level Host -Message "Procedures:  $procedureCount"
