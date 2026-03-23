## ADDED Requirements

### Requirement: Dev API Gateway REST API
The system SHALL provide a dedicated API Gateway REST API for the dev environment named `ror-api-dev` with independent configuration from staging and production.

#### Scenario: Dev gateway exists as independent resource
- **WHEN** Terraform applies the dev gateway configuration
- **THEN** a new `aws_api_gateway_rest_api` resource `ror-api-dev` is created

#### Scenario: Dev gateway has complete endpoint definitions
- **WHEN** the dev gateway is created
- **THEN** all endpoints (v1/*, v2/*, organizations, heartbeat, generateid) are defined identically to the original shared gateway

### Requirement: Dev API Gateway Deployment
The system SHALL create an independent deployment for the dev API Gateway.

#### Scenario: Dev deployment is created
- **WHEN** the dev gateway resources are defined
- **THEN** an `aws_api_gateway_deployment` resource is created for `ror-api-dev`

#### Scenario: Dev deployment triggers on gateway changes
- **WHEN** any endpoint configuration changes in the dev gateway
- **THEN** a new deployment is created without affecting staging or prod gateways

### Requirement: Dev API Gateway Stage
The system SHALL configure a default stage for the dev gateway.

#### Scenario: Dev stage is created
- **WHEN** the dev deployment is created
- **THEN** a stage is configured with caching enabled and backend host pointing to dev ALB

### Requirement: Dev API Gateway WAF Association
The system SHALL associate the existing `waf-dev-v2` web ACL with the dev gateway stage.

Note: The WAF web ACL `waf-dev-v2` already exists (defined in `ror/vpc/wafv2.tf`) and is referenced via a data source. No new WAF resources are created.

#### Scenario: Dev WAF association points to new gateway stage
- **WHEN** the dev gateway stage is created
- **THEN** the `aws_wafv2_web_acl_association` resource references the new dev gateway stage ARN
- **AND** the association uses the existing `data.aws_wafv2_web_acl.dev-v2` web ACL

### Requirement: Dev API Gateway CloudWatch Logging
The system SHALL configure CloudWatch access logging for the dev gateway.

#### Scenario: Dev access logging is enabled
- **WHEN** the dev stage is created
- **THEN** access logs are sent to a dev-specific CloudWatch log group