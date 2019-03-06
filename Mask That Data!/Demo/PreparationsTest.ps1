Import-Module dbatools
Import-Module pester

$instance = "putinyourservername"
$databaseNames = @('WideWorldImporters', 'WideWorldImporters_Masked1', 'WideWorldImporters_Masked2')

# Test if WideWorldImporters databases are loaded
Describe "Presentation Preparations" {

    Context "Programs Should Be Closed" {

        $processes = Get-Process | Select-Object ProcessName -ExpandProperty ProcessName

        It "Slack should be closed" {
            "slack" -in $processes | Should -Be $false
        }

        It "Chrome should be closed" {
            "chrome" -in $processes | Should -Be $false
        }

        It "Outlook should be closed" {
            "OUTLOOK" -in $processes | Should -Be $false
        }

        It "Powerpoint should be running" {
            "POWERPNT" -in $processes | Should -Be $true
        }

        It "VS Code should be running" {
            "Code" -in $processes | Should -Be $true
        }

        It "SSMS should be running" {
            "Ssms" -in $processes | Should -Be $true
        }

    }

    Context "Database Status" {

        $databases = Get-DbaDatabase -SqlInstance $instance -Database $databaseNames

        It "WideWorldImporters should be present" {
            "WideWorldImporters" | Should -BeIn $databases.Name
        }

        It "WideWorldImporters_Masked1 should be present" {
            "WideWorldImporters_Masked1" | Should -BeIn $databases.Name
        }

        It "WideWorldImporters_Masked2 should be present" {
            "WideWorldImporters_Masked2" | Should -BeIn $databases.Name
        }

        It "WideWorldImporters_Masked1 should not have certain indexes" {
            $table = Get-DbaDbTable -SqlInstance $instance -Database $databaseNames[1] -Table "Customers"

            $table.Indexes.Name -contains "UQ_Sales_Customers_CustomerName" | Should -Be $false
        }

        It "WideWorldImporters_Masked2 should not have certain indexes" {
            $table = Get-DbaDbTable -SqlInstance $instance -Database $databaseNames[2] -Table "Customers"

            $table.Indexes.Name -contains "UQ_Sales_Customers_CustomerName" | Should -Be $false
        }

    }
}