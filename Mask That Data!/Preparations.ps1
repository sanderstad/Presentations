Write-PSFMessage -Level Host -Message "Starting Preparations"

$storageDir = "C:\Temp\_datamasking"

$urlDDM = "https://github.com/sanderstad/Presentations/blob/master/Mask%20That%20Data!/Dynamic%20Data%20Masking/DynamicDataMasking.bak"
$urlWWI = "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"

$fileDDM = "$storageDir\DynamicDataMasking.bak"
$fileWWI = "$storageDir\WideWorldImporters-Full.bak"

$instance = "STADPC"

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

# Download the DynamicDataMasking database when needed
try{
    if(-not (Test-Path -Path $fileDDM)){
        Write-PSFMessage -Level Host -Message "Downloading DynamicDataMasking database"
        Invoke-WebRequest -Uri $urlDDM -OutFile $fileDDM
    }
    else{
        Write-PSFMessage -Level Verbose "DynamicDataMasking database is already present"
    }

}
catch{
    Stop-PSFFunction -Message "Could not download DynamicDataMasking database" -Target $storageDir -ErrorRecord $_
}

# Download the WideWorldImporters database when needed
try{
    if(-not (Test-Path -Path $fileWWI)){
        Write-PSFMessage -Level Host -Message "Downloading WideWorldImporters database"
        Invoke-WebRequest -Uri $urlWWI -OutFile $fileWWI
    }
    else{
        Write-PSFMessage -Level Verbose "WideWorldImporters database is already present"
    }

}
catch{
    Stop-PSFFunction -Message "Could not download WideWorldImporters database" -Target $storageDir -ErrorRecord $_
}

# Restore DDM database
try{
    Write-PSFMessage -Level Host -Message "Restoring DynamicDataMasking database"
    $null = Restore-DbaDatabase -SqlInstance $instance -Path $fileDDM -DatabaseName "DynamicDataMasking" -ReplaceDbNameInFile -WithReplace
}
catch{
    Stop-PSFFunction -Message "Could not restore DynamicDataMasking database" -Target $storageDir -ErrorRecord $_
}

# Restore the WideWorldImporters databases
<# try{
    Write-PSFMessage -Level Host -Message "Restoring WideWorldImporters database"
    $null = Restore-DbaDatabase -SqlInstance $instance -Path $fileWWI -DatabaseName "WideWorldImporters" -ReplaceDbNameInFile -WithReplace

    Write-PSFMessage -Level Host -Message "Restoring WideWorldImporters Masked database"
    $null = Restore-DbaDatabase -SqlInstance $instance -Path $fileWWI -DatabaseName "WideWorldImporters_Masked" -ReplaceDbNameInFile -WithReplace
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
} #>



