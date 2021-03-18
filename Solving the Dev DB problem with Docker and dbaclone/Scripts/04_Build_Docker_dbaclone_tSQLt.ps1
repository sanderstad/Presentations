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

$projectFile = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Tests\StackOverflow2013-Tests.sqlproj"

# Running build
.  $msbuildPath $projectFile

###############################################################
# Create the clone
###############################################################
$Destination = "C:\sqldata\docker\clone\"
$dbName = 'StackOverflow2013'
$CloneName = "StackOverflow2013-Tests"

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

$dacpacPath = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Tests\bin\Debug\StackOverflow2013-Tests.dacpac"
$publishProfilePath = Join-Path -Path $rootPath -ChildPath "SSDT\StackOverflow2013\StackOverflow2013-Tests\StackOverflow2013-Tests.publish.xml"

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

$TestResultPath = Join-Path -Path $rootPath -ChildPath "TestResults"

if (-not (Test-Path -Path $TestResultPath)) {
    $null = New-Item -Path $TestResultPath -ItemType Directory
}

# Execute tests
$query = "EXEC tSQLt.RunAll"

Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database $Database -Query $query -Verbose

# Collect the tests
$query = "EXEC tSQLt.XmlResultFormatter"
try {
    $result = Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database $Database -Query $query | Select-Object ItemArray -ExpandProperty ItemArray
}
catch {
    Stop-PSFFunction -Message "Something went wrong collecting the tSQLt test results" -Target $Database -ErrorRecord $_
    return
}

# Write the test results
try {
    $result | Set-Content -NoNewLine -Path (Join-Path -Path $TestResultPath -ChildPath "TEST-$($Database)_tSQLt.xml")
}
catch {
    Stop-PSFFunction -Message "Something went wrong writing the tSQLt test results" -Target $TestResultPath -ErrorRecord $_
    return
}
