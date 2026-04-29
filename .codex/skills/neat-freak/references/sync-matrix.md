# Documentation Sync Matrix

Use this matrix when it is unclear which documentation surfaces should change.

## Code Changes to Documentation Changes

| Change | Documentation surfaces |
|---|---|
| New API, route, or protocol | Project agent instructions, integration guide or usage docs, architecture docs |
| Renamed API, route, or protocol | Same as new API, plus search and replace stale names |
| New or renamed environment variable | Project agent instructions, operator runbook, downstream setup docs |
| New database table or schema | Project agent instructions, architecture data model |
| New user flow | README usage, architecture flow notes, handoff or changelog if present |
| Major feature across multiple files | README, architecture, integration or usage docs, runbook, handoff or changelog |
| Terminology change | Glossary or integration docs if present, plus global stale-term search |
| Deployment or infrastructure change | Operator runbook, project agent instructions, README setup when relevant |
| SDK or downstream integration change | Producer integration docs and consumer project docs |

## Memory and Instruction Changes

| Situation | Action |
|---|---|
| Stale fact | Replace or delete the old fact |
| Relative time phrase | Convert to an absolute date |
| Duplicate memories | Merge into one clear note |
| Completed temporary task | Delete it |
| Reversed decision | Remove the old decision and keep the current one |
| One-off context | Delete it unless it still affects future work |

## Cross-Project Checks

Search dependent projects whenever the change involves:

- shared protocols
- SDKs
- public routes or subdomains
- environment variables
- authentication or authorization flows
- shared infrastructure

The producer and consumer documentation must agree.

## Standard Documentation Shape

For a new capability, update these surfaces when they exist:

1. Usage or integration docs: how to use it.
2. Architecture docs: how it works.
3. Runbook docs: how to operate or debug it.
4. Handoff or changelog docs: what changed.

Keep high-frequency references such as API tables, environment-variable tables,
and terminology lists current.
