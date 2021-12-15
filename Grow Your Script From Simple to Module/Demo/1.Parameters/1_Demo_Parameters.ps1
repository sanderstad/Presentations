$script:modulePath = "$script:fileOutputPathmodules"

$script:fileOutputPath = "$script:modulePath\output"
$script:fileOutputPath = "$script:modulePath\output"

break

# Execte the raw script
.\1_Demo_Parameters_01_RawScript.ps1

# Execute the parameterized script
.\1_Demo_Parameters_02_ParametersUsed.ps1 -FileCount 10 -Destination $script:fileOutputPath

# Failed attempt with an invalid file count
.\1_Demo_Parameters_03_Validation.ps1 -FileCount 25 -Destination $script:fileOutputPath -DeleteFiles

# Failed attempt with an invalid destination
.\1_Demo_Parameters_03_Validation.ps1 -FileCount 20 -Destination "$($script:fileOutputPath)2" -DeleteFiles

# Failed attempt with an invalid extension
.\1_Demo_Parameters_03_Validation.ps1 -FileCount 20 -Destination $script:fileOutputPath -Extension bat -DeleteFiles

# Execute the script with functions
.\1_Demo_Parameters_04_FunctionsImplemented.ps1

