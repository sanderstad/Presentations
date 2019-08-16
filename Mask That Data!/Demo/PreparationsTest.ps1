
param(
    [string]$SqlInstance,
    [PSCredential]$SqlCredential,
    [string]$Database,
    [switch]$KeepProcesses
)

Import-Module dbatools
Import-Module pester

# Check parameter
if (-not $SqlInstance) {
    $SqlInstance = "localhost"
}

if (-not $Database) {
    $Database = @('WWI', 'WWI_Masked1', 'WWI_Masked1')
}

Describe "Presentation Preparations" {

    # Test if the correct processes are closed or running
    Context "Programs Should Be Closed" {

        $processes = Get-Process | Select-Object ProcessName -ExpandProperty ProcessName

        if (-not $KeepProcesses) {
            It "Slack should be closed" {
                "slack" -in $processes | Should -Be $false
            }

            It "Chrome should be closed" {
                "chrome" -in $processes | Should -Be $false
            }

            It "Outlook should be closed" {
                "OUTLOOK" -in $processes | Should -Be $false
            }
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

        It "ZoomIt should be running" {
            "ZoomIt" -in $processes | Should -Be $true
        }

    }

    # Test if WideWorldImporters databases are loaded and correct
    Context "Database Status" {

        $databases = Get-DbaDatabase -SqlInstance $SqlInstance -SqlCredential $SqlCredential

        It "WWI should be present" {
            $databases.Name | Should -Contain "WWI"
        }

        It "WWI_Masked1 should be present" {
            $databases.Name | Should -Contain "WWI_Masked1"
        }

        It "WWI_Masked2 should be present" {
            $databases.Name | Should -Contain "WWI_Masked2"
        }

        It "WideWorldImporters_Masked1 should not have certain indexes" {
            $table = Get-DbaDbTable -SqlInstance $SqlInstance -Database $Database[1] -Table "Customers"

            $table.Indexes.Name -contains "UQ_Sales_Customers_CustomerName" | Should -Be $false
        }

        It "WideWorldImporters_Masked2 should not have certain indexes" {
            $table = Get-DbaDbTable -SqlInstance $SqlInstance -Database $Database[2] -Table "Customers"

            $table.Indexes.Name -contains "UQ_Sales_Customers_CustomerName" | Should -Be $false
        }

    }
}