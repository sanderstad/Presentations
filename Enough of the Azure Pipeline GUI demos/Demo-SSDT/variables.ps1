# SSDT project creation
$projectName = "UnitTesting"
$templateName = "SSDT-With-tSQLt"
$templateDescription = "SSDT project template including tSQLt"
$projectDestinationPath = "c:\temp\ssdtdemo\"

# Database and object creation
$instance = "localhost"
$database = "UnitTesting"
$tableCount = 10
$maxColumns = 20

$username = "sa"
$password = ConvertTo-SecureString -String "MyStr0ngP@ssword" -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $password #>

# Unit testing variables
$destination = Join-Path -Path $projectDestinationPath -ChildPath "$projectName\$($projectName)-Tests\TestBasic\"