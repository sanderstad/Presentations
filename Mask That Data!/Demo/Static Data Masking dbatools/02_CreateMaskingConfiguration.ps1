# Set variables
$instance = "localhost"
$database = "MaskThatData"
$outputPath = "c:\temp\_datamasking"

# Check if the outpath directory exists
if (-not (Test-Path -Path $outputPath)) {
    $null = New-Item -Path $outputPath -ItemType Directory
}

# Create the config
$result = New-DbaDbMaskingConfig -SqlInstance $instance -Database $database -Path $outputPath

# Open the file in vscode
code $result.FullName
