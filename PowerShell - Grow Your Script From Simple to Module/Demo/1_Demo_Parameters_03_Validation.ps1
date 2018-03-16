param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 20)]
    [int]$FileCount,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path -Path $_ -PathType 'Container'})]
    [string]$Destination ,
    [ValidateSet('txt', 'log')]
    [string]$Extension = 'txt',
    [switch]$DeleteFiles
)

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
for ($i = 0; $i -lt $fileCount; $i++) {
    # Generate random string
    [string]$random = -join ((65..90) + (97..122) | Get-Random -Count 10 | Foreach-Object {[char]$_})

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


