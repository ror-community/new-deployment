## ADDED Requirements

### Requirement: Prod API Gateway REST API
The system SHALL provide a dedicated API Gateway REST API for the production environment named `ror-api-prod` with independent configuration from dev and staging.

#### Scenario: Prod gateway exists as independent resource
- **WHEN** Terraform applies the prod gateway configuration
- **THEN** a new `aws_api_gateway_rest_api` resource `ror-api-prod` is created

#### Scenario: Prod gateway has complete endpoint definitions
- **WHEN** the prod gateway is created
- **THEN** all endpoints (v1/*, v2/*, organizations, heartbeat, generateid) are defined identically to the original shared gateway

### Requirement: Prod API Gateway Deployment
The system SHALL create an independent deployment for the prod API Gateway.

#### Scenario: Prod deployment is created
- **WHEN** the prod gateway resources are defined
- **THEN** an `aws_api_gateway_deployment` resource is created for `ror-api-prod`

#### Scenario: Prod deployment triggers on gateway changes
- **WHEN** any endpoint configuration changes in the prod gateway
- **THEN** a new deployment is created without affecting dev or staging gateways

### Requirement: Prod API Gateway Stage
The system SHALL configure a default stage for the prod gateway.

#### Scenario: Prod stage is created
- **WHEN** the prod deployment is created
- **THEN** a stage is configured with caching enabled and backend host pointing to prod ALB

### Requirement: Prod API Gateway WAF Association
The system SHALL associate the existing `waf-prod-v2` web ACL with the prod gateway stage.

Note: The WAF web ACL `waf-prod-v2` already exists (defined in `ror/vpc/wafv2.tf`) and is referenced via a data source. No new WAF resources are created.

#### Scenario: Prod WAF association points to new gateway stage
- **WHEN** the prod gateway stage is created
- **THEN** the `aws_wafv2_web_acl_association` resource references the new prod gateway stage ARN
- **AND** the association uses the existing `data.aws_wafv2_web_acl.prod-v2` web ACL

### Requirement: Prod API Gateway CloudWatch Logging
The system SHALL configure CloudWatch access logging for the prod gateway.

#### Scenario: Prod access logging is enabled
- **WHEN** the prod stage is created
- **THEN** access logs are sent to a prod-specific CloudWatch log group