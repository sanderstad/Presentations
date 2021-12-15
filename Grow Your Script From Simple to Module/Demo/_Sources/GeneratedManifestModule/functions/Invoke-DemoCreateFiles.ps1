function Invoke-DemoCreateFiles {

    <#
    .SYNOPSIS
        Run the creation of the directories

    .DESCRIPTION
        Run the creation of the directories

    .PARAMETER FileCount
        Amount of files to create

    .PARAMETER Destination
        File destination

    .PARAMETER Extension
        Extension of the file

    .PARAMETER DeleteFiles
        Delete any existing files

    .PARAMETER Force
        Force the creation of the directory

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .NOTES
        Author: Sander Stad
        Website: http://datamasterminds.io

    .EXAMPLE
        Invoke-DemoCreateFiles -FileCount 100 -Destination C:\Temp\ -Extension .txt -DeleteFiles -Force

        Run the command with 100 files to "C;\Temp" with the extension .txt and delete any existing files.
    #>


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