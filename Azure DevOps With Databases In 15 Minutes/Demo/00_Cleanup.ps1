. ".\variables.ps1"

# Connect to the server
Write-PSFMessage -Level Host -Message "Connecting to sql instance"
try {
    $server = Connect-DbaInstance -SqlInstance $instance -SqlCredential $cred
}
catch {
    Stop-PSFFunction -Message "Could not connect to $instance" -Target $instance -ErrorRecord $_
}

# Check if the database is already present
if ($server.Databases.Name -contains $database) {
    try {
        Write-PSFMessage -Level Host -Message "Removing database"
        $null = Remove-DbaDatabase -SqlInstance $instance -SqlCredential $cred -Database $database -Confirm:$false
    }
    catch {
        Stop-PSFFunction -Message "Could not remove database" -Target $database -ErrorRecord $_ -Continue
    }
}

if ((Test-Path -Path $projectDestinationPath)) {
    try {
        Write-PSFMessage -Level Host -Message "Removing solution"
        $null = Get-ChildItem (Join-Path -Path $projectDestinationPath -ChildPath $projectName) -Recurse | Remove-Item -Recurse -Force -Confirm:$false
    }
    catch {
        Stop-PSFFunction -Message "Could not remove project directory" -Target $projectDestinationPath -ErrorRecord $_ -Continue
    }
}