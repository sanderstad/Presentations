param(
    [string]$SqlInstance,
    [PSCredential]$SqlCredential,
    [string]$Database,
    [switch]$KeepProcesses,
    [switch]$SkipCleanup
)


Write-PSFMessage -Level Host -Message "Starting Preparations"

# Import modules
Import-Module dbatools
Import-Module PSFramework

# Check parameter
if (-not $SqlInstance) {
    $SqlInstance = "localhost"
}

if (-not $KeepProcesses) {
    $closeProcesses = $true
}
else {
    $closeProcesses = $false
}

# Connect to the server
try {
    $server = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $SqlCredential
}
catch {
    Stop-PSFFunction -Message "Could not connect to instance" -Category ConnectionError -Target $SqlInstance -ErrorRecord $_
    return
}

# Set defaults
$url = "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"

$backupFile = Join-Path -Path $server.BackupDirectory -ChildPath "$($url.Split("/")[-1])"

$databases = @("MTD", "MTD_Masked1", "MTD_Masked2")

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Clean up
if (-not $SkipCleanup) {
    if (Test-Path -Path $backupFile) {
        try {
            $null = Remove-Item -Path $backupFile -Confirm:$false -Force
        }
        catch {
            Stop-PSFFunction -Message "Could not clean up backup file" -Target $SqlInstance -ErrorRecord $_
        }
    }

    try {
        Remove-DbaDatabase -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database $databases -Confirm:$false
    }
    catch {
        Stop-PSFFunction -Message "Could not clean up databases" -Target $SqlInstance -ErrorRecord $_
    }
}

# Close processes
if ($closeProcesses) {
    Write-PSFMessage -Level Host -Message "Killing programs that should not be open"

    # Get the processes
    $processes = Get-Process | Select-Object ProcessName -ExpandProperty ProcessName

    # Close the individual processes
    if ("slack" -in $processes) {
        try {
            Stop-Process -ProcessName slack -ErrorAction Continue
        }
        catch {
            Write-PSFMessage -Level Critical -Message "Could not stop Slack"
        }
    }

    if ("chrome" -in $processes) {
        try {
            Stop-Process -ProcessName chrome -ErrorAction Continue
        }
        catch {
            Write-PSFMessage -Level Critical -Message "Could not stop Chrome"
        }
    }

    if ("Teams" -in $processes) {
        try {
            Stop-Process -ProcessName Teams -ErrorAction Continue
        }
        catch {
            Write-PSFMessage -Level Critical -Message "Could not stop Teams"
        }
    }
}

# Download the WideWorldImporters database when needed
try {
    if (-not (Test-Path -Path $backupFile)) {
        Write-PSFMessage -Level Host -Message "Downloading WideWorldImporters database"
        Invoke-WebRequest -Uri $url -OutFile $backupFile
    }
    else {
        Write-PSFMessage -Level Verbose "WideWorldImporters database is already present"
    }

}
catch {
    Stop-PSFFunction -Message "Could not download WideWorldImporters database" -Target $backupFile -ErrorRecord $_
}

# Restore the WideWorldImporters databases
foreach ($db in $databases) {
    try {
        Write-PSFMessage -Level Host -Message "Restoring database $db"
        $null = Restore-DbaDatabase -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Path $backupFile -DatabaseName $db -ReplaceDbNameInFile -WithReplace
    }
    catch {
        Stop-PSFFunction -Message "Could not restore WideWorldImporters database" -Target $SqlInstance -ErrorRecord $_
    }
}

# Prepare the WideWorldImporters database
try {
    $query = "ALTER TABLE [Sales].[Customers] DROP CONSTRAINT [UQ_Sales_Customers_CustomerName]"

    Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $SqlCredential -Database $databases[2] -Query $query
}
catch {
    Stop-PSFFunction -Message "Could not remove index" -Target $SqlInstance -ErrorRecord $_
}

# Clean up
if (-not $SkipCleanup) {
    try {
        $null = Remove-Item -Path $backupFile -Confirm:$false -Force
    }
    catch {
        Stop-PSFFunction -Message "Could not clean up backup file" -Target $SqlInstance -ErrorRecord $_
    }
}



