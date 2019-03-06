
$database = "WWI_Masked2"
$filePath = "Presentations:\__Original\Mask That Data!\demo\Static Data Masking dbatools\WWI_Masked2_Corrected.tables.json"

Invoke-DbaDbDataMasking -SqlInstance [putinyourservername] -Database $database -FilePath $filePath -Confirm:$false