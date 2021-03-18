# URL for PowerShell module
# https://github.com/sanderstad/PStSQLtTestGenerator

# Import the global variables
. ".\variables.ps1"

########################################################################################
# DON'T CHANGE ANYTHING BELOW                                                          #
########################################################################################
if ((Get-Module -ListAvailable).Name -notcontains 'PStSQLtTestGenerator') {
    Write-Warning "Please install PStSQLtTestGenerator using 'Install-Module PStSQLtTestGenerator'"
    return
}

Invoke-PSTGTestGenerator -SqlInstance $sqlInstance -SqlCredential $sqlCredential -Database $database -OutputPath $destination