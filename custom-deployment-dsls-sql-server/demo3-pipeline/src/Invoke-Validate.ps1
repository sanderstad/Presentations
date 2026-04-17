#Requires -Version 7.0
<#
.SYNOPSIS
    Lint all .tenant files in a directory without writing any output.

.DESCRIPTION
    Runs the compiler in dry-run mode (no output files written).
    Any parse error or constraint violation causes a non-zero exit.

.PARAMETER TenantPath
    Directory containing .tenant files.

.PARAMETER PlansPath
    Path to the plans.yaml file.

.PARAMETER CompilerPath
    Path to Invoke-Compiler.ps1.

.EXAMPLE
    pwsh Invoke-Validate.ps1 -TenantPath ../../tenants -PlansPath ../../demo2-compiler/example/plans.yaml -CompilerPath ../../demo2-compiler/src/Invoke-Compiler.ps1
#>
param(
    [Parameter(Mandatory)] [string] $TenantPath,
    [Parameter(Mandatory)] [string] $PlansPath,
    [Parameter(Mandatory)] [string] $CompilerPath
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

$tenantFiles = @(Get-ChildItem $TenantPath -Filter '*.tenant' -Recurse)
if ($tenantFiles.Count -eq 0) {
    Write-Host "No .tenant files found in $TenantPath" -ForegroundColor Yellow
    exit 0
}

Write-Host "Validating $($tenantFiles.Count) tenant file(s) ..." -ForegroundColor Cyan

# Run compiler to a temp directory; discard output if successful
$tempOut = Join-Path ([System.IO.Path]::GetTempPath()) "tenant-validate-$(New-Guid)"
New-Item -ItemType Directory -Path $tempOut | Out-Null

try {
    & pwsh -NonInteractive -File $CompilerPath `
        -TenantPath $TenantPath `
        -PlansPath $PlansPath `
        -OutputPath $tempOut

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Validation failed - see errors above." -ForegroundColor Red
        exit 1
    }

    Write-Host "All tenant files are valid." -ForegroundColor Green
}
finally {
    Remove-Item $tempOut -Recurse -Force -ErrorAction SilentlyContinue
}
