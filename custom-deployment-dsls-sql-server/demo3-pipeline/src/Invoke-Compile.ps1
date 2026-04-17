#Requires -Version 7.0
<#
.SYNOPSIS
    Compile all .tenant files in a directory to Bicep.

.DESCRIPTION
    Thin wrapper around Invoke-Compiler.ps1 for use in a CI/CD pipeline.
    Writes generated .bicep files to the output directory and copies the
    Bicep module library alongside them so the output is self-contained
    for deployment.

.PARAMETER TenantPath
    Directory containing .tenant files.

.PARAMETER PlansPath
    Path to the plans.yaml file.

.PARAMETER CompilerPath
    Path to Invoke-Compiler.ps1.

.PARAMETER OutputPath
    Directory to write generated .bicep files to.

.PARAMETER ModulesPath
    Path to the infra/modules directory. When provided, modules are copied
    into OutputPath/modules so the generated Bicep can find them at deploy time.
    Defaults to infra/modules relative to the repo root.

.EXAMPLE
    pwsh Invoke-Compile.ps1 `
        -TenantPath   ../../tenants `
        -PlansPath    ../../demo2-compiler/example/plans.yaml `
        -CompilerPath ../../demo2-compiler/src/Invoke-Compiler.ps1 `
        -OutputPath   ./output `
        -ModulesPath  ../../infra/modules
#>
param(
    [Parameter(Mandatory)] [string] $TenantPath,
    [Parameter(Mandatory)] [string] $PlansPath,
    [Parameter(Mandatory)] [string] $CompilerPath,
    [Parameter(Mandatory)] [string] $OutputPath,
    [string] $ModulesPath = (Join-Path $PSScriptRoot '../../../infra/modules')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve caller-relative paths using PowerShell's FileSystem provider location.
# [System.IO.Directory]::GetCurrentDirectory() is NOT updated by Set-Location,
# so it can point to the profile directory instead of wherever the user cd'd to.
# (Get-Location -PSProvider FileSystem).ProviderPath always reflects the real CWD.
$callerDir = (Get-Location -PSProvider FileSystem).ProviderPath
function Resolve-CallerPath([string] $p) {
    if ([System.IO.Path]::IsPathRooted($p)) { return $p }
    return [System.IO.Path]::GetFullPath((Join-Path $callerDir $p))
}
$TenantPath   = Resolve-CallerPath $TenantPath
$PlansPath    = Resolve-CallerPath $PlansPath
$CompilerPath = Resolve-CallerPath $CompilerPath
$OutputPath   = Resolve-CallerPath $OutputPath
if ($ModulesPath) {
    $ModulesPath = Resolve-CallerPath $ModulesPath
}

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

Write-Host "Compiling tenant definitions from $TenantPath ..." -ForegroundColor Cyan
Write-Host "Output directory : $OutputPath"
if ($ModulesPath -and (Test-Path $ModulesPath)) {
    Write-Host "Modules path     : $ModulesPath"
}

& pwsh -NonInteractive -File $CompilerPath `
    -TenantPath $TenantPath `
    -PlansPath $PlansPath `
    -OutputPath $OutputPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation failed - see errors above." -ForegroundColor Red
    exit 1
}

# Copy Bicep modules alongside generated output so the artifact is self-contained.
# Generated Bicep files reference 'modules/sql-server.bicep' etc. as relative paths.
if ($ModulesPath -and (Test-Path $ModulesPath)) {
    $modulesTarget = Join-Path $OutputPath 'modules'
    Copy-Item -Path $ModulesPath -Destination $modulesTarget -Recurse -Force
    $moduleCount = @(Get-ChildItem $modulesTarget -Filter '*.bicep').Count
    Write-Host "Copied $moduleCount module(s) to $modulesTarget" -ForegroundColor DarkGray
}
else {
    Write-Warning "Modules path '$ModulesPath' not found - generated Bicep will not be deployable without modules."
}

$generated = @(Get-ChildItem $OutputPath -Filter '*.bicep')
Write-Host "`nGenerated $($generated.Count) Bicep file(s):" -ForegroundColor Green
$generated | ForEach-Object { Write-Host "  $($_.Name)" }
