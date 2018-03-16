# Show the module using a single file 'DemoModule1.psm1'

# Go to the temp directory
Set-Location -Path "C:\temp"


# Create the module
Import-Module PSModuleDevelopment
Invoke-PSMDTemplate -TemplateName PSFModule

# Name: DemoModule1
# Description: Demo module

# Add the functions from 2_Demo_Functions_03_ConfirmAndWhatif.ps1 as separate functions

# Add an asterisk to the FunctionsToExport part of the manifest
# Import the module and see which functions are listed

# Remove the asterisk from the manifest
# Add the names of the functions to the psd1 file of the demo module
# Import the module

Import-Module DemoModule1
Get-Module
Get-Command -Module DemoModule1

# Now only the functions we want exported are visible

# Execute the script below to again create the files but now from a module

$fileCount = 10
$destination1 = "C:\temp\demo1"
$destination2 = "C:\temp\demo2"

Write-Host "Executing the function with -WhatIf" -ForegroundColor Magenta
Invoke-DemoCreateFiles -FileCount $fileCount -Destination $destination1, $destination2 -DeleteFiles -Confirm:$false

