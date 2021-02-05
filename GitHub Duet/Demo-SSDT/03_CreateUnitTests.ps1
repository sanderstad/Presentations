# URL for PowerShell module
# https://github.com/sanderstad/PStSQLtTestGenerator

. ".\variables.ps1"

#$cred = Get-Credential

########################################################################################
# DON'T CHANGE ANYTHING BELOW                                                          #
########################################################################################
if ((Get-Module -ListAvailable).Name -notcontains 'PStSQLtTestGenerator') {
    Write-Warning "Please install PStSQLtTestGenerator using 'Install-Module PStSQLtTestGenerator'"
    return
}

$params = @{
    SqlInstance = $instance
    SqlCredential = $cred
    Database = $database
    OutputPath = $destination
}

Invoke-PSTGTestGenerator @params