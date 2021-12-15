function Invoke-DemoCreateDirectory {
    [CmdLetBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]                      # Added the SupportsShouldProcess option
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