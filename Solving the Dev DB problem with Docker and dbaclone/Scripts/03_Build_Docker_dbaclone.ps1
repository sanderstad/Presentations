$rootPath = "C:\Users\sstad\source\repos\Other\Presentations\Solving the Dev DB problem with Docker and dbaclone"

###############################################################
# Import the modules
###############################################################
if (-not (Get-Module -ListAvailable -Name 'dbatools')) {
    Write-Warning "Please install the dbatools PowerShell module. 'Install-Module dbatools'"
    return
}

if (-not (Get-Module -ListAvailable -Name 'dbaclone')) {
    Write-Warning "Please install the dbaclone PowerShell module. 'Install-Module dbaclone'"
    return
}

Import-Module dbatools
Import-Module dbaclone

###############################################################
# Build the project
###############################################################

# Setting environment varibles
$msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"

$projectFile = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Tests\StackOverflow2013-Tests.sqlproj"

# Running build
.  $msbuildPath $projectFile

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
# Deploy database
###############################################################

$username = "sa"
$password = "Password123!@#"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force
$SqlCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd

$SqlInstance = "sql1,14331"
$Database = 'StackOverflow2013'

$dacpacPath = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Data\bin\Debug\StackOverflow2013-Data.dacpac"
$publishProfilePath = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Data\StackOverflow2013-Data.publish.xml"

$params = @{
    SqlInstance   = $SqlInstance
    SqlCredential = $SqlCredential
    Database      = $Database
    Path          = $dacpacPath
    PublishXml    = $publishProfilePath
}

Publish-DbaDacPackage @params

