# Show the module using a single file 'DemoModule1.psm1'

Clear-Host

. "$($PSScriptRoot)\..\variables.ps1"

# test if the directory for the module is created
if (-not(Test-Path -Path $Script:ModulePath)) {
    Write-Host "The module directory does not exist. Creating it..."
    $null = New-Item -Path $Script:ModulePath -ItemType Directory -Force
}

if (Test-Path -Path "$($Script:ModulePath)\GeneratedManifestModule") {
    Remove-Item -Path "$($Script:ModulePath)\GeneratedManifestModule" -Recurse -Force
}

# Create the module
Write-Host "Creating the module..."
Import-Module PSModuleDevelopment

$moduleParams = @{
    TemplateName = "PSFModule"
    Name         = "GeneratedManifestModule"
    OutPath      = $Script:ModulePath
}

Invoke-PSMDTemplate @moduleParams

break

Set-Location C:\temp\demomodules\GeneratedManifestModule
ipmo .\GeneratedManifestModule.psd1 -Force
Get-Module
Get-Command -Module GeneratedManifestModule

# Execute the script below to again create the files but now from a module
$fileCount = 10
$destination1 = "C:\temp\demo1"
$destination2 = "C:\temp\demo2"

Write-Host "Executing the function with -WhatIf" -ForegroundColor Magenta
Invoke-DemoCreateFiles -FileCount $fileCount -Destination $destination1, $destination2 -DeleteFiles -Confirm:$false

