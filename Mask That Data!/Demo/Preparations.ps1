Write-PSFMessage -Level Host -Message "Starting Preparations"

$storageDir = "C:\Temp\_datamasking"

$url = "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"

$file = "$storageDir\WideWorldImporters-Full.bak"

$instance = "STADPC"
$databaseOriginal = "WWI"
$databaseMasked1 = "WWI_Masked1"
$databaseMasked2 = "WWI_Masked2"

Import-Module dbatools
Import-Module PSFramework

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-PSFMessage -Level Host -Message "Killing programs that should not be open"
<# $processes = Get-Process | Select-Object ProcessName -ExpandProperty ProcessName
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
        #Stop-Process -ProcessName chrome -ErrorAction Continue
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
} #>

# Test if the download directory is present and if not create it
try {
    if (-not (Test-Path -Path $storageDir)) {
        Write-PSFMessage -Level Host -Message "Creating storage directory"
        $null = New-Item -ItemType Directory -Path $storageDir
    }
}
catch {
    Stop-PSFFunction -Message "Could not create directory" -Target $storageDir -ErrorRecord $_
}

# Download the WideWorldImporters database when needed
try {
    if (-not (Test-Path -Path $file)) {
        Write-PSFMessage -Level Host -Message "Downloading WideWorldImporters database"
        Invoke-WebRequest -Uri $url -OutFile $file
    }
    else {
        Write-PSFMessage -Level Verbose "WideWorldImporters database is already present"
    }

}
catch {
    Stop-PSFFunction -Message "Could not download WideWorldImporters database" -Target $storageDir -ErrorRecord $_
}

# Remove the databases if present
$databases = Get-DbaDatabase -SqlInstance $instance
try {
    if ($databaseOriginal -in $databases.Name) {
        Remove-DbaDatabase -SqlInstance $instance -Database $databaseOriginal -Confirm:$false
    }

    if ($databaseMasked1 -in $databases.Name) {
        Remove-DbaDatabase -SqlInstance $instance -Database $databaseMasked1 -Confirm:$false
    }

    if ($databaseMasked2 -in $databases.Name) {
        Remove-DbaDatabase -SqlInstance $instance -Database $databaseMasked2 -Confirm:$false
    }
}
catch {
    Stop-PSFFunction -Message "Could not remove demo database(s)" -Target $storageDir -ErrorRecord $_
}

# Restore the WideWorldImporters databases
try {
    Write-PSFMessage -Level Host -Message "Restoring WideWorldImporters database"
    $null = Restore-DbaDatabase -SqlInstance $instance -Path $file -DatabaseName $databaseOriginal -ReplaceDbNameInFile -WithReplace

    Write-PSFMessage -Level Host -Message "Restoring WideWorldImporters Masked database"
    #$null = Restore-DbaDatabase -SqlInstance $instance -Path $file -DatabaseName $databaseMasked1 -ReplaceDbNameInFile -WithReplace
    $null = Restore-DbaDatabase -SqlInstance $instance -Path $file -DatabaseName $databaseMasked2 -ReplaceDbNameInFile -WithReplace
}
catch {
    Stop-PSFFunction -Message "Could not restore WideWorldImporters database" -Target $storageDir -ErrorRecord $_
}

# Prepare the WideWorldImporters database
try {
    $query = "ALTER TABLE [Sales].[Customers] DROP CONSTRAINT [UQ_Sales_Customers_CustomerName]"

    #Invoke-DbaQuery -SqlInstance $instance -Database $databaseMasked1 -Query $query
    Invoke-DbaQuery -SqlInstance $instance -Database $databaseMasked2 -Query $query
}
catch {
    Stop-PSFFunction -Message "Could not remove index" -Target $storageDir -ErrorRecord $_
}



