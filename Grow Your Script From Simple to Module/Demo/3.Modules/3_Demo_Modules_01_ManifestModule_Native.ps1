
Clear-Host

. "$($PSScriptRoot)\..\variables.ps1"

$modulePath = (Join-Path -Path $script:modulePath -ChildPath "NativeManifestModule")

# test if the directory for the module is created
if (-not(Test-Path -Path $modulePath)) {
    Write-Host "The module directory does not exist. Creating it..."
    $null = New-Item -Path $modulePath -ItemType Directory -Force
}

# Create the manifest file
$moduleParams = @{
    Path              = (Join-Path -Path $script:modulePath -ChildPath "NativeManifestModule.psd1")
    Author            = "Sander"
    CompanyName       = "FuzzyLion"
    RootModule        = "NativeManifestModule"
    FunctionsToExport = @('Invoke-DemoCreateDirectory', 'Remove-DemoCreatedFiles', 'Get-DemoRandomString', 'Invoke-DemoCreateFiles')
}
New-ModuleManifest @moduleParams

# Copy the functions
Copy-Item -Path "$($PSScriptRoot)\3_Demo_Modules_01_ManifestModule_Script.psm1" -Destination (Join-Path -Path $modulePath -ChildPath "NativeManifestModule.psm1")

# Make sure to set the root module to get the import working
# RootModule = 'NativeManifestModule'

# Import the module
Write-Host "Importing the module..."
Import-Module $modulePath

# Get all the modules
#Get-Module

# Get the individual functions
#Get-Command -Module NativeManifestModule


