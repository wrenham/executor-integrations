# Migadu admin API

Vendor docs: https://migadu.com/api/ (no vendor OpenAPI spec — `openapi.yaml` is hand-written).

## Executor setup

- Type: OpenAPI, namespace `migadu`, health check `domains.listDomains`.
- Auth: HTTP Basic. Executor's credential field takes the value after `Basic `, i.e.
  `base64("<migadu account email>:<api key>")`. API keys: Migadu → My Account → API Keys.

## Deviations from the vendor docs (verified 2026-09-23)

- List endpoints return a wrapping object, not a bare array:
  `{domains}`, `{mailboxes}`, `{identities}`, `{forwardings}`, `{address_aliases}`, `{rewrites}`.
- Domain objects include `greylisting_enabled`.
- Mailbox objects include `is_active`, `activated_at`, `changed_at`, `storage_usage`,
  `forwardings`, and daily/weekly/monthly incoming/outgoing limits.

## Cautions for agents

- `activateDomain` is a GET that changes state.
- `deleteMailbox` removes all mail irreversibly; `updateMailbox` can reset a password.
  Consider disabling these tools in Executor until write access is deliberately granted.
