$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    BeforeAll {
        $CommandName = 'Invoke-DemoCreateFiles'
    }

    Context "Validate known parameters" {
        It "Should only contain our specific parameters" {
            [string[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object { $_ -notin ('whatif', 'confirm') }

            [string[]]$knownParameters = $null # List of parameters that should be available
            $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters

            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object { $_ }) -DifferenceObject $params).Count ) | Should -Be 0
        }

        It "Should have the correct parameters" {
            <#
                Test the parameters for correctness

                Example:
                    Get-Command $CommandName | Should -HaveParameter SqlInstance -Type string -Mandatory
            #>
        }
    }
}

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {

    BeforeAll {

    }

    Context "Tests" {

    }

    AfterAll {

    }
}