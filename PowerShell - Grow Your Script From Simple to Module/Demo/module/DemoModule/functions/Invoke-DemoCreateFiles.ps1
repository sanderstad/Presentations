function Invoke-DemoCreateFiles {
    [CmdLetBinding(SupportsShouldProcess = $true)]                      # Added the SupportsShouldProcess option
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
                if ($DeleteFiles) {
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
                    }
                }
            } # end for loop
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