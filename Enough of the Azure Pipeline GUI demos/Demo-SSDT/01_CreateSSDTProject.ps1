# URL for SSDT project template
# https://github.com/sanderstad/SSDT-With-tSQLt-Template

# Import the global variables
. ".\variables.ps1"


########################################################################################
# DON'T CHANGE ANYTHING BELOW                                                          #
########################################################################################
if ((Get-Module -ListAvailable).Name -notcontains 'PSFrameWork') {
    Write-Warning "Please install PSFramework using 'Install-Module PSFramework'"
    return
}

# Setup variables
$url = "https://github.com/sanderstad/SSDT-With-tSQLt-Template/archive/master.zip"
$zipFilePath = "$($Env:TEMP)\SSDT-With-tSQLt-Template.zip"
$archiveDestPath = "$($Env:TEMP)\SSDT-With-tSQLt-Template"
$pathToTemplate = "$($archiveDestPath)\SSDT-With-tSQLt-Template-master"

# Check if the template is not already there
$templates = Get-PSMDTemplate # Should not contain 'SSDT-With-tSQLt-Template'
if ($templates.Name -contains $templateName) {
    try {
        Write-PSFMessage -Level Host -Message "Removing PSF template"
        Remove-PSMDTemplate -TemplateName $templateName -Confirm:$false
    }
    catch {
        Stop-PSFFunction -Message "Could not remove template"
        return
    }
}

# Check if the directory is already there
$projectPath = Join-Path -Path $projectDestinationPath -ChildPath $projectName
if ((Test-Path -Path $projectDestinationPath)) {
    try {
        Write-PSFMessage -Level Host -Message "Removing project destination path '$projectDestinationPath'"
        $null = Remove-Item -Path $projectDestinationPath -Recurse -Force
    }
    catch {

    }
}

# Remove the template directory
if (Test-Path -Path $archiveDestPath) {
    try {
        Write-PSFMessage -Level Host -Message "Removing existing archive destination path '$archiveDestPath'"
        $null = Remove-Item -Path $archiveDestPath -Recurse -Force
    }
    catch {
        Stop-PSFFunction -Message "Could not remove archive destination directory '$archiveDestPath'"
    }
}

# Create the project dir
try {
    Write-PSFMessage -Level Host -Message "Creating project directory '$projectPath'"
    $null = New-Item -Path $projectPath -ItemType Directory
}
catch {
    Stop-PSFFunction -Message "Could not create project destination directory"
    return
}

# Download the file
try {
    Write-PSFMessage -Level Host -Message "Downloading file to '$zipFilePath'"
    $null = Invoke-WebRequest -Uri $url -OutFile $zipFilePath
}
catch {
    Stop-PSFFunction -Message "Something went wrong downloading the template archive" -Target $url -ErrorRecord $_
    return
}

# Extract the archive
try {
    Write-PSFMessage -Level Host -Message "Extracting '$zipFilePath' to '$archiveDestPath'"
    Expand-Archive -Path $zipFilePath -DestinationPath $archiveDestPath -Force
}
catch {
    Stop-PSFFunction -Message "Something went wrong extracting the template" -Target $url -ErrorRecord $_
    return
}

# Create the template
try {
    Write-PSFMessage -Level Host -Message "Creating new PSF template '$templateName' from '$pathToTemplate'"
    New-PSMDTemplate -ReferencePath $pathToTemplate -TemplateName $templateName -Description $templateDescription -Force
}
catch {
    Stop-PSFFunction -Message "Something went wrong creating the template" -Target $url -ErrorRecord $_
    return
}

# Create the project
try {
    Write-PSFMessage -Level Host -Message "Creating solution from template '$templateName'"
    Invoke-PSMDTemplate -TemplateName $templateName -OutPath $projectDestinationPath -Name $projectName -Force
}
catch {
    Stop-PSFFunction -Message "Something went wrong creating the project" -Target $url -ErrorRecord $_
    return
}

# Open the windows explorer with this solution
explorer (Join-Path -Path $projectDestinationPath -ChildPath $projectName)
