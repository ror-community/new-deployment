## Context

Currently, the ROR API uses a single shared AWS API Gateway REST API (`ror-api`) with three stages (dev, staging, prod) defined in `api_gateway_shared.tf`. All environments share:
- One REST API resource with identical endpoint definitions
- One deployment that triggers for all stages
- Shared method configurations (resources, methods, integrations, CORS)

This architecture creates tight coupling: any change to gateway configuration requires a new deployment that affects all stages, making it risky to test changes in dev without potential production impact.

## Goals / Non-Goals

**Goals:**
- Create three independent API Gateway REST APIs (dev, staging, prod)
- Each gateway has its own deployment and can be modified independently
- Maintain identical endpoint configurations across all gateways initially
- Preserve all existing functionality (endpoints, caching, WAF, logging)

**Non-Goals:**
- Refactoring or optimizing the gateway configuration (future work)
- Changing the endpoint structure or behavior
- Modifying DNS or custom domain configurations (handled separately)

## Decisions

### Decision 1: Create separate gateway files per environment

**Choice:** Three independent `api_gateway_<env>.tf` files, each containing a complete REST API definition

**Rationale:**
- Clear ownership: each environment's gateway is in its own file
- Independent deployments: changes to dev don't require touching prod files
- Future flexibility: each gateway can evolve independently

**Alternatives considered:**
- Single file with `for_each` or `count`: harder to reason about, less clear ownership
- Modules with per-environment instantiation: adds abstraction complexity; defer to future refactoring

### Decision 2: Copy shared configuration into each environment file

**Choice:** Duplicate the complete gateway definition (resources, methods, integrations, CORS) in each environment file

**Rationale:**
- Initial implementation simplicity
- Each environment can diverge over time
- No shared state that could cause cross-environment issues

**Alternatives considered:**
- Terraform module for shared logic: good for maintenance but adds complexity for initial migration
- Keep shared file for common definitions: defeats the purpose of separation

### Decision 3: Remove the shared gateway after migration

**Choice:** After creating separate gateways, remove `api_gateway_shared.tf` and update stage files to reference new gateway resources

**Rationale:**
- Clean state without orphaned resources
- Prevents confusion about which gateway is active
- Terraform will handle resource lifecycle

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Code duplication increases maintenance burden | Accept for now; refactor into module later |
| Larger Terraform state with 3x gateway resources | Accept; AWS API Gateway limits are not a concern |
| Migration requires creating new resources before destroying old | Use `create_before_destroy` lifecycle; stage migration carefully |
| Custom domain/ACM certificate associations need updating | Verify DNS and certificate configurations per environment before cutover |

## Migration Plan

1. **Create new gateway files**: Add `api_gateway_dev_full.tf`, `api_gateway_staging_full.tf`, `api_gateway_prod_full.tf` with complete gateway definitions
2. **Create deployments and stages**: Each gateway gets its own deployment resource pointing to environment-specific backend
3. **Update WAF associations**: Point each gateway's stage(s) to environment-specific WAF web ACLs
4. **Test in dev first**: Verify dev gateway works end-to-end before promoting
5. **Migrate staging then prod**: Apply changes sequentially
6. **Remove shared gateway**: Delete `api_gateway_shared.tf` after migration complete
7. **Clean up old stage files**: Remove `api_gateway_dev.tf`, `api_gateway_staging.tf`, `api_gateway_prod.tf` as their content is now in the full gateway files

## Open Questions

- Should we preserve the original stage-based approach as a fallback? (Recommend: no, clean migration)
- How to handle the transition period when both gateways exist? (Recommend: use different names, test new gateway, then switch DNS)