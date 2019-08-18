# Mask the database

$instance = "localhost"
$database = "MTD_Masked2"

$path = Join-Path -Path (Split-Path -parent $PSCommandPath) -ChildPath "05_MaskDatabase_Config.json"

Invoke-DbaDbDataMasking -SqlInstance $instance -Database $database -FilePath $path