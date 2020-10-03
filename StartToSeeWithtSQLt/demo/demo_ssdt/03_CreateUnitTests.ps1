[CmdLetbinding()]

# URL for SSDT project template
# "https://github.com/sanderstad/SSDT-With-tSQLt-Template"

# Give in your settings
$instance = "localhost"
$database = "UnitTesting"
$destination = "C:\temp\unittesting_ssdt\UnitTesting\UnitTesting-Tests\TestBasic\"

#$cred = Get-Credential

########################################################################################
# DON'T CHANGE ANYTHING BELOW                                                          #
########################################################################################
if ((Get-Module -ListAvailable).Name -notcontains 'PStSQLtTestGenerator') {
    Write-Warning "Please install PStSQLtTestGenerator using 'Install-Module PStSQLtTestGenerator'"
    return
}

Invoke-PSTGTestGenerator -SqlInstance $instance -SqlCredential $cred -Database $database -OutputPath $destination