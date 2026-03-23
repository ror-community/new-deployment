## ADDED Requirements

### Requirement: Staging API Gateway REST API
The system SHALL provide a dedicated API Gateway REST API for the staging environment named `ror-api-staging` with independent configuration from dev and production.

#### Scenario: Staging gateway exists as independent resource
- **WHEN** Terraform applies the staging gateway configuration
- **THEN** a new `aws_api_gateway_rest_api` resource `ror-api-staging` is created

#### Scenario: Staging gateway has complete endpoint definitions
- **WHEN** the staging gateway is created
- **THEN** all endpoints (v1/*, v2/*, organizations, heartbeat, generateid) are defined identically to the original shared gateway

### Requirement: Staging API Gateway Deployment
The system SHALL create an independent deployment for the staging API Gateway.

#### Scenario: Staging deployment is created
- **WHEN** the staging gateway resources are defined
- **THEN** an `aws_api_gateway_deployment` resource is created for `ror-api-staging`

#### Scenario: Staging deployment triggers on gateway changes
- **WHEN** any endpoint configuration changes in the staging gateway
- **THEN** a new deployment is created without affecting dev or prod gateways

### Requirement: Staging API Gateway Stage
The system SHALL configure a default stage for the staging gateway.

#### Scenario: Staging stage is created
- **WHEN** the staging deployment is created
- **THEN** a stage is configured with caching enabled and backend host pointing to staging ALB

### Requirement: Staging API Gateway WAF Association
The system SHALL associate the existing `waf-staging-v2` web ACL with the staging gateway stage.

Note: The WAF web ACL `waf-staging-v2` already exists (defined in `ror/vpc/wafv2.tf`) and is referenced via a data source. No new WAF resources are created.

#### Scenario: Staging WAF association points to new gateway stage
- **WHEN** the staging gateway stage is created
- **THEN** the `aws_wafv2_web_acl_association` resource references the new staging gateway stage ARN
- **AND** the association uses the existing `data.aws_wafv2_web_acl.staging-v2` web ACL

### Requirement: Staging API Gateway CloudWatch Logging
The system SHALL configure CloudWatch access logging for the staging gateway.

#### Scenario: Staging access logging is enabled
- **WHEN** the staging stage is created
- **THEN** access logs are sent to a staging-specific CloudWatch log group