# FreeAgent API

Vendor docs: https://dev.freeagent.com/docs (no complete vendor OpenAPI spec — `openapi.yaml`
is hand-written and covers the bookkeeping surface only).

Two files, generated from one source:

| File | Namespace | Base URL | OAuth endpoints |
|---|---|---|---|
| `openapi.yaml` | `freeagent` | `https://api.freeagent.com/v2` | `api.freeagent.com` |
| `openapi.sandbox.yaml` | `freeagent_sandbox` | `https://api.sandbox.freeagent.com/v2` | `api.sandbox.freeagent.com` |

Edit `openapi.yaml` only, then regenerate the sandbox copy with `./sandbox.sh`.
Executor needs separate integrations for the two environments because the OAuth
URLs live in the spec.

## Executor setup

- Type: OpenAPI, spec = raw GitHub URL of the file above, health check `users.getCurrentUser`.
- Auth: OAuth 2.0 authorisation code, no scopes. Executor reads the flow from the
  spec; paste the app's **OAuth identifier** (client id) and **OAuth secret** from
  https://dev.freeagent.com → My Apps → *Executor*. Registered redirect URI:
  `https://executor.sh/api/oauth/callback`.
- One **connection per FreeAgent company**. The company is fixed at authorisation time
  (log in as a user of that company), so client stores each get their own connection
  named after the store. Access tokens last ~7 days; refresh tokens don't expire.
- Dev-dashboard apps work against the sandbox out of the box. Production API access is
  enabled per app from the dashboard — check the app page before creating the first
  production connection.

## API conventions worth knowing

- Everything is referenced by full URL (`contact`, `category`, `bank_account`, ...), never
  a bare id. `{id}` path parameters are the last segment of that URL.
- List responses wrap the array (`{bank_transactions: [...]}`); `page`/`per_page` (max 100),
  `Link: <...>; rel="next"` for more. `updated_since` is the cheap sync filter.
- Money values are strings. Explanation `gross_value` is signed: negative = money out.
- `listBankTransactions` requires `bank_account`; `view=unexplained` is the reconciliation queue.
- `createBankTransactionExplanation` takes exactly one of `category`, `paid_invoice`,
  `paid_bill`, `transfer_bank_account`, `paid_user`.
- `uploadStatement` de-duplicates on `fitid` — always send one (Wise/Revolut transaction ids).
- Rate limit 120/min and 3600/hour per app per user (429 + Retry-After). Fan out across
  company connections sequentially.
- A `User-Agent` header is mandatory; Executor sets its own.

## Calling from `execute`

Executor wraps arguments: query/path parameters are top-level, request bodies go under `body`.

```ts
tools.freeagent.org.wrenham.bankTransactions.listBankTransactions({ bank_account, view: "unexplained" })
tools.freeagent.org.wrenham.contacts.createContact({ body: { contact: { organisation_name: "..." } } })
```

## Connections (Sept 2026)

`freeagent_sandbox`: `freeagentSandboxAppExecutor` (Test Stores).
`freeagent`: `wrenham` (Wrenham Ltd), `wiltshire`, `burlock`, `deadmor`, `fasola`, `lacquan`, `markroberts`,
`matlock`, `namcotravel` (Namco Travel Ltd), `newforest`, `shadwell`, `verwood`, `winston`.
All owner `org`; address `tools.freeagent.org.<name>.<group>.<tool>`. Enumerate with
`tools.executor.coreTools.connections.list({})` and filter `integration === "freeagent"`.

## Deviations from the vendor docs

None recorded yet — first live verification pending (sandbox, Sept 2026).

## Cautions for agents

Read tools: allow. Everything below changes the books and should sit behind approval
until deliberately released, per connection:

- `createBankTransactionExplanation`, `updateBankTransactionExplanation`, `uploadStatement`,
  `createJournalSet`, `createBill`, `updateBill`, `createExpense` — post to the ledger.
- `markInvoiceAsSent`, `sendInvoiceEmail`, `markInvoiceAsCancelled` — customer-facing.
- All `delete*` tools are irreversible; consider disabling them outright.
