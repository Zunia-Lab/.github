# Deployment and DNS

Guide for wiring `zunialab.com`. Production is the Hetzner host behind Cloudflare.

## Domains

| Host | Target | Project |
|------|--------|---------|
| `zunialab.com` | Hetzner nginx → `127.0.0.1:3010` | `zunia-website` |
| `www.zunialab.com` | Same vhost as the apex | `zunia-website` |
| `docs.zunialab.com` | Hetzner nginx static root | `zunia-docs` |
| `wallet.zunialab.com` | Hetzner nginx → `127.0.0.1:3012` | `zunia-dashboard` |
| `api.zunialab.com` | Hetzner nginx → `127.0.0.1:8788` (WSS `/v1/connect/ws`) | `zunia-backend` |
| `backend.zunialab.com` | Alias of `api` | `zunia-backend` |
| `indexer.zunialab.com` | Hetzner nginx → `127.0.0.1:8787` | `zunia-indexer` |
| `link.zunialab.com` | Same Next app as the apex | `zunia-website` |
| `status.zunialab.com` | Static page on the same host | `zunia-infra` |

Cloudflare proxies the zone (orange cloud), SSL mode Full (strict), WebSockets on. Origin TLS is one Let's Encrypt certificate (DNS-01). Server steps live in `zunia-infra` (`docs/hetzner.md`). Leave `mail.zunialab.com` on the mail host.

## DNS records (Cloudflare / registrar)

Proxied A `65.108.104.223` and AAAA `2a01:4f9:6b:1c48::2` for `@`, `docs`, `wallet`, `api`, `backend`, `indexer`, `link`, and `status`. `www` is a proxied CNAME to the apex. Do not change MX or `mail`.

## Email

| Address | Action |
|---------|--------|
| `hello@zunialab.com` | General |
| `security@zunialab.com` | Vulnerability reports (required) |
| `dev@zunialab.com` | User support |
| `press@zunialab.com` | Press |

MX / TXT records depend on your email provider. Keep SPF/DKIM configured; aim for DMARC `p=reject` eventually.

## Well-known (website)

Served from `zunia-website/public/.well-known/`:

- `apple-app-site-association` — replace `TEAMID`
- `assetlinks.json` — replace Play signing SHA-256
- `security.txt` — contact `security@`

## GitHub org domain verification

1. Org Settings → Verified domains → Add `zunialab.com`
2. Add the TXT record GitHub provides
3. Click Verify

## Production host

The public hostnames above are on the Hetzner box. Rebuild steps are in the `zunia-infra` repo (`docs/hetzner.md`). Vercel is not the production target for these domains.

## Accounts to provision (long lead time)

- Apple Developer Program (organisation)
- Google Play Console (organisation)
- Chrome Web Store / Firefox AMO / Edge Add-ons
- WalletConnect Cloud project ID
- npm org `@zunialab`

## Social / Open Graph

Use assets from `zunia-brand`:

- X cover: `png/social/zunia-x-cover-1500x500.png`
- Profile: `png/social/zunia-profile-512.png`
- LinkedIn: `png/social/zunia-linkedin-cover-1584x396.png`

## Org logo (manual)

Upload `zunia-brand/png/icons/zunia-icon-cobalt-512.png` at:

https://github.com/organizations/Zunia-Lab/settings/profile
