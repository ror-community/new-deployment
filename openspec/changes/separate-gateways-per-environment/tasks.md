## 1. Create Dev API Gateway

- [ ] 1.1 Create `ror/services/api/api_gateway_dev_full.tf` with `aws_api_gateway_rest_api` resource named `ror-api-dev`
- [ ] 1.2 Add all endpoint resources (v1, v2, organizations, heartbeat, generateid) to dev gateway
- [ ] 1.3 Add all methods (GET, POST, ANY, OPTIONS) for each endpoint to dev gateway
- [ ] 1.4 Add all method responses and integrations to dev gateway
- [ ] 1.5 Add all integration responses (including CORS) to dev gateway
- [ ] 1.6 Create dev-specific CloudWatch log group for access logs
- [ ] 1.7 Create dev deployment resource (`aws_api_gateway_deployment`) with `create_before_destroy` lifecycle
- [ ] 1.8 Create dev stage with caching and backend host variables
- [ ] 1.9 Add all method settings (caching configuration) for dev stage
- [ ] 1.10 Associate dev WAF web ACL with dev gateway stage

## 2. Create Staging API Gateway

- [ ] 2.1 Create `ror/services/api/api_gateway_staging_full.tf` with `aws_api_gateway_rest_api` resource named `ror-api-staging`
- [ ] 2.2 Add all endpoint resources (v1, v2, organizations, heartbeat, generateid) to staging gateway
- [ ] 2.3 Add all methods (GET, POST, ANY, OPTIONS) for each endpoint to staging gateway
- [ ] 2.4 Add all method responses and integrations to staging gateway
- [ ] 2.5 Add all integration responses (including CORS) to staging gateway
- [ ] 2.6 Create staging-specific CloudWatch log group for access logs
- [ ] 2.7 Create staging deployment resource (`aws_api_gateway_deployment`) with `create_before_destroy` lifecycle
- [ ] 2.8 Create staging stage with caching and backend host variables
- [ ] 2.9 Add all method settings (caching configuration) for staging stage
- [ ] 2.10 Associate staging WAF web ACL with staging gateway stage

## 3. Create Prod API Gateway

- [ ] 3.1 Create `ror/services/api/api_gateway_prod_full.tf` with `aws_api_gateway_rest_api` resource named `ror-api-prod`
- [ ] 3.2 Add all endpoint resources (v1, v2, organizations, heartbeat, generateid) to prod gateway
- [ ] 3.3 Add all methods (GET, POST, ANY, OPTIONS) for each endpoint to prod gateway
- [ ] 3.4 Add all method responses and integrations to prod gateway
- [ ] 3.5 Add all integration responses (including CORS) to prod gateway
- [ ] 3.6 Create prod-specific CloudWatch log group for access logs
- [ ] 3.7 Create prod deployment resource (`aws_api_gateway_deployment`) with `create_before_destroy` lifecycle
- [ ] 3.8 Create prod stage with caching and backend host variables
- [ ] 3.9 Add all method settings (caching configuration) for prod stage
- [ ] 3.10 Associate prod WAF web ACL with prod gateway stage

## 4. Verify and Clean Up

- [ ] 4.1 Run `terraform plan` to verify new gateway resources are created correctly
- [ ] 4.2 Run `terraform apply` in dev environment first
- [ ] 4.3 Test dev gateway endpoints (heartbeat, organizations)
- [ ] 4.4 Run `terraform apply` in staging environment
- [ ] 4.5 Test staging gateway endpoints
- [ ] 4.6 Run `terraform apply` in prod environment
- [ ] 4.7 Test prod gateway endpoints
- [ ] 4.8 Remove old `api_gateway_shared.tf` file
- [ ] 4.9 Remove old `api_gateway_dev.tf`, `api_gateway_staging.tf`, `api_gateway_prod.tf` files
- [ ] 4.10 Run `terraform plan` to confirm clean state with no unexpected changes