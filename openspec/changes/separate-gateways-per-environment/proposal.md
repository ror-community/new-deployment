## Why

Currently, all three environments (dev, staging, prod) share a single API Gateway REST API with separate stages. This tight coupling makes it difficult to introduce changes in dev without risking unintended impacts to staging or production. Any modification to the gateway configuration requires a deployment that affects all stages.

## What Changes

- Split the single shared API Gateway REST API into separate gateways for dev and staging only
- Production will continue using the existing shared API Gateway unchanged
- Dev and staging will each have their own `aws_api_gateway_rest_api` resource with independent deployments
- The shared configuration file will remain for production; dev and staging will have their own gateway definitions
- Each new gateway will have its own CloudWatch log groups and WAF associations

## Capabilities

### New Capabilities

- `dev-api-gateway`: Dedicated API Gateway for dev environment with independent configuration
- `staging-api-gateway`: Dedicated API Gateway for staging environment with independent configuration

### Unchanged Capabilities

- `prod-api-gateway`: Production continues using the existing shared API Gateway with no changes to its configuration

### Modified Capabilities

- `api-gateway-shared`: The shared gateway configuration remains in place for production use only

## Impact

- Files affected: `ror/services/api/api_gateway_dev.tf`, `ror/services/api/api_gateway_staging.tf` (new full gateway definitions)
- Production files (api_gateway_prod.tf, api_gateway_shared.tf) remain unchanged
- DNS/routing: Dev and staging custom domains will point to their respective new gateways
- WAF associations: New gateways will have their own WAF web ACL associations
- CloudWatch logs: Separate log groups for dev and staging gateways
- Terraform state: New resources created for dev and staging; production remains on existing shared gateway