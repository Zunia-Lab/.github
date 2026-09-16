# Zunia Lab workspace

Local workspace for the [Zunia Lab](https://github.com/Zunia-Lab) organization.

**Product:** Multi-chain Cosmos wallet (browser extension + mobile + web).  
**Domain:** [zunialab.com](https://zunialab.com) · **Email:** hello@zunialab.com · **Security:** security@zunialab.com

## Repositories

| Directory | GitHub (after push) | Purpose |
|-----------|---------------------|---------|
| `.github/` | `Zunia-Lab/.github` | Org profile + community health |
| `zunia-brand/` | `Zunia-Lab/zunia-brand` | Logos and brand guidelines |
| `zunia-ui/` | `Zunia-Lab/zunia-ui` | Shared UI + Flutter tokens |
| `zunia-chain-registry/` | `Zunia-Lab/zunia-chain-registry` | Fork of Keplr chain registry |
| `zunia-docs/` | `Zunia-Lab/zunia-docs` | Docusaurus docs |
| `zunia-website/` | `Zunia-Lab/zunia-website` | Marketing site |
| `zunia-extension/` | `Zunia-Lab/zunia-extension` | Browser extension (WXT) |
| `zunia-mobile/` | `Zunia-Lab/zunia-mobile` | Mobile wallet (Flutter, iOS + Android) |
| `zunia-dashboard/` | `Zunia-Lab/zunia-dashboard` | Web portfolio |
| `zunia-sdk/` | `Zunia-Lab/zunia-sdk` | Developer SDKs (web, React, Flutter) |
| `zunia-core/` | `Zunia-Lab/zunia-core` | Wallet kernel (scaffold) |
| `zunia-backend/` | `Zunia-Lab/zunia-backend` | API / notifications (scaffold) |
| `zunia-indexer/` | `Zunia-Lab/zunia-indexer` | Indexer vendor decision + config |
| `zunia-e2e/` | `Zunia-Lab/zunia-e2e` | Playwright + Maestro harness |
| `zunia-infra/` | `Zunia-Lab/zunia-infra` | Pulumi / infra scaffold |
| `zunia-security/` | `Zunia-Lab/zunia-security` | **Private** threat model / audits |

Pre-development gate: [PRE-DEVELOPMENT.md](./PRE-DEVELOPMENT.md).

## Design sources

- `zunia-brand-assets/` — original brand pack (also published as `zunia-brand`)
- `Design output formats/` — HTML design mockups

## Setup

1. Org: [github.com/Zunia-Lab](https://github.com/Zunia-Lab) (already created).
2. Run `./scripts/setup-org.sh` then `./scripts/push-all-repos.sh` to sync remotes.
3. Create `zunia-security` as a **private** repo manually.
4. Follow [DEPLOY.md](./DEPLOY.md) for DNS, email, and Vercel.
5. Upload org logo at [org settings](https://github.com/organizations/Zunia-Lab/settings/profile).

## Contact

hello@zunialab.com · security@zunialab.com
