[CmdLetbinding()]

# URL for SSDT project template
# "https://github.com/sanderstad/SSDT-With-tSQLt-Template"

# EXAMPLE
# .\00_CreateSSDTProject.ps1 -ProjectName DB1 -OutputPath C:\projects\ -TemplateName SSDT-With-tSQLt-Template
# Create a SSDT solution for a database called "DB1" and output it to "C:\Projects"


########################################################################################
# DON'T CHANGE ANYTHING BELOW                                                          #
########################################################################################

param(
    [string]$ProjectName,
    [string]$OutputPath,
    [string]$TemplateName,
    [string]$TemplateDescription,
    [switch]$RemoveExistingProject,
    [switch]$RemoveExistingTemplate
)

if (-not (Get-Module -ListAvailable -Name 'dbatools')) {
    Write-Warning "Please install the dbatools PowerShell module. 'Install-Module dbatools'"
    return
}

if (-not (Get-Module -ListAvailable -Name 'PSFrameWork')) {
    Write-Warning "Please install the PSFrameWork PowerShell module. 'Install-Module PSFrameWork'"
    return
}

if (-not $ProjectName) {
    Stop-PSFFunction -Message "Please enter a project name" -Target $SqlInstance -Continue
}

if (-not $OutputPath) {
    Stop-PSFFunction -Message "Please enter an output path" -Target $OutputPath -Continue
}
else {
    if (-not (Test-Path -Path $OutputPath)) {
        try {
            $null = New-Item -Path $OutputPath -ItemType Directory
        }
        catch {
            Stop-PSFFunction -Message "Could not create output path directory" -Target $OutputPath -ErrorRecord $_
        }
    }
}

if (-not $RemoveExistingProject -and (Get-ChildItem -Path (Join-Path -Path $OutputPath -ChildPath $ProjectName) -ErrorAction SilentlyContinue)) {
    Stop-PSFFunction -Message "There is already a project with files present. Please use -RemoveExistingProject automatically remove it"
}

if (Test-PSFFunctionInterrupt) { return }

if (-not $TemplateName) {
    $TemplateName = "SSDT-With-tSQLt"
}

if (-not $TemplateDescription) {
    $TemplateDescription = "SSDT project template including tSQLt"
}

# Setup variables
$url = "https://github.com/sanderstad/SSDT-With-tSQLt-Template/archive/master.zip"
$zipFilePath = "$($Env:TEMP)\SSDT-With-tSQLt-Template.zip"
$archiveDestPath = "$($Env:TEMP)\SSDT-With-tSQLt-Template"
$pathToTemplate = "$($archiveDestPath)\SSDT-With-tSQLt-Template-master"


# Setup the full project path
$projectPath = Join-Path -Path $OutputPath -ChildPath $ProjectName

if ($RemoveExistingProject) {
    if ((Test-Path -Path $projectPath)) {
        try {
            Write-PSFMessage -Level Host -Message "Removing project destination path '$projectPath'"
            Remove-Item -Path $projectPath -Recurse -Force
        }
        catch {
            Stop-PSFFunction -Message "Could not remove project directory" -ErrorRecord $_ -Target $projectPath -Continue
        }
    }
}

# Check if the template is not already there
$templates = Get-PSMDTemplate # Should not contain 'SSDT-With-tSQLt-Template'
if ($RemoveExistingTemplate) {
    if ($templates.Name -contains $TemplateName) {
        try {
            Write-PSFMessage -Level Host -Message "Removing PSF template"
            Remove-PSMDTemplate -TemplateName $TemplateName -Confirm:$false
        }
        catch {
            Stop-PSFFunction -Message "Could not remove template"
            return
        }
    }
}

# Remove the template directory
if (Test-Path -Path $archiveDestPath) {
    try {
        Write-PSFMessage -Level Host -Message "Removing existing archive destination path '$archiveDestPath'"
        Remove-Item -Path $archiveDestPath -Recurse -Force
    }
    catch {
        Stop-PSFFunction -Message "Could not remove archive destination directory '$archiveDestPath'"
    }
}

# Create the project dir
if (-not (Test-Path -Path $projectPath)) {
    try {
        Write-PSFMessage -Level Host -Message "Creating project directory '$projectPath'"
        $null = New-Item -Path $projectPath -ItemType Directory
    }
    catch {
        Stop-PSFFunction -Message "Could not create project destination directory"
        return
    }
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
    Write-PSFMessage -Level Host -Message "Creating new PSF template '$TemplateName' from '$pathToTemplate'"
    New-PSMDTemplate -ReferencePath $pathToTemplate -TemplateName $TemplateName -Description $TemplateDescription -Force
}
catch {
    Stop-PSFFunction -Message "Something went wrong creating the template" -Target $url -ErrorRecord $_
    return
}

# Create the project
try {
    Write-PSFMessage -Level Host -Message "Creating solution from template '$TemplateName'"
    Invoke-PSMDTemplate -TemplateName $TemplateName -OutPath $OutputPath -Name $ProjectName -Force
}
catch {
    Stop-PSFFunction -Message "Something went wrong creating the project" -Target $url -ErrorRecord $_
    return
}

# Open the windows explorer with this solution
explorer ($projectPath)
