## Why

Currently, all three environments (dev, staging, prod) share a single API Gateway REST API with separate stages. This tight coupling makes it difficult to introduce changes in dev without risking unintended impacts to staging or production. Any modification to the gateway configuration requires a deployment that affects all stages.

## What Changes

- Split the single shared API Gateway REST API into three separate REST APIs, one per environment
- Each environment will have its own `aws_api_gateway_rest_api` resource with independent deployments
- The shared configuration file will be replaced with environment-specific gateway definitions
- Each gateway will have its own CloudWatch log groups and WAF associations

## Capabilities

### New Capabilities

- `dev-api-gateway`: Dedicated API Gateway for dev environment with independent configuration
- `staging-api-gateway`: Dedicated API Gateway for staging environment with independent configuration
- `prod-api-gateway`: Dedicated API Gateway for production environment with independent configuration

### Modified Capabilities

- `api-gateway-shared`: The shared gateway configuration will be removed and replaced with environment-specific copies

## Impact

- Files affected: `ror/services/api/api_gateway_shared.tf`, `ror/services/api/api_gateway_dev.tf`, `ror/services/api/api_gateway_staging.tf`, `ror/services/api/api_gateway_prod.tf`
- DNS/routing: Each environment's custom domain will need to point to its respective gateway
- WAF associations: Each gateway will need its own WAF web ACL association
- CloudWatch logs: Separate log groups per gateway
- Terraform state: New resources will be created; existing shared gateway will be deprecated