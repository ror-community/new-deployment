# ROR API Terraform (legacy root)

This directory is the **old** combined root. It is retired.

Terraform Cloud workspace: `ror/ror-services-api`. It is CLI-driven, locked, and in the Archive project. Leftover state is 29 data sources only. **Do not apply.** The `.tf` files here still declare every migrated resource; an apply would try to create them again.

Live ownership is under `environments/`:

| Directory | Workspace |
|---|---|
| `environments/shared` | `ror/ror-services-api-shared` |
| `environments/dev` | `ror/ror-services-api-dev` |
| `environments/staging` | `ror/ror-services-api-staging` |
| `environments/prod` | `ror/ror-services-api-prod` |

A change in this parent directory must not queue those workspaces.
