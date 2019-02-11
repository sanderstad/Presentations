Write-PSFMessage -Level Host -Message "Starting Preparations"

$storageDir = "C:\Temp\_datamasking"

$url = "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"
$file = "$storageDir\WideWorldImporters-Full.bak"

$instance = "STADPC"
$databaseOriginal = "WideWorldImporters"
$databaseMasked = "WideWorkdImporters_Masked"

Import-Module dbatools
Import-Module PSModuleDevelopment

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Test if the download directory is present and if not create it
try{
    if(-not (Test-Path -Path $storageDir)){
        Write-PSFMessage -Level Host -Message "Creating storage directory"
        $null = New-Item -ItemType Directory -Path $storageDir
    }
}
catch{
    Stop-PSFFunction -Message "Could not create directory" -Target $storageDir -ErrorRecord $_
}

# Download the WideWorldImporters database when needed
try{
    if(-not (Test-Path -Path $file)){
        Write-PSFMessage -Level Host -Message "Downloading WideWorldImporters database"
        Invoke-WebRequest -Uri $url -OutFile $file -TransferEncoding
    }
    else{
        Write-PSFMessage -Level Verbose "WideWorldImporters database is already present"
    }

}
catch{
    Stop-PSFFunction -Message "Could not download WideWorldImporters database" -Target $storageDir -ErrorRecord $_
}

# Restore the WideWorldImporters databases
try{
    Write-PSFMessage -Level Host -Message "Restoring WideWorldImporters database"
    $null = Restore-DbaDatabase -SqlInstance $instance -Path $file -DatabaseName $databaseOriginal -ReplaceDbNameInFile -WithReplace

    Write-PSFMessage -Level Host -Message "Restoring WideWorldImporters Masked database"
    $null = Restore-DbaDatabase -SqlInstance $instance -Path $file -DatabaseName $databaseMasked -ReplaceDbNameInFile -WithReplace
}
catch{
    Stop-PSFFunction -Message "Could not restore WideWorldImporters database" -Target $storageDir -ErrorRecord $_
}

# Prepare the WideWorldImporters database
try{
    $query = "ALTER TABLE [Sales].[Customers] DROP CONSTRAINT [UQ_Sales_Customers_CustomerName]"

    Invoke-DbaQuery -SqlInstance $instance -Database $databaseMasked -Query $query
}
catch{
    Stop-PSFFunction -Message "Could not remove index" -Target $storageDir -ErrorRecord $_
}



