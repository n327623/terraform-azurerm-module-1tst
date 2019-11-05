<#
    .SYNOPSIS
    INTEGRATION TESTS: Deployment of Environment workload
    .DESCRIPTION
    Check the Deployment of the Environment workload with all its components: Network, Global and Platform resource groups
    .EXAMPLE
    Invoke-Pester ./environment.tests.ps1
#>

param(
  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$SubscriptionName,
  [Parameter(Mandatory, HelpMessage = "Resource Group name")]
  [string]$rsgName,
  [Parameter(Mandatory, HelpMessage = "Storage Account name")]
  [string]$staName,
  [Parameter(Mandatory, HelpMessage = "Storage Account Tier")]
  [string]$sta_tier,
  [Parameter(Mandatory, HelpMessage = "Storage Account replication")]
  [string]$storage_replication,
  [Parameter(Mandatory, HelpMessage = "Resources Location")]
  [string]$location
)

Describe "Integration Tests" -Tag "IT" {

    Write-Host "Starting Environment Integration Tests..."

    $Script:continueTest = $true

    BeforeEach {
        if ($continueTest -eq $true) {
            
            Write-Host "Connect to Subscription $SubscriptionName"
            Write-Host "Connect to RSG $rsgName"
            Write-Host "Connect to STA $staName"

            $subId = (Get-AzSubscription | Where-Object { $_.State -eq "Enabled" -and $_.Name -eq $SubscriptionName }).Id
            Select-AzSubscription -SubscriptionId $subId
            $Script:rsg = Get-AzResourceGroup -Name $rsgName        
            
            $Script:resSta = Get-AzResource -ResourceGroupName $rsgName -ResourceType Microsoft.Storage/storageAccounts
            $Script:sta = Get-AzStorageAccount -ResourceGroupName $rsgName -Name $staName
            Write-Host "Get-AzStorageAccount -ResourceGroupName $rsgName -Name $staName"

            $continueTest = $false
        }
    }

    Context "Environment groups" {  

        It "Checking  Storage Account" {
            $resSta | Should Not Be $null
            $resSta.Count | Should Be 1

            $sta | Should Not Be $null
            $sta.StorageAccountName | Should Be $resSta.Name
            $sta.Sku.Tier | Should Be $sta_tier
            $sta.Sku.Name | Should Match $storage_replication
            $sta.Tags.Count | Should Be 6
        }
    }
}