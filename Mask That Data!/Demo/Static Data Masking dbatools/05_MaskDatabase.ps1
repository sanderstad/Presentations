# Mask the database

$instance = "localhost"
$database = "MaskThatData"

$path = Join-Path -Path (Split-Path -parent $PSCommandPath) -ChildPath "05_MaskDatabase_Config.json"

Invoke-DbaDbDataMasking -SqlInstance $instance -Database $database -FilePath $path