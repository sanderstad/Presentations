function Remove-DemoCreatedFiles {
    [CmdLetBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]                      # Added the SupportsShouldProcess option
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