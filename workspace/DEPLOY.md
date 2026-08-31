# Deployment and DNS

Guide for wiring `zuniawallet.com` to GitHub org products and Vercel.

## Domains

| Host | Target | Project |
|------|--------|---------|
| `zuniawallet.com` | Vercel | `zunia-website` |
| `www.zuniawallet.com` | Redirect → apex | `zunia-website` |
| `docs.zuniawallet.com` | Vercel | `zunia-docs` |
| `wallet.zuniawallet.com` | Vercel | `zunia-dashboard` |
| `api.zuniawallet.com` | Backend host | `zunia-backend` / `zunia-infra` |
| `link.zuniawallet.com` | Universal / App Links | `zunia-website` (or CDN) |
| `status.zuniawallet.com` | Status page | TBD |

## DNS records (Cloudflare / registrar)

After creating Vercel projects and adding domains in the Vercel dashboard:

```
# Apex (example; Vercel may ask for A instead of CNAME)
A     @     76.76.21.21

# Or ALIAS/ANAME if your DNS supports it
CNAME www    cname.vercel-dns.com
CNAME docs   cname.vercel-dns.com
CNAME wallet cname.vercel-dns.com
CNAME api    <backend-host>
CNAME link   cname.vercel-dns.com
CNAME status <status-provider>
```

Use the exact values Vercel shows for your project.

## Email

| Address | Action |
|---------|--------|
| `hello@zuniawallet.com` | General |
| `security@zuniawallet.com` | Vulnerability reports (required) |
| `support@zuniawallet.com` | User support |
| `press@zuniawallet.com` | Press |

MX / TXT records depend on your email provider. Keep SPF/DKIM configured; aim for DMARC `p=reject` eventually.

## Well-known (website)

Served from `zunia-website/public/.well-known/`:

- `apple-app-site-association` — replace `TEAMID`
- `assetlinks.json` — replace Play signing SHA-256
- `security.txt` — contact `security@`

## GitHub org domain verification

1. Org Settings → Verified domains → Add `zuniawallet.com`
2. Add the TXT record GitHub provides
3. Click Verify

## Vercel link (CLI)

```bash
cd zunia-website && vercel link && vercel --prod
cd ../zunia-docs && vercel link && vercel --prod
cd ../zunia-dashboard && vercel link && vercel --prod
```

Attach custom domains in each Vercel project → Settings → Domains.

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
