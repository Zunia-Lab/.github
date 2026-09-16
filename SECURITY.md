# Security Policy

## Supported versions

| Product | Supported |
|---------|-----------|
| zunia-extension | Latest release on Chrome Web Store (when published) |
| zunia-mobile | Latest release on App Store / Play Store (when published) |
| zunia-chain-registry | `main` branch |
| zunia-core | Tagged releases (when published) |
| zunia-backend | Production API (when deployed) |

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Email [security@zunialab.com](mailto:security@zunialab.com) with:

- Description of the vulnerability
- Steps to reproduce
- Impact assessment
- Affected repository and version
- Your contact information (optional, for follow-up)

PGP key URL will be listed in `https://zunialab.com/.well-known/security.txt` when issued.

We aim to acknowledge reports within 72 hours and provide a status update within 7 business days.

General inquiries: [hello@zunialab.com](mailto:hello@zunialab.com).

## Scope

In scope:

- Zunia browser extension, mobile app, web dashboard, and backend
- Key handling, signing flows, and transaction preview
- `window.zunia` provider API and `@zunialab/*` SDKs
- Official releases and infrastructure under zunialab.com

Out of scope:

- Third-party dApps connecting to Zunia
- User-supplied custom RPC endpoints
- Upstream dependencies (report to the upstream project; we will coordinate if needed)

## Safe harbor

We support responsible disclosure. We will not pursue legal action against researchers who report vulnerabilities in good faith and follow this policy.

## Recognition

We credit researchers who report valid issues, with permission, in release notes or a security acknowledgments page.
