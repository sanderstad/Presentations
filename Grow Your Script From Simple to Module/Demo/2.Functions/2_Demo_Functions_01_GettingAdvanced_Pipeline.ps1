

function Invoke-DemoCreateDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Directory,
        [switch]$Force
    )

    Write-Host "Creating destination directory..."
    # Try to create destination directory
    try {
        New-Item -Path $Destination -ItemType Directory -Force:$Force
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
        [int]$Length # Removed the 5 because you should not initialize values in the param section
    )

    # Generate random string
    [string]$random = -join ((65..90) + (97..122) | Get-Random -Count $Length | Foreach-Object { [char]$_ })

    return $random
}

function Invoke-DemoCreateFiles {
    [cmdletbinding()] # Added this part to make the function advanced
    param(
        [Parameter(Mandatory = $true)]
        [int]$FileCount, # Removed validation
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Destination , # Changed the parameter from a single string to an array
        [ValidateSet('txt', 'log')]
        [string]$Extension = 'txt',
        [switch]$DeleteFiles,
        [switch]$Force
    )

    # Added the begin statement to allow items to be processed before the loop
    begin {
        Write-Host "Starting the function" -ForegroundColor Green

        # Set the error flag
        $errorOccured = $false

        # Check the file count range
        if ($FileCount -notin 1..20) {
            # Moved the check for the range to the begin instead of param validated
            Write-Error "Range for file count is not between 1 and 20"

            # Set the error
            $errorOccured = $true
        }
    }

    # Added process statement to loop through our items
    process {
        # Check if an error occured
        if (-not $errorOccured) {

            # Checking if files need to be deleted
            if ($DeleteFiles -and (Test-Path $Destination)) {
                Remove-DemoCreatedFiles -Directory $Destination -Force:$Force
            }

            if (-not (Test-Path $Destination)) {
                Invoke-DemoCreateDirectory -Directory $Destination -Force:$Force
            }

            Write-Host "Create files..."
            for ($i = 0; $i -lt $FileCount; $i++) {
                # Generate random string
                [string]$random = Get-DemoRandomString -Length 5

                # Setup the new file path
                $newFilePath = "$Destination\File_$random.$Extension"

                # Try to create the file
                try {
                    New-Item -Path $newFilePath -ItemType File
                }
                catch {
                    Write-Error "Couldn't create file $newFilePath.`n$_"
                }

            } # end for loop file count

        }
        else {
            Write-Warning "Something went wrong check the error messages"
        } # end if error

    } # end process

    # Added end to allow items to be processed at the end of the advanced function
    end {
        Write-Host "Done executing function" -ForegroundColor Green
    }

} # end function

$fileCount = 20
$destination1 = "C:\temp\demo1"
$destination2 = "C:\temp\demo2"

# Because of the loop I can now do this
Write-Host "Executing the function as a pipline" -ForegroundColor Magenta
$destination1, $destination2 | Invoke-DemoCreateFiles -FileCount $fileCount                 # Using the pipelines










