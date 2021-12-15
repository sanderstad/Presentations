function Remove-DemoCreatedFiles {

    <#
    .SYNOPSIS
        Remove the files

    .DESCRIPTION
        Remove the files created by the demo

    .PARAMETER Directory
        Directory to remove files from.

    .PARAMETER Force
        Force removal of files.

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
        Remove-DemoCreatedFiles -Directory "C:\Temp\Demo" -Force

        Remove the files from the directory "C:\Temp\Demo" and force removal of files.
    #>

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