<#
    .SYNOPSIS
    Deployment of Environment workload
    .DESCRIPTION
    Check the Deployment of the Environment workload with all its components: Network, Global and Platform resource groups
    .EXAMPLE
    Invoke-Pester ./environment.tests.ps1
#>

$dirTests = Split-Path -Parent $MyInvocation.MyCommand.Path # former Here
$dirTestFrame = "$dirTests"
$dirEnvironment = (Get-Item $dirTests).parent.fullname # former dir
$fileTfVars = $dirTests + "/terraform.tfvars" # former tfvarfile

function formatTfVars {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Terraform variables HashTable")]
        $tfvars
    )
    # Split HashTable into its single elements to pass them into the Terraform action (validate, plan,...)
    ($tfvars.GetEnumerator() | ForEach-Object { "-var $($_.Key)=$($_.Value)" }) -join ' '
}

$Script:vars = $null

Describe "Unit Tests" -Tag 'UT' {
    $currentvars = $null
    
    BeforeEach {
        If ($vars -ne $currentvars) {
            $planfile = "ut1.tfplan"

            # For local testing only
            Write-Host "Terraform Init..."
            $command = "terraform init $dirTestFrame"
            Invoke-Expression $command
            $? | Should be $true

            Write-Host "Terraform Validate..."
            $command = "terraform validate -var-file=`"$fileTfVars`" $dirTestFrame"
            Invoke-Expression $command
            $? | Should be $true

            Write-Host "Creating test plan..."
            $command = "terraform plan -input=false -var-file=`"$fileTfVars`" -out=`"$planfile`" $dirTestFrame"
            Invoke-Expression $command
            $? | Should be $true

            Write-Host "Terraform Show..."
            $tfplan = ( terraform show -json $planfile | ConvertFrom-Json )
            $command = "terraform show -json $planfile"
            Invoke-Expression $command
            $? | Should be $true

            $Script:module = $tfplan.resource_changes 
            Remove-Item $planfile

            $currentvars = $vars
        }
    }
      

    Context "Storage Account group" {
        $vars = @{
            env_rsg      = "tstd1weustatesctocomm001"
            env_location          = "westeurope"
            env_cost_center       = "CC"
            env_product           = "test-producto"
            env_channel           = "test-channel"
            env_description       = "test-desc"
            env_tracking_code     = "test-TC"
            env_cia               = "CIA"
            env_sta_name          = "teststa191106"
            env_sta_tier          = "Standard"
            env_sta_replication   = "LRS"
        }

    
        It "Review Storage Account" {
            $sta = $module | Where-Object { $_.mode -eq "managed" -and $_.type -eq "azurerm_storage_account" }
            $sta | Should Not BeNullOrEmpty
            $sta.change.after.name | Should Be $vars.env_sta_name
            $sta.change.after.resource_group_name | Should Be $vars.env_rsg
            $sta.change.after.account_tier | Should Be $vars.env_sta_tier
            $sta.change.after.account_replication_type | Should Be $vars.env_sta_replication
            $tagCount = 0
            $tags = $sta.change.after.tags
            
            foreach ($key in $tags.psobject.properties.name) {
                $tagCount++
            }
            $tagCount | Should Be 6
            $sta.change.after.tags.channel | Should Be $vars.env_channel
            $sta.change.after.tags.cost_center | Should Be $vars.env_cost_center
            $sta.change.after.tags.description | Should Be $vars.env_description
            $sta.change.after.tags.product | Should Be $vars.env_product
            $sta.change.after.tags.tracking_code | Should Be $vars.env_tracking_code
            $sta.change.after.tags.cia | Should Be $vars.env_cia
        }
    }
}

Describe -Name 'Integration Tests' -Tags ('IT') -Fixture {

  $currentvars = $null
  $Script:vars = $null

  BeforeEach {
        If ($vars -ne $currentvars) {
            $planfile = "it1.tfplan"
            $command = "terraform plan -input=false -var-file=`"$fileTfVars`" -out=`"$planfile`" $dirTestFrame"
            Invoke-Expression $command
            $? | Should be $true
            
            Write-Host "    Creating Integration resources... Please be patient!"
            $command = "terraform apply -input=false  -auto-approve $planfile"
            Invoke-Expression $command
            $? | Should be $true 
            Remove-Item $planfile
            $Script:resources = ((terraform show -json | ConvertFrom-Json).values.root_module.child_modules).resources
            $Script:outputs = ( terraform output -json | ConvertFrom-Json )
           
            Write-Host "    Destroying Integration test resources... Please be even more patient!"
            $command = "terraform destroy -input=false -auto-approve -var-file=`"$fileTfVars`"  `"$dirTests`""
            Invoke-Expression $command
            $? | Should be $true 
            $currentvars = $vars
    }
  }

  Context -Name 'Foo Frame Case' {
    $Script:vars = @{
      env_rsg      = "tstd1weustatesctocomm001"
      env_location          = "westeurope"
      env_cost_center       = "CC"
      env_product           = "test-producto"
      env_channel           = "test-channel"
      env_description       = "test-desc"
      env_tracking_code     = "test-TC"
      env_cia               = "CIA"
      env_sta_name          = "teststa191106"
      env_sta_tier          = "Standard"
      env_sta_replication   = "LRS"
    }


    It -name 'check Storage Account plan' {
      $sta = $resources | Where-Object { $_.type -eq "azurerm_storage_account" }
      $sta | Should Not Be $null
      $sta.values.name | Should Be $vars.env_sta_name
      $tags = $sta.values.tags
     ($tags | Get-Member -MemberType NoteProperty).Count | Should Be 6
   }

  }
}