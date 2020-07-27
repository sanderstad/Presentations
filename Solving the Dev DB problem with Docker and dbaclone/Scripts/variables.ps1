# SSDT project creation
$rootPath = "C:\Users\sstad\source\repos\Other\Presentations\Solving the Dev DB problem with Docker and dbaclone"

$projectName = "StackOverflow2013"
$templateName = "SSDT-With-tSQLt"
$templateDescription = "SSDT project template including tSQLt"
$projectDestinationPath = "c:\temp\SolvingDevDBProblem\"

# Database and object creation
$instance = "localhost"
$database = "StackOverflow2013"

<# $username = "username"
$password = ConvertTo-SecureString -String "password" -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $password #>

# Unit testing variables
$destination = Join-Path -Path $projectDestinationPath -ChildPath "$projectName\$($projectName)-Tests\TestBasic\"