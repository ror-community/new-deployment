## Context

Currently, the ROR API uses a single shared AWS API Gateway REST API (`ror-api`) with three stages (dev, staging, prod) defined in `api_gateway_shared.tf`. All environments share:
- One REST API resource with identical endpoint definitions
- One deployment that triggers for all stages
- Shared method configurations (resources, methods, integrations, CORS)

This architecture creates tight coupling: any change to gateway configuration requires a new deployment that affects all stages, making it risky to test changes in dev without potential production impact.

## Goals / Non-Goals

**Goals:**
- Create two independent API Gateway REST APIs (dev, staging) separate from production
- Each new gateway has its own deployment and can be modified independently
- Production environment remains completely unchanged - no risk of disruption
- Maintain identical endpoint configurations on new gateways initially
- Preserve all existing functionality for all environments

**Non-Goals:**
- Making any changes to production API Gateway resources
- Refactoring or optimizing the gateway configuration (future work)
- Changing the endpoint structure or behavior
- Modifying DNS or custom domain configurations for production (handled separately)

## Decisions

### Decision 1: Create separate gateway files for dev and staging only

**Choice:** Two new `api_gateway_<env>_full.tf` files (dev and staging), each containing a complete REST API definition. Production continues using the existing shared gateway.

**Rationale:**
- Zero risk to production - no Terraform changes affecting prod resources
- Clear ownership: dev and staging gateways are in their own files
- Independent deployments: changes to dev/staging don't affect production
- Future flexibility: dev/staging gateways can evolve independently

**Alternatives considered:**
- Create separate gateways for all three environments: introduces risk to production
- Keep shared gateway for all: doesn't solve the coupling problem for dev/staging

### Decision 2: Copy shared configuration into dev and staging files

**Choice:** Duplicate the complete gateway definition (resources, methods, integrations, CORS) in dev and staging environment files

**Rationale:**
- Initial implementation simplicity
- Each environment can diverge over time
- No shared state that could cause cross-environment issues
- Production remains on stable shared gateway

**Alternatives considered:**
- Terraform module for shared logic: good for maintenance but adds complexity for initial migration
- Keep shared file for common definitions: defeats the purpose of separation for dev/staging

### Decision 3: Keep shared gateway for production

**Choice:** The existing `api_gateway_shared.tf` and `api_gateway_prod.tf` files remain unchanged. Production continues to use the shared API Gateway with the prod stage.

**Rationale:**
- Zero risk to production traffic
- No need to migrate production DNS or custom domains
- Production team can plan their own migration when ready
- Changes are isolated to non-production environments

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Code duplication increases maintenance burden for dev/staging | Accept for now; refactor into module later |
| Larger Terraform state with additional gateway resources | Accept; AWS API Gateway limits are not a concern |
| Dev/staging gateways need separate management | Clear ownership: dev/staging teams manage their own gateways |
| Production still shares gateway with no isolation | Production can be migrated separately in future phase |
| Custom domain/ACM certificate associations for dev/staging | Verify DNS and certificate configurations per environment |

## Migration Plan

1. **Create dev gateway file**: Add `api_gateway_dev_full.tf` with complete gateway definition
2. **Create dev deployment and stage**: Point to dev ALB backend
3. **Create staging gateway file**: Add `api_gateway_staging_full.tf` with complete gateway definition
4. **Create staging deployment and stage**: Point to staging ALB backend
5. **Update WAF associations**: Create new WAF associations for dev and staging gateway stages
6. **Update DNS for dev/staging**: Point dev.staging custom domains to new gateways
7. **Test dev first**: Verify dev gateway works end-to-end
8. **Test staging**: Verify staging gateway works end-to-end
9. **Production unchanged**: No changes to production resources

## Open Questions

- Should production be migrated later? (Defer decision to production team)
- How to handle the transition period for dev/staging DNS? (Recommend: use different gateway names, test, then switch DNS)