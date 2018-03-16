# Get to the presentation directory
Set-Location "Presentations:\__Original\PowerShell - Grow Your Script From Simple to Module\Demo"

# Execte the raw script
.\1_Demo_Parameters_01_RawScript.ps1

# Execute the parameterized script
.\1_Demo_Parameters_02_ParametersUsed.ps1 -FileCount 10 -Destination C:\temp\demo

# Failed attempt with an invalid file count
.\1_Demo_Parameters_03_Validation.ps1 -FileCount 30 -Destination C:\temp\demo -DeleteFiles

# Failed attempt with an invalid destination
.\1_Demo_Parameters_03_Validation.ps1 -FileCount 20 -Destination C:\temp\demo2 -DeleteFiles

# Failed attempt with an invalid extension
.\1_Demo_Parameters_03_Validation.ps1 -FileCount 20 -Destination C:\temp\demo -Extension bat -DeleteFiles

# Execute the script with functions
.\1_Demo_Parameters_04_FunctionsImplemented.ps1

