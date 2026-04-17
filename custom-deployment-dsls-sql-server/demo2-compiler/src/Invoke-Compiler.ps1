#Requires -Version 7.0
<#
.SYNOPSIS
    Compile one or more .tenant files to Bicep.

.DESCRIPTION
    Pipeline:
      1. Parse   - tokenize and parse each .tenant file into a TenantConfig object
      2. Load    - read plan definitions from plans.yaml
      3. Validate- check feature constraints against the selected plan
      4. Render  - produce a .bicep file using a PowerShell here-string template

.PARAMETER TenantPath
    Path to a .tenant file or a directory containing .tenant files.

.PARAMETER PlansPath
    Path to the plans.yaml file. Defaults to ../example/plans.yaml relative to this script.

.PARAMETER OutputPath
    Directory to write generated .bicep files to. Defaults to ../output.

.EXAMPLE
    # From repo root:
    pwsh demos/demo2-compiler/src/Invoke-Compiler.ps1 `
        -TenantPath demos/demo2-compiler/example/fuzzylion.tenant `
        -PlansPath  demos/demo2-compiler/example/plans.yaml `
        -OutputPath demos/demo2-compiler/output

.EXAMPLE
    # Multiple tenant files:
    pwsh demos/demo2-compiler/src/Invoke-Compiler.ps1 `
        -TenantPath demos/demo2-compiler/example `
        -OutputPath demos/demo2-compiler/output
#>
param(
    [Parameter(Mandatory)]
    [string] $TenantPath,

    [string] $PlansPath = (Join-Path $PSScriptRoot '../example/plans.yaml'),
    [string] $OutputPath = (Join-Path $PSScriptRoot '../output')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Resolve caller-relative paths using PowerShell's FileSystem provider location.
# [System.IO.Directory]::GetCurrentDirectory() is NOT updated by Set-Location,
# so it can point to the profile directory instead of wherever the user cd'd to.
# (Get-Location -PSProvider FileSystem).ProviderPath always reflects the real CWD.
$script:callerDir = (Get-Location -PSProvider FileSystem).ProviderPath
function Resolve-CallerPath([string] $p) {
    if ([System.IO.Path]::IsPathRooted($p)) { return $p }
    return [System.IO.Path]::GetFullPath((Join-Path $script:callerDir $p))
}
$TenantPath = Resolve-CallerPath $TenantPath
$PlansPath = Resolve-CallerPath $PlansPath
$OutputPath = Resolve-CallerPath $OutputPath

. (Join-Path $PSScriptRoot 'TenantModels.ps1')

# -- Parser (same tokenizer/parser as demo 1) -----------------------------------

enum TokenKind {
    Keyword
    StringLit
    NumberLit
    Identifier
    Assign
    LBrace
    RBrace
    LBrack
    RBrack
    Comma
    EOF
}

class Token {
    [TokenKind] $Kind; [string] $Value; [int] $Line
    Token([TokenKind] $k, [string] $v, [int] $l) { $this.Kind = $k; $this.Value = $v; $this.Line = $l }
}

function Get-Tokens([string] $src) {
    $list = [System.Collections.Generic.List[Token]]::new()
    $pos = 0; $line = 1
    while ($pos -lt $src.Length) {
        $ch = $src[$pos]
        if ($ch -match '\s') { if ($ch -eq "`n") { $line++ }; $pos++; continue }
        if ($pos + 1 -lt $src.Length -and $src[$pos] -eq '/' -and $src[$pos + 1] -eq '/') {
            while ($pos -lt $src.Length -and $src[$pos] -ne "`n") { $pos++ }; continue
        }
        switch ($ch) {
            '=' { $list.Add([Token]::new([TokenKind]::Assign, '=', $line)); $pos++; break }
            '{' { $list.Add([Token]::new([TokenKind]::LBrace, '{', $line)); $pos++; break }
            '}' { $list.Add([Token]::new([TokenKind]::RBrace, '}', $line)); $pos++; break }
            '[' { $list.Add([Token]::new([TokenKind]::LBrack, '[', $line)); $pos++; break }
            ']' { $list.Add([Token]::new([TokenKind]::RBrack, ']', $line)); $pos++; break }
            ',' { $list.Add([Token]::new([TokenKind]::Comma, ',', $line)); $pos++; break }
            '"' {
                $pos++; $start = $pos
                while ($pos -lt $src.Length -and $src[$pos] -ne '"') { $pos++ }
                $list.Add([Token]::new([TokenKind]::StringLit, $src.Substring($start, $pos - $start), $line))
                $pos++; break
            }
            default {
                if ($ch -match '[0-9]') {
                    $start = $pos
                    while ($pos -lt $src.Length -and $src[$pos] -match '[0-9]') { $pos++ }
                    $list.Add([Token]::new([TokenKind]::NumberLit, $src.Substring($start, $pos - $start), $line))
                }
                elseif ($ch -match '[a-zA-Z_]') {
                    $start = $pos
                    while ($pos -lt $src.Length -and $src[$pos] -match '[\w\-]') { $pos++ }
                    $word = $src.Substring($start, $pos - $start)
                    $kind = if ($word -eq 'tenant') { [TokenKind]::Keyword } else { [TokenKind]::Identifier }
                    $list.Add([Token]::new($kind, $word, $line))
                }
                else { throw "Unexpected character '$ch' at line $line" }
            }
        }
    }
    $list.Add([Token]::new([TokenKind]::EOF, '<EOF>', $line))
    return [Token[]]$list
}

$script:T = $null; $script:P = 0
function Get-T { $script:T[$script:P] }
function Read-T { $t = $script:T[$script:P]; $script:P++; $t }
function Assert-T([TokenKind]$k) {
    $t = Read-T
    if ($t.Kind -ne $k) { throw "Parse error at line $($t.Line): expected $k, got $($t.Kind) ('$($t.Value)')" }
    $t
}
function Read-List {
    Assert-T([TokenKind]::LBrack) | Out-Null
    $items = [System.Collections.Generic.List[string]]::new()
    while ((Get-T).Kind -ne [TokenKind]::RBrack) {
        $items.Add((Assert-T([TokenKind]::StringLit)).Value)
        if ((Get-T).Kind -eq [TokenKind]::Comma) { Read-T | Out-Null }
    }
    Assert-T([TokenKind]::RBrack) | Out-Null
    return [string[]]$items
}
function Read-Value {
    switch ((Get-T).Kind) {
        ([TokenKind]::StringLit) { return (Read-T).Value }
        ([TokenKind]::NumberLit) { return [int](Read-T).Value }
        ([TokenKind]::LBrack) { return , (Read-List) }
        default { throw "Unexpected token $((Get-T).Kind) at line $((Get-T).Line)" }
    }
}
function Read-TenantFile([string]$path) {
    $src = Get-Content $path -Raw
    $src = $src -replace "`r`n", "`n"  # normalise CRLF so the tokenizer works on any platform
    $script:T = Get-Tokens $src; $script:P = 0
    $tenants = [System.Collections.Generic.List[object]]::new()
    while ((Get-T).Kind -ne [TokenKind]::EOF) {
        Assert-T([TokenKind]::Keyword) | Out-Null
        $name = (Assert-T([TokenKind]::StringLit)).Value
        Assert-T([TokenKind]::LBrace) | Out-Null
        $props = [ordered]@{}
        while ((Get-T).Kind -ne [TokenKind]::RBrace) {
            $key = (Assert-T([TokenKind]::Identifier)).Value
            Assert-T([TokenKind]::Assign) | Out-Null
            $props[$key] = Read-Value
        }
        Assert-T([TokenKind]::RBrace) | Out-Null
        $tenants.Add([PSCustomObject]@{ Name = $name; Properties = $props })
    }
    return $tenants.ToArray()
}

# -- Plan loader ----------------------------------------------------------------

function Import-Plans([string] $plansFile) {
    # PowerShell 7 ships with a YAML parser via the PowerShell-yaml module.
    # For demo purposes we use a simple regex-based YAML reader so there are
    # no module dependencies.
    $yaml = Get-Content $plansFile -Raw
    $plans = @{}
    $blocks = [regex]::Matches($yaml, '(?m)^  (\w+):\s*\n((?:    .+\n?)*)')

    foreach ($block in $blocks) {
        $planName = $block.Groups[1].Value
        $body = $block.Groups[2].Value

        $get = {
            param($key)
            if ($body -match "(?m)^\s+${key}:\s+(.+)$") { $Matches[1].Trim() } else { '' }
        }

        $reqRaw = [regex]::Matches($body, "(?<=requiredFeatures:\s*\n)((?:\s+- .+\n?)*)")
        $forbRaw = [regex]::Matches($body, "(?<=forbiddenFeatures:\s*\n)((?:\s+- .+\n?)*)")

        $parseList = {
            param($m)
            if ($m.Count -eq 0 -or [string]::IsNullOrWhiteSpace($m[0].Value)) { return @() }
            [regex]::Matches($m[0].Value, '- (.+)') | ForEach-Object { $_.Groups[1].Value.Trim() }
        }

        $plans[$planName] = [PlanDefinition]::new(
            $planName,
            (& $get 'tier'),
            (& $get 'family'),
            [int](& $get 'capacity'),
            [int](& $get 'maxSizeGb'),
            [string[]](& $parseList $reqRaw),
            [string[]](& $parseList $forbRaw)
        )
    }

    return $plans
}

# -- Model builder --------------------------------------------------------------

function New-TenantConfig([PSCustomObject] $parsed) {
    $props = $parsed.Properties
    return [TenantConfig]::new(
        $parsed.Name,
        $props['plan'],
        $props['region'],
        [FeatureSet]::new([string[]]$props['features']),
        [int]$props['retention']
    )
}

# -- Bicep template ------------------------------------------------------------
function ConvertTo-Bicep([TenantConfig] $tenant, [PlanDefinition] $plan) {
    $tde = if ($tenant.Features.Has('tde')) { 'true' } else { 'false' }
    $auditing = if ($tenant.Features.Has('auditing')) { 'true' } else { 'false' }
    $geoRep = $tenant.Features.Has('geo-replication')
    $skuSection = if ($plan.Family) {
        "      name: '$($plan.Tier)'`n      tier: '$($plan.Tier)'`n      family: '$($plan.Family)'`n      capacity: $($plan.Capacity)"
    }
    else {
        "      name: '$($plan.Tier)'`n      tier: '$($plan.Tier)'`n      capacity: $($plan.Capacity)"
    }

    $geoModule = if ($geoRep) {
        @"

module geoReplication 'modules/geo-replication.bicep' = {
  name: 'geo-$($tenant.Name)'
  scope: rg
  params: {
    primaryServerId: sqlServer.outputs.serverId
    secondaryRegion: 'uksouth'
    administratorLoginPassword: sqlAdminPassword
  }
}
"@
    }
    else { '' }

    return @"
// Generated by TenantDSL compiler - do not edit manually
// Tenant : $($tenant.Name)
// Plan   : $($tenant.PlanName)
// Source : $($tenant.Name).tenant

targetScope = 'subscription'

param location string = '$($tenant.Region)'
param tenantName string = '$($tenant.Name)'

@secure()
param sqlAdminPassword string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-sql-`${tenantName}'
  location: location
}

module sqlServer 'modules/sql-server.bicep' = {
  name: 'sql-`${tenantName}'
  scope: rg
  params: {
    serverName: 'sql-`${tenantName}'
    location: location
    administratorLoginPassword: sqlAdminPassword
    elasticPoolSku: {
$skuSection
    }
    maxSizeGb: $($plan.MaxSizeGb)
    transparentDataEncryption: $tde
    auditingEnabled: $auditing
    auditRetentionDays: $($tenant.RetentionDays)
  }
}
$geoModule
module diagnostics 'modules/diagnostics.bicep' = {
  name: 'diag-`${tenantName}'
  scope: rg
  params: {
    serverId: sqlServer.outputs.serverId
    retentionDays: $($tenant.RetentionDays)
  }
}
"@
}

# -- Entry point ----------------------------------------------------------------

$tenantFiles = if (Test-Path $TenantPath -PathType Container) {
    Get-ChildItem $TenantPath -Filter '*.tenant'
}
else {
    Get-Item $TenantPath
}

if (-not (Test-Path $OutputPath)) { New-Item $OutputPath -ItemType Directory | Out-Null }

Write-Host "Loading plan definitions from $PlansPath" -ForegroundColor DarkGray
$plans = Import-Plans $PlansPath

$exitCode = 0

foreach ($file in $tenantFiles) {
    Write-Host "`nCompiling $($file.Name) ..." -ForegroundColor Cyan

    $parsed = Read-TenantFile $file.FullName
    foreach ($raw in $parsed) {
        $tenant = New-TenantConfig $raw

        if (-not $plans.ContainsKey($tenant.PlanName)) {
            Write-Error "Unknown plan '$($tenant.PlanName)' in tenant '$($tenant.Name)'"
            $exitCode = 1
            continue
        }

        $plan = $plans[$tenant.PlanName]
        $errors = $tenant.Features.ValidateAgainst($plan)

        if ($errors.Count -gt 0) {
            $errors | ForEach-Object { Write-Host "  ERROR: $_" -ForegroundColor Red }
            $exitCode = 1
            continue
        }

        $bicep = ConvertTo-Bicep $tenant $plan
        $outFile = Join-Path $OutputPath "$($tenant.Name).bicep"
        Set-Content -Path $outFile -Value $bicep -Encoding UTF8

        Write-Host "  OK  -> $outFile" -ForegroundColor Green
    }
}

exit $exitCode
