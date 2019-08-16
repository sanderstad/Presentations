$instance = "localhost"
$database = "MaskThatData"

Invoke-DbaDbPiiScan -SqlInstance $instance -Database $database | Out-GridView