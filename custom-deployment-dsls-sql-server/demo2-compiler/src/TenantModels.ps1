# TenantModels.ps1
# Data model classes for the TenantDSL compiler.
# Dot-source this file before using Invoke-Compiler.ps1.

class FeatureSet {
    [string[]] $Features

    FeatureSet([string[]] $features) {
        $this.Features = $features ?? @()
    }

    # Returns true if the named feature is enabled for this tenant.
    [bool] Has([string] $feature) {
        return $this.Features -contains $feature
    }

    # Validates this feature set against a plan's constraints.
    # Returns a (possibly empty) array of error messages.
    [string[]] ValidateAgainst([PlanDefinition] $plan) {
        $errors = [System.Collections.Generic.List[string]]::new()

        foreach ($req in $plan.RequiredFeatures) {
            if (-not $this.Has($req)) {
                $errors.Add("Plan '$($plan.Name)' requires feature '$req' but it is not enabled.")
            }
        }

        foreach ($forbidden in $plan.ForbiddenFeatures) {
            if ($this.Has($forbidden)) {
                $errors.Add("Plan '$($plan.Name)' forbids feature '$forbidden' but it is enabled.")
            }
        }

        return [string[]] $errors
    }
}

class PlanDefinition {
    [string]   $Name
    [string]   $Tier
    [string]   $Family
    [int]      $Capacity
    [int]      $MaxSizeGb
    [string[]] $RequiredFeatures
    [string[]] $ForbiddenFeatures

    PlanDefinition(
        [string]   $name,
        [string]   $tier,
        [string]   $family,
        [int]      $capacity,
        [int]      $maxSizeGb,
        [string[]] $requiredFeatures,
        [string[]] $forbiddenFeatures
    ) {
        $this.Name             = $name
        $this.Tier             = $tier
        $this.Family           = $family
        $this.Capacity         = $capacity
        $this.MaxSizeGb        = $maxSizeGb
        $this.RequiredFeatures = $requiredFeatures  ?? @()
        $this.ForbiddenFeatures= $forbiddenFeatures ?? @()
    }
}

class TenantConfig {
    [string]         $Name
    [string]         $PlanName
    [string]         $Region
    [FeatureSet]     $Features
    [int]            $RetentionDays

    TenantConfig(
        [string]     $name,
        [string]     $planName,
        [string]     $region,
        [FeatureSet] $features,
        [int]        $retentionDays
    ) {
        $this.Name          = $name
        $this.PlanName      = $planName
        $this.Region        = $region
        $this.Features      = $features
        $this.RetentionDays = $retentionDays
    }
}
