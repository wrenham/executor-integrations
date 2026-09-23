# executor-integrations

Source of truth for Wrenham Ltd's [Executor](https://executor.sh/wrenham-ltd) integrations.
One folder per provider. Executor reads each spec by its raw GitHub URL, so a fix
is a commit here followed by **Refresh** on the integration in Executor.

## Layout

```
<provider>/
  openapi.yaml   # hand-written or vendor OpenAPI 3 spec (for OpenAPI integrations)
  README.md      # auth, quirks, what the vendor docs get wrong, tools to disable
```

MCP-based integrations (first-party or hosted FastMCP) need no spec; their
`README.md` records the server URL, headers and which tools are enabled.

## Providers

| Folder | Type | Notes |
|---|---|---|
| `migadu/` | OpenAPI | Migadu admin API — domains, mailboxes, identities, forwardings, aliases, rewrites |

## Conventions

- Namespace in Executor = folder name (`migadu`, `freeagent`, ...).
- Credentials never live here; they are entered in Executor (and kept in Vaultwarden).
- Prefer the vendor's own spec when one exists; hand-write only when it doesn't.
- Record live-API deviations from vendor docs in the provider README and fix the spec.
