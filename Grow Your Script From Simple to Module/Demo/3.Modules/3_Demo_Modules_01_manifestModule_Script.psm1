function Invoke-DemoCreateDirectory {
    [CmdLetBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Directory,
        [switch]$Force
    )

    if ($pscmdlet.ShouldProcess("$Directory", "Create demo directory")) {
        # Added the shoulprocess for the actions
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
}

function Remove-DemoCreatedFiles {
    [CmdLetBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Directory,
        [switch]$Force
    )

    if ($pscmdlet.ShouldProcess("$Directory", "Removing demo files")) {
        # Added the shoulprocess for the actions
        # Added the shoulprocess for the actions
        Write-Host "Deleting files..."
        $item = Get-ChildItem -Path $Directory

        # Check if there are any items in the directory
        if ($item.Count -ge 1) {
            try {
                Remove-Item -Path "$Directory\*.*" -Force:$Force
            }
            catch {
                Write-Error "Couldn't remove files.`n$_"
            }
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
    [CmdLetBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [int]$FileCount,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Destination ,
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
            Write-Error "Range for file count is not between 1 and 20"

            # Set the error
            $errorOccured = $true
        }
    }

    # Added process statement to loop through our items
    process {
        # Check if an error occured
        if (-not $errorOccured) {

            # Loop through each of the destinations
            foreach ($dest in $Destination) {
                # Added loop to support both ways of assigning variables
                # Checking if files need to be deleted
                if ($DeleteFiles -and (Test-Path $dest)) {
                    Remove-DemoCreatedFiles -Directory $dest -Force:$Force
                }

                if (-not (Test-Path $dest)) {
                    Invoke-DemoCreateDirectory -Directory $dest -Force:$Force
                }

                Write-Host "Create files..."
                if ($pscmdlet.ShouldProcess("$Directory", "Creating demo files")) {
                    # Added the shoulprocess for the actions
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

                } # if should process

            } # end for each destination
        }
        else {
            Write-Warning "Something went wrong check the errors messages"
        } # end if error

    } # end process

    # Added end to allow items to be processed at the end of the advanced function
    end {
        Write-Host "Done executing function" -ForegroundColor Green
    }
}