$username = "sa"
$password = "Password123!@#"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force
$SqlCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

$SqlInstance = "sql1,14331"
$Database = 'StackOverflow2013'


# Execute tests
$query = "EXEC tSQLt.RunAll"

Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database $Database -Query $query -Verbose