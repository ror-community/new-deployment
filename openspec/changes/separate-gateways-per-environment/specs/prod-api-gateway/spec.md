## UNCHANGED Requirements

### Requirement: Prod API Gateway REST API
The production environment SHALL continue using the existing shared API Gateway REST API without any changes.

#### Scenario: Prod gateway remains on shared infrastructure
- **WHEN** Terraform applies changes for this feature
- **THEN** the production API Gateway resources are not modified
- **AND** the production stage continues to use the existing `ror-api` shared gateway

#### Scenario: Prod gateway endpoints unchanged
- **WHEN** the feature is deployed
- **THEN** all production endpoints continue to function exactly as before
- **AND** no changes to production DNS, custom domains, or WAFassociations

### Requirement: No Production Terraform Changes
The system SHALL NOT make any Terraform changes that affect production resources.

#### Scenario: Terraform plan shows no production changes
- **WHEN** running `terraform plan` for this feature
- **THEN** no changes are shown to production API Gateway resources
- **AND** production infrastructure remains stable

### Rationale

Production stability is paramount. By keeping the existing shared gateway for production:
- Zero risk of production outageduring migration
- No need to update production DNS or SSL certificates
- Production team can plan their own migration separately if desired
- Changes are isolated to non-production environments