# Copy this file to local.auto.tfvars (kept out of git) to use Azure CLI authentication instead of OIDC.
# Steps:
# 1. az login
# 2. (optional) az account set --subscription <subscription-id>
# 3. cp terraform/local.example.auto.tfvars terraform/local.auto.tfvars (or create manually)
# 4. Run ./deploy.sh dev plan (or apply)

# Disable OIDC so provider uses CLI token
use_oidc = false

# Optionally pin a subscription explicitly (otherwise provider detects from CLI context)
# subscription_id = "00000000-0000-0000-0000-000000000000"
# tenant_id       = "00000000-0000-0000-0000-000000000000"
