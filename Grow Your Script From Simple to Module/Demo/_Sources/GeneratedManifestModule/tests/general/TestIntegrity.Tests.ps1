Describe "Validate test integrity" {
    $global:moduleBase = (Get-Module -Name GeneratedManifestModule).ModuleBase

    Context "Test available unit tests" {
        It "All functions should have a unit test" {
            # Get all the files
            $params = @{
                Path    = @("$($global:moduleBase)\functions", "$($global:moduleBase)\internal\functions")
                Recurse = $true
                File    = $true
            }
            [string[]]$functionFiles = Get-ChildItem @params | Where-Object Name -like "*.ps1" | Select-Object -ExpandProperty BaseName

            $params = @{
                Path    = "$($global:moduleBase)\tests\functions"
                Recurse = $true
                File    = $true
            }
            [string[]]$testFiles = Get-ChildItem @params | Where-Object Name -like "*.Tests.ps1" | Select-Object -ExpandProperty BaseName

            # Cleanup the values to only have the function name
            $functionFiles = $functionFiles -replace ".ps1", ""
            $testFiles = $testFiles -replace ".Tests", ""

            $compare = (Compare-Object -ReferenceObject $functionFiles -DifferenceObject $testFiles | Where-Object SideIndicator -Like '<=').InputObject
            $compare | Should -BeNullOrEmpty
        }
    }
}