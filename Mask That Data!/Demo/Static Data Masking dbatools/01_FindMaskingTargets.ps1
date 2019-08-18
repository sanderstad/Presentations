$instance = "localhost"
$database = "MTD_Masked2"

Invoke-DbaDbPiiScan -SqlInstance $instance -Database $database | Out-GridView