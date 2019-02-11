Import-Module dbatools
Import-Module pester

$instance = "STADPC"
$databaseNames = @('WideWorldImporters', 'WideWorldImporters_Masked')

# Test if WideWorldImporters databases are loaded
Describe "Presentation Preparations" {

    Context "Programs Should Be Closed" {

        $processes = Get-Process | Select-Object ProcessName -ExpandProperty ProcessName

        It "Slack should be closed" {
            "slack" -in $processes | Should -Be $false
        }

    }

    Context "Database Status" {

        $databases = Get-DbaDatabase -SqlInstance $instance -Database $databaseNames

        It "WideWorldImporters should be present" {
            "WideWorldImporters" | Should -BeIn $databases.Name
        }

        It "WideWorldImporters_Masked should be present" {
            "WideWorldImporters_Masked" | Should -BeIn $databases.Name
        }

        It "Should not have certain indexes" {
            $table = Get-DbaDbTable -SqlInstance $instance -Database $databaseNames[1] -Table "Customers"

            $table.Indexes.Name -contains "UQ_Sales_Customers_CustomerName" | Should -Be $false
        }

    }
}