function Invoke-DemoCreateDirectory {

    <#
    .SYNOPSIS
        Create the directory

    .DESCRIPTION
        Create the directory

    .PARAMETER Directory
        The directory to create

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
        Invoke-DemoCreateDirectory -Directory C:\Temp\Test -Force

        Create the directory C:\Temp\Test and force the creation of the directory.
    #>

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