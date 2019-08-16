# Test the masking config

$path = Join-Path -Path (Split-Path -parent $PSCommandPath) -ChildPath "04_TestMaskingConfiguration_Config.json"

Test-DbaDbDataMaskingConfig -FilePath $path