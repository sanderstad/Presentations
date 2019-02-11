Write-PSFMessage -Level Host -Message "Starting Preparations"

$storageDir = "C:\Temp\_datamasking"

$urlDb = "https://github.com/sanderstad/Presentations/raw//master/Mask%20That%20Data!/Downloads/MaskThatData.bak"
#$urlWWI = "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"

$fileDb = "$storageDir\MaskThatData.bak"
#$fileWWI = "$storageDir\WideWorldImporters-Full.bak"

$instance = "STADPC"

Import-Module dbatools
Import-Module PSModuleDevelopment

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

# Download the MaskThatData database when needed
try{
    if(-not (Test-Path -Path $fileDb)){
        Write-PSFMessage -Level Host -Message "Downloading MaskThatData database"
        Invoke-WebRequest -UseBasicParsing $urlDb -OutFile $fileDb
    }
    else{
        Write-PSFMessage -Level Verbose "MaskThatData database backup is already present"
    }

}
catch{
    Stop-PSFFunction -Message "Could not download MaskThatData database" -Target $storageDir -ErrorRecord $_
}


# Restore database
try{
    Write-PSFMessage -Level Host -Message "Restoring MaskThatData database"
    $null = Restore-DbaDatabase -SqlInstance $instance -Path $fileDb -WithReplace
}
catch{
    Stop-PSFFunction -Message "Could not restore MaskThatData database" -Target $storageDir -ErrorRecord $_
}




