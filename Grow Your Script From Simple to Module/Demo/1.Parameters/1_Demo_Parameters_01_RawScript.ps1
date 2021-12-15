$fileCount = 15
$destination = "C:\temp\demo"
$extension = 'txt'
$deleteFiles = $true

# Test if destination exists
if (-not (Test-Path $destination)) {
    Write-Host "Creating destination directory..."
    # Try to create destination directory
    try {
        New-Item -Path $destination -ItemType Directory
    }
    catch {
        Write-Error "Couldn't create directory $destination.`n$_"
    }
}

# Checking if files need to be deleted
if ($deleteFiles) {
    Write-Host "Deleting files..."
    $item = Get-ChildItem -Path $destination

    # Check if there are any items in the directory
    if ($item.Count -ge 1) {
        try {
            Remove-Item -Path "$destination\*.*"
        }
        catch {
            Write-Error "Couldn't remove files.`n$_"
        }

    }
}

Write-Host "Create files..."
for ($i = 0; $i -lt $fileCount; $i++) {
    # Generate random string
    [string]$random = -join ((65..90) + (97..122) | Get-Random -Count 10 | Foreach-Object { [char]$_ })

    # Setup the new file path
    $newFilePath = "$destination\File_$random.$extension"

    # Try to create the file
    try {
        New-Item -Path $newFilePath -ItemType File
    }
    catch {
        Write-Error "Couldn't create file $newFilePath.`n$_"
    }
}



