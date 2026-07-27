---
type: project-spec
source: hermes-hackathon
difficulty: medium
category: conversational commerce
form_factor:
  - WhatsApp catalog bot
  - local merchant dashboard
deployment: local-first simulator with optional WhatsApp webhook
scope_expansion: "[[Scope Expansion Checklist]]"
research_dossier: "[[Research - Hermes Batch C#29. WhatsApp Catalog Bot for Small Stores]]"
status: concept
tags:
  - whatsapp
  - catalog
  - small-business
---

# WhatsApp Catalog Bot for Small Stores

> A small-store assistant that answers only from a merchant-controlled catalog, asks the minimum order questions, and hands a complete order request to a person for confirmation.

## Product Outcome

Let a shop handle repetitive product, price, availability, and delivery questions without inventing stock or creating an unreliable checkout system. The canonical output is a merchant-reviewed order request, not an autonomous financial transaction.

## User and Core Workflow

1. Merchant imports a clean catalog sheet with SKU, variants, price, stock state, description, media, service area, and policy.
2. The system validates missing/duplicate fields and builds exact plus semantic search.
3. Customer asks a question in WhatsApp, Telegram, or the local simulator.
4. Bot identifies intent, retrieves relevant SKUs/policies, answers with catalog timestamps, and asks for variant/quantity.
5. Cart/order request is summarized with customer confirmation.
6. Merchant receives an approval queue, corrects stock/delivery, and confirms manually.
7. Conversation outcome updates FAQ gaps and catalog-cleanup tasks.

## Demo/Personal V0

Use a synthetic 50-SKU CSV and local chat simulator. Support search, comparison, variants, cart summary, service-area check, and merchant handoff. Test unknown products, stale stock, ambiguity, opt-out, and adversarial prompts. No live messages or payments.

## Build Boundary

- In scope: merchant-owned catalog ingestion, retrieval, policy answers, cart/request capture, human handoff, and conversation audit.
- Out of scope: open-web product facts, payment collection, autonomous discounts/refunds, exact stock claims without a fresh source, or placing orders without customer and merchant confirmation.
- Never expose other customers’ conversations or use chat content for unrelated training.
- Hard-code opt-out and human-request recognition outside the model.

## Existing Products, Building Blocks, and Shortcuts

- [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api/) is the official future channel and documents webhooks, messages, and templates.
- [Telegram Bot API](https://core.telegram.org/bots) enables a lower-friction live pilot before WhatsApp business onboarding.
- [Google Sheets API](https://developers.google.com/sheets/api) lets many merchants keep using a familiar catalog editor.
- [Shopify Admin GraphQL API](https://shopify.dev/docs/api/admin-graphql) can become a richer authorized catalog/inventory adapter.
- [Qdrant quickstart](https://qdrant.tech/documentation/quickstart/) is available for filtered semantic retrieval, though SQLite FTS is enough for V0.

## Recommended Free-First Stack

- Python, FastAPI, Pydantic, SQLite/FTS5, and a minimal HTMX merchant dashboard.
- Polars for sheet validation and versioned imports.
- Local embeddings for fuzzy product queries; deterministic SKU, price, stock, service-area, and policy resolution.
- Local LLM for intent and natural phrasing, receiving only retrieved catalog rows and constrained actions.
- A channel adapter interface with local simulator first, Telegram second, and WhatsApp only after onboarding.

Deterministic commerce state plus model-assisted language sharply reduces hallucinated prices and stock.

## Architecture/Data Model

`merchant` owns `catalog_version`, `product`, `variant`, `inventory_observation`, `policy`, `customer_session`, `message`, `retrieval`, `cart`, `order_request`, `merchant_decision`, `handoff`, and `audit_event`. Every answer records the catalog/policy version and retrieved rows. Idempotency keys prevent duplicate order requests from webhook retries.

## Build Slices

1. CSV importer, validation report, catalog browser, and exact/fuzzy search.
2. Local conversation state machine for questions, variants, cart, and confirmation.
3. Grounded response generation, unknown-answer behavior, and human handoff.
4. Merchant approval queue, stale-stock warnings, audit, and analytics.
5. Google Sheets/Shopify adapter, Telegram pilot, then WhatsApp webhook.

## Drawbacks, Concerns, and Failure Modes

- Small-store catalogs are often incomplete, duplicated, or not updated.
- Conversational quantities and variants are ambiguous across languages.
- Webhook retries can create duplicate messages and orders.
- Customers may treat the bot’s response as a binding stock, price, or delivery promise.
- Messaging templates, consent, rate limits, and commerce policies add operational overhead.

## Clever Hacks and Simpler Alternative

- Start with “in stock / ask store / unavailable” rather than fake precise quantities.
- Add an automatic catalog-health report before enabling chat.
- Use quick-reply buttons for variants and quantities after natural-language discovery.
- Always include a concise cart and policy recap before confirmation.
- Simplest alternative: searchable mobile catalog plus a prefilled WhatsApp order message, with no conversational agent.

## Success Measures

- Price and SKU answers exactly match the active catalog fixture.
- Unknown/stale stock reliably routes to the merchant instead of guessing.
- No duplicate order request is created under webhook replay tests.
- Customers can reach a human or opt out in one step.
- Merchant review time and repeated-question volume decline without increased correction rate.

## Product Path

Build for one friendly shop with CSV and local simulation, then pilot Telegram and WhatsApp. Paid versions could add multi-location inventory, staff roles, multilingual catalogs, CRM/commerce sync, analytics, and order-status flows. Production requires messaging-provider approval, consumer/privacy rules, tenant isolation, and payment/commercial terms if checkout is added.

## Related

- [[Website in a WhatsApp]]
- [[Winback Agency]]
- [[Clinic Missed-Call Follow-Up Bot]]
