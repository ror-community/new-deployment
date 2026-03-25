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

## 3. Verify and Deploy

- [ ] 3.1 Run `terraform plan` to verify new gateway resources are created correctly
- [ ] 3.2 Run `terraform apply` in dev environment
- [ ] 3.3 Test dev gateway endpoints (heartbeat, organizations)
- [ ] 3.4 Run `terraform apply` in staging environment
- [ ] 3.5 Test staging gateway endpoints
- [ ] 3.6 Verify production resources remain unchanged (`terraform plan` shows no changes to prod)
- [ ] 3.7 Update dev/staging DNS to point to new gateways (if applicable)
- [ ] 3.8 Clean up old dev/staging stage files after migration is confirmed working

## Notes

- Production API Gateway (`api_gateway_shared.tf`, `api_gateway_prod.tf`) remains unchanged
- No changes to production WAF associations or CloudWatch logs
- Dev and staging gateways are independent and can be modified without affecting each other orproduction