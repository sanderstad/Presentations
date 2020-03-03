param(
    [DbaInstanceParameter]$SqlInstance,
    [PSCredential]$SqlCredential,
    [string]$DatabaseName,
    [string]$DataFilePath,
    [string]$LogFilePath
)

$query = "
CREATE DATABASE [$DatabaseName]
ON
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/AW2017C1/Data/AdventureWorks2017.mdf'
    ),
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/AW2017C1/Log/AdventureWorks2017_log.ldf'
    )
FOR ATTACH;
"

Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database "master" -Query $query