###############################################################
# Import the modules
###############################################################
Import-Module dbatools
Import-Module dbaclone

###############################################################
# Create the clone
###############################################################
$Destination = "C:\projects\dbaclone\clone\"
$Database = 'StackOverflow2013'
$CloneName = "StackOverflow2013"

$params = @{
    Destination = $Destination
    Database    = $Database
    CloneName   = $CloneName
    LatestImage = $true
}

New-DcnClone @params

###############################################################
# Run the docker container
###############################################################
$DockerFilePath = "/home/sander/docker/sqlserver/restart-sql1-dbaclone.sh"
$SshPrivateFilePath = "C:\Users\sstad\Downloads\ssh\docker.ppk"
$User = "sander@docker"

plink -batch -i "$SshPrivateFilePath" "$User" "$DockerFilePath"

###############################################################
# Attach database
###############################################################
$username = "sa"
$password = "Password123!@#"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force
$SqlCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

$SqlInstance = "sql1,14331"
$Database = 'StackOverflow2013'

$query = "
USE [master];
GO
CREATE DATABASE [$Database]
ON
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/$Database/Data/StackOverflow2013_1.mdf'
    ),
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/$Database/Log/StackOverflow2013_log.ldf'
    ),
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/$Database/Data/StackOverflow2013_2.ndf'
    ),
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/$Database/Data/StackOverflow2013_3.ndf'
    ),
    (
        FILENAME = N'/var/opt/mssql/data/dbaclone/$Database/Data/StackOverflow2013_4.ndf'
    )
FOR ATTACH;"

Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database "master" -Query $query

###############################################################
# Build the project
###############################################################

# Setting environment varibles
$msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"

$projectFile = "C:\Users\sstad\source\repos\Databases\StackOverflow2013\StackOverflow2013-Tests\StackOverflow2013-Tests.sqlproj"

# Running build
.  $msbuildPath $projectFile

###############################################################
# Deploy database
###############################################################

$dacpacPath = "C:\Users\sstad\source\repos\Databases\StackOverflow2013\StackOverflow2013-Tests\bin\Debug\StackOverflow2013-Tests.dacpac"
$publishProfilePath = "C:\Users\sstad\source\repos\Databases\StackOverflow2013\StackOverflow2013-Tests\StackOverflow2013-Tests.publish.xml"

$params = @{
    SqlInstance   = $SqlInstance
    SqlCredential = $SqlCredential
    Database      = $Database
    Path          = $dacpacPath
    PublishXml    = $publishProfilePath
}

Publish-DbaDacPackage @params

###############################################################
# Run tests
###############################################################

$resultPath = "C:\projects\$($Database)\TestResults"

if (-not (Test-Path -Path $resultPath)) {
    $null = New-Item -Path $resultPath -ItemType Directory
}

. ..\SSDT\StackOverflow2013\Build\azure-validate.ps1 -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database $Database -TestResultPath $resultPath

###############################################################
# Create database unit tests
###############################################################

Import-Module PStSQLtTestGenerator

