#Requires -Version 7.0
<#
.SYNOPSIS
    Parse a .tenant file and print the token stream and parse tree.

.DESCRIPTION
    Implements the TenantDSL grammar (see grammar/TenantDSL.g4) as a hand-written
    tokenizer and recursive-descent parser in PowerShell.

    Stages:
      1. Tokenizer  - converts raw text into a flat list of typed tokens
      2. Parser     - applies grammar rules to build a structured parse tree
      3. Printer    - walks the tree and prints it to the console

.PARAMETER Path
    Path to the .tenant file to parse.

.EXAMPLE
    pwsh Invoke-Parse.ps1 -Path ../example/fuzzylion.tenant
#>
param(
    [Parameter(Mandatory)]
    [string] $Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -- Token types (mirrors TenantDSL.g4 lexer rules) ----------------------------

enum TokenKind {
    Keyword     # 'tenant'
    StringLit   # "fuzzylion"
    NumberLit   # 90
    Identifier  # plan, region, features, retention
    Assign      # =
    LBrace      # {
    RBrace      # }
    LBrack      # [
    RBrack      # ]
    Comma       # ,
    EOF
}

class Token {
    [TokenKind] $Kind
    [string]    $Value
    [int]       $Line

    Token([TokenKind] $kind, [string] $value, [int] $line) {
        $this.Kind = $kind
        $this.Value = $value
        $this.Line = $line
    }

    [string] ToString() {
        return '{0,-12} | {1,-30} | line {2}' -f $this.Kind, $this.Value, $this.Line
    }
}

# -- Tokenizer ------------------------------------------------------------------

function Get-Tokens {
    param([string] $Source)

    $tokens = [System.Collections.Generic.List[Token]]::new()
    $pos = 0
    $line = 1

    while ($pos -lt $Source.Length) {
        $ch = $Source[$pos]

        # Whitespace
        if ($ch -match '\s') {
            if ($ch -eq "`n") { $line++ }
            $pos++
            continue
        }

        # Line comment: skip to end of line
        if ($pos + 1 -lt $Source.Length -and
            $Source[$pos] -eq '/' -and $Source[$pos + 1] -eq '/') {
            while ($pos -lt $Source.Length -and $Source[$pos] -ne "`n") { $pos++ }
            continue
        }

        switch ($ch) {
            '=' { $tokens.Add([Token]::new([TokenKind]::Assign, '=', $line)); $pos++; break }
            '{' { $tokens.Add([Token]::new([TokenKind]::LBrace, '{', $line)); $pos++; break }
            '}' { $tokens.Add([Token]::new([TokenKind]::RBrace, '}', $line)); $pos++; break }
            '[' { $tokens.Add([Token]::new([TokenKind]::LBrack, '[', $line)); $pos++; break }
            ']' { $tokens.Add([Token]::new([TokenKind]::RBrack, ']', $line)); $pos++; break }
            ',' { $tokens.Add([Token]::new([TokenKind]::Comma, ',', $line)); $pos++; break }

            '"' {
                $pos++  # skip opening quote
                $start = $pos
                while ($pos -lt $Source.Length -and $Source[$pos] -ne '"') {
                    $pos++
                }
                $value = $Source.Substring($start, $pos - $start)
                $tokens.Add([Token]::new([TokenKind]::StringLit, $value, $line))
                $pos++  # skip closing quote
                break
            }

            default {
                if ($ch -match '[0-9]') {
                    $start = $pos
                    while ($pos -lt $Source.Length -and $Source[$pos] -match '[0-9]') { $pos++ }
                    $tokens.Add([Token]::new([TokenKind]::NumberLit,
                            $Source.Substring($start, $pos - $start), $line))
                }
                elseif ($ch -match '[a-zA-Z_]') {
                    $start = $pos
                    while ($pos -lt $Source.Length -and $Source[$pos] -match '[\w\-]') { $pos++ }
                    $word = $Source.Substring($start, $pos - $start)
                    $kind = if ($word -eq 'tenant') { [TokenKind]::Keyword } else { [TokenKind]::Identifier }
                    $tokens.Add([Token]::new($kind, $word, $line))
                }
                else {
                    throw "Unexpected character '$ch' at line $line"
                }
            }
        }
    }

    $tokens.Add([Token]::new([TokenKind]::EOF, '<EOF>', $line))
    return [Token[]] $tokens
}

# -- Recursive-descent parser (mirrors TenantDSL.g4 parser rules) --------------
#
#   file        : tenantBlock+ EOF
#   tenantBlock : 'tenant' STRING '{' property+ '}'
#   property    : ID '=' value
#   value       : STRING | NUMBER | list
#   list        : '[' (STRING (',' STRING)*)? ']'

$script:Tokens = $null
$script:Pos = 0

function Get-Token { $script:Tokens[$script:Pos] }
function Read-Token { $t = $script:Tokens[$script:Pos]; $script:Pos++; $t }

function Assert-Token {
    param([TokenKind] $Kind)
    $t = Read-Token
    if ($t.Kind -ne $Kind) {
        throw "Parse error at line $($t.Line): expected $Kind but got $($t.Kind) ('$($t.Value)')"
    }
    return $t
}

function Read-List {
    Assert-Token([TokenKind]::LBrack) | Out-Null
    $items = [System.Collections.Generic.List[string]]::new()
    while ((Get-Token).Kind -ne [TokenKind]::RBrack) {
        $items.Add((Assert-Token([TokenKind]::StringLit)).Value)
        if ((Get-Token).Kind -eq [TokenKind]::Comma) { Read-Token | Out-Null }
    }
    Assert-Token([TokenKind]::RBrack) | Out-Null
    return [string[]] $items
}

function Read-Value {
    switch ((Get-Token).Kind) {
        ([TokenKind]::StringLit) { return (Read-Token).Value }
        ([TokenKind]::NumberLit) { return [int](Read-Token).Value }
        ([TokenKind]::LBrack) { return , (Read-List) }
        default {
            $t = Get-Token
            throw "Parse error at line $($t.Line): unexpected token $($t.Kind) ('$($t.Value)')"
        }
    }
}

function Read-Property {
    $key = (Assert-Token([TokenKind]::Identifier)).Value
    Assert-Token([TokenKind]::Assign) | Out-Null
    $value = Read-Value
    return [PSCustomObject]@{ Key = $key; Value = $value }
}

function Read-TenantBlock {
    Assert-Token([TokenKind]::Keyword) | Out-Null  # 'tenant'
    $name = (Assert-Token([TokenKind]::StringLit)).Value
    Assert-Token([TokenKind]::LBrace) | Out-Null

    $properties = [ordered] @{}
    while ((Get-Token).Kind -ne [TokenKind]::RBrace) {
        $prop = Read-Property
        $properties[$prop.Key] = $prop.Value
    }

    Assert-Token([TokenKind]::RBrace) | Out-Null
    return [PSCustomObject]@{ Name = $name; Properties = $properties }
}

function Read-TenantFile {
    $tenants = [System.Collections.Generic.List[object]]::new()
    while ((Get-Token).Kind -ne [TokenKind]::EOF) {
        $tenants.Add((Read-TenantBlock))
    }
    return $tenants.ToArray()
}

# -- Main -----------------------------------------------------------------------

$resolvedPath = Resolve-Path $Path
$source = Get-Content -Path $resolvedPath -Raw
$source = $source -replace "`r`n", "`n"

Write-Host "`n=== Source file: $resolvedPath ===" -ForegroundColor DarkGray
Write-Host $source

$script:Tokens = Get-Tokens -Source $source
$script:Pos = 0

Write-Host '=== Token stream ===' -ForegroundColor Cyan
$script:Tokens | ForEach-Object {
    Write-Host ('  {0}' -f $_)
}

Write-Host ''
Write-Host '=== Parse tree ===' -ForegroundColor Cyan

$tenants = Read-TenantFile

foreach ($tenant in $tenants) {
    Write-Host "  tenantBlock" -ForegroundColor Yellow
    Write-Host "    name = `"$($tenant.Name)`""
    foreach ($key in $tenant.Properties.Keys) {
        $val = $tenant.Properties[$key]
        if ($val -is [array]) {
            Write-Host ("    property  {0,-12} = [{1}]" -f $key, ($val -join ', '))
        }
        else {
            Write-Host ("    property  {0,-12} = {1}" -f $key, $val)
        }
    }
}

Write-Host ''
Write-Host "Parsed $($tenants.Count) tenant block(s) with no errors." -ForegroundColor Green
