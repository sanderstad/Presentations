$username = "sa"
$password = "Password123!@#"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

$query = "
CREATE DATABASE [AW2017]
ON
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/AW2017C1/Data/AdventureWorks2017.mdf'
    ),
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/AW2017C1/Log/AdventureWorks2017_log.ldf'
    )
FOR ATTACH;
"

$sqlinstance = "sql1,14331"

Invoke-DbaQuery -SqlInstance $sqlinstance -SqlCredential $cred -Database "master" -Query $query