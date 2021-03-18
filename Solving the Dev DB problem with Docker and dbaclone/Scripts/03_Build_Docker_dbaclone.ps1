# Import the global variables
. ".\variables.ps1"

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

$projectFile = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Data\StackOverflow2013-Data.sqlproj"

# Running build
.  $msbuildPath $projectFile

###############################################################
# Create the clone
###############################################################
$Destination = "C:\sqldata\docker\clone\"
$dbName = 'StackOverflow2013'
$CloneName = "StackOverflow2013-Data"

$params = @{
    Destination = $Destination
    Database    = $dbName
    CloneName   = $CloneName
    LatestImage = $true
}

New-DcnClone @params

###############################################################
# Deploy database
###############################################################

$Database = $CloneName

$dacpacPath = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Data\bin\Debug\StackOverflow2013-Data.dacpac"
$publishProfilePath = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Data\StackOverflow2013-Data.publish.xml"

$params = @{
    SqlInstance   = $sqlInstance
    SqlCredential = $sqlCredential
    Database      = $Database
    Path          = $dacpacPath
    PublishXml    = $publishProfilePath
}

Publish-DbaDacPackage @params

