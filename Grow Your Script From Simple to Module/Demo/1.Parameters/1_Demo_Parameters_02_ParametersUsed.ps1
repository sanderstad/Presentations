param(
    [Parameter(Mandatory = $true)]
    [int]$FileCount,
    [Parameter(Mandatory = $true)]
    [string]$Destination ,
    [string]$Extension = 'txt',
    [switch]$DeleteFiles
)

# Test if destination exists
if (-not (Test-Path $Destination)) {
    Write-Host "Creating destination directory..."
    # Try to create destination directory
    try {
        New-Item -Path $Destination -ItemType Directory
    }
    catch {
        Write-Error "Couldn't create directory $Destination.`n$_"
        return
    }
}

# Checking if files need to be deleted
if ($DeleteFiles) {
    Write-Host "Deleting files..."
    $item = Get-ChildItem -Path $Destination

    # Check if there are any items in the directory
    if ($item.Count -ge 1) {
        try {
            Remove-Item -Path "$Destination\*.*"
        }
        catch {
            Write-Error "Couldn't remove files.`n$_"
        }

    }
}

Write-Host "Create files..."
for ($i = 0; $i -lt $FileCount; $i++) {
    # Generate random string
    [string]$random = -join ((65..90) + (97..122) | Get-Random -Count 10 | Foreach-Object { [char]$_ })

    # Setup the new file path
    $newFilePath = "$Destination\File_$random.$Extension"

    # Try to create the file
    try {
        New-Item -Path $newFilePath -ItemType File
    }
    catch {
        Write-Error "Couldn't create file $newFilePath.`n$_"
    }
}

# 1_Demo_Parameters_02_ParametersUsed.ps1 -FileCount 10 -Destination C:\Temp\Files -Extension txt -DeleteFiles


