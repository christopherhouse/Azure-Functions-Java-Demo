#!/usr/bin/env pwsh
<#!
.SYNOPSIS
    Terraform deployment helper for Azure Functions Java Demo (PowerShell edition).
.DESCRIPTION
    Mirrors functionality of deploy.sh for Windows users.
    Supports actions: plan, apply, destroy against environments: dev, prod.
    Uses Azure CLI authentication (az login) and backend config files per environment.
.PARAMETER Environment
    Target environment (dev|prod).
.PARAMETER Action
    Action to perform (plan|apply|destroy). Defaults to plan.
.EXAMPLE
    ./deploy.ps1 -Environment dev -Action plan
.EXAMPLE
    ./deploy.ps1 dev apply
.NOTES
    Requires: Azure CLI, Terraform, authenticated az session, backend storage pre-created.
#>
param(
    [Parameter(Position=0,Mandatory=$true)][ValidateSet('local','dev','prod')][string]$Environment,
    [Parameter(Position=1)][ValidateSet('plan','apply','destroy')][string]$Action = 'plan'
)

$ErrorActionPreference = 'Stop'

# --- Constants ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = $ScriptDir
$EnvDir = Join-Path $TerraformDir "environments/$Environment"

# --- Logging helpers ---
function Write-Info    { param($m) ; Write-Host "[INFO ] $m" -ForegroundColor Cyan }
function Write-Success { param($m) ; Write-Host "[ OK  ] $m" -ForegroundColor Green }
function Write-Warn    { param($m) ; Write-Host "[WARN ] $m" -ForegroundColor Yellow }
function Write-ErrorMsg{ param($m) ; Write-Host "[ERROR] $m" -ForegroundColor Red }

function Assert-File($path, $desc) {
    if (-not (Test-Path $path)) { Write-ErrorMsg "$desc not found: $path" ; exit 1 }
}

# --- Validation ---
Assert-File $EnvDir 'Environment directory'
Assert-File (Join-Path $EnvDir 'terraform.tfvars') 'Variables file'
Assert-File (Join-Path $EnvDir 'backend.conf') 'Backend config file'

# --- Prerequisites ---
Write-Info 'Checking prerequisites'
if (-not (Get-Command az -ErrorAction SilentlyContinue)) { Write-ErrorMsg 'Azure CLI not installed'; exit 1 }
try { az account show --only-show-errors | Out-Null } catch { Write-ErrorMsg 'Not logged in to Azure. Run az login.'; exit 1 }
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) { Write-ErrorMsg 'Terraform not installed'; exit 1 }
Write-Success 'Prerequisites OK'

Push-Location $TerraformDir
try {
    # --- Init ---
    Write-Info "Initializing Terraform backend ($Environment)"
    terraform init -backend-config="environments/$Environment/backend.conf" -reconfigure | Write-Host
    Write-Success 'terraform init complete'

    switch ($Action) {
        'plan' {
            Write-Info "Planning ($Environment)"
            $planPath = Join-Path $EnvDir 'terraform.tfplan'
            Write-Info "Plan output -> $planPath"
            terraform plan -var-file="environments/$Environment/terraform.tfvars" -out="$planPath" | Write-Host
            Write-Info "To perform exactly these actions, run the following command to apply:"
            Write-Host "    terraform apply \"$planPath\""
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Plan complete ($planPath)"
            } else {
                Write-ErrorMsg 'Plan failed (see errors above)'
                exit 1
            }
        }
        'apply' {
            if ($env:CI -eq 'true' -or $env:TF_IN_AUTOMATION -eq 'true') {
                Write-Info 'Automation mode detected (no prompt)'
                $confirm = 'yes'
            } else {
                Write-Warn "About to APPLY changes to $Environment"
                $confirm = Read-Host 'Type yes to continue'
            }
            if ($confirm -ne 'yes') { Write-Info 'Apply cancelled'; exit 0 }

            $planFile = Join-Path $EnvDir 'terraform.tfplan'
            Write-Info 'Preparing apply'

            $regenerate = $true
            if (Test-Path $planFile) {
                Write-Info 'Validating existing plan file'
                terraform show -json "$planFile" > $null 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $regenerate = $false
                    Write-Info "Existing plan file is valid -> $planFile"
                } else {
                    Write-Warn 'Existing plan file is invalid/incomplete (will regenerate)'
                }
            } else {
                Write-Info "No existing plan file found; will generate -> $planFile"
            }

            if ($regenerate) {
                Write-Info "Generating fresh plan (apply phase) -> $planFile"
                terraform plan -var-file="environments/$Environment/terraform.tfvars" -out="$planFile" | Write-Host
                if ($LASTEXITCODE -ne 0 -or -not (Test-Path $planFile)) {
                    Write-ErrorMsg 'Failed to create a valid plan; aborting apply'
                    exit 1
                }
            }

            Write-Info "Applying plan -> $planFile"
            terraform apply "$planFile" | Write-Host
            Write-Success 'Apply complete'
            Write-Info 'Outputs:'
            terraform output
        }
        'destroy' {
            Write-Warn "This will DESTROY resources in $Environment"
            $confirm = Read-Host 'Type yes to continue'
            if ($confirm -ne 'yes') { Write-Info 'Destroy cancelled'; exit 0 }
            terraform destroy -var-file="environments/$Environment/terraform.tfvars" -auto-approve | Write-Host
            Write-Success 'Destroy complete'
        }
    }
    Write-Success 'Operation finished'
}
finally {
    Pop-Location
}
