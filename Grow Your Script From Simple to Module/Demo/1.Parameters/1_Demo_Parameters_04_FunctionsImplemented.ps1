

function Invoke-DemoCreateDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Directory,
        [switch]$Force
    )

    Write-Host "Creating destination directory..."
    # Try to create destination directory
    try {
        New-Item -Path $Directory -ItemType Directory -Force:$Force
    }
    catch {
        Write-Error "Couldn't create directory $Destination.`n$_"
        return
    }
}

function Remove-DemoCreatedFiles {

    param(
        [Parameter(Mandatory = $true)]
        [string]$Directory,
        [switch]$Force
    )

    Write-Host "Deleting files..."
    $item = Get-ChildItem -Path $Destination

    # Check if there are any items in the directory
    if ($item.Count -ge 1) {
        try {
            Remove-Item -Path "$Destination\*.*" -Force:$Force
        }
        catch {
            Write-Error "Couldn't remove files.`n$_"
        }
    }
}

function Get-DemoRandomString {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Length = 5
    )

    # Generate random string
    [string]$random = -join ((65..90) + (97..122) | Get-Random -Count $Length | Foreach-Object { [char]$_ })

    return $random
}

function Invoke-DemoCreateFiles {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 20)]
        [int]$FileCount,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Destination ,
        [ValidateSet('txt', 'log')]
        [string]$Extension = 'txt',
        [switch]$DeleteFiles,
        [switch]$Force
    )

    foreach ($dest in $Destination) {
        # Checking if files need to be deleted
        if ($DeleteFiles -and ((Test-Path $dest))) {
            Remove-DemoCreatedFiles -Directory $dest -Force:$Force
        }

        # Check if path exists
        if (-not (Test-Path $dest)) {
            Invoke-DemoCreateDirectory -Directory $dest -Force:$Force
        }

        Write-Host "Create files..."

        for ($i = 0; $i -lt $FileCount; $i++) {
            # Generate random string
            [string]$random = Get-DemoRandomString -Length 5

            # Setup the new file path
            $newFilePath = "$dest\File_$random.$Extension"

            # Try to create the file
            try {
                New-Item -Path $newFilePath -ItemType File
            }
            catch {
                Write-Error "Couldn't create file $newFilePath.`n$_"
            }

        } # end for loop file count

    } # end for each destination

} # end function

$fileCount = 10
$destination = "c:\temp\demo"
$destination1 = "c:\temp\demo1"
$destination2 = "c:\temp\demo2"

# Get a random string
#Get-DemoRandomString -Length 10

# Create the demo directory
#Invoke-DemoCreateDirectory -Directory $destination -Force

# Remove the files from the demo directory
#Remove-DemoCreatedFiles -Directory $destination

# Execute the main function
#Invoke-DemoCreateFiles -FileCount $fileCount -Destination $destination

# Execute the script with a multiple values
Invoke-DemoCreateFiles -FileCount $fileCount -Destination $destination1, $destination2







