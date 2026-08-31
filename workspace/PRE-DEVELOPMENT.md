# Zunia — Pre-Development Readiness Review

> Audit of the current workspace + everything that must be decided, configured, or built
> before real feature development starts.
>
> Scope: product apps, SDKs, kernel/backend scaffolds, org `.github`.
> Status date: 2026-08-31 (updated same day with Phase 0 scaffolds).

---

## 0. TL;DR — where we actually are

| Area | State | Verdict |
|------|-------|---------|
| Brand, logos, tokens | Complete (`zunia-brand`, `@zunialab/tokens`, `tokens-flutter`) | ✅ Ready |
| Design system | 9 web components + RN mirrors + Flutter tokens package | 🟡 Thin, no Storybook/tests |
| Chain registry | Full Keplr fork, cosmos/evm/svm JSON, upstream sync doc | ✅ Ready |
| Docs site | Docusaurus + ADR overview + connect/SDK pages | 🟡 Content still aspirational |
| Website / Dashboard | Next scaffolds + `vercel.json` + `.well-known` | 🟡 Config ready, UI not started |
| Extension | WXT + connect/security/session **config**; empty provider | ❌ Not started |
| Mobile | Flutter + connect/mnemonic **config** + deep links | ❌ Wallet logic not started |
| SDK | `zunia-sdk` web/React/Flutter packages | 🟡 Scaffold API surface |
| **Wallet core** | `zunia-core` scaffold + ADRs + CI; **no crypto** | 🟡 Repo exists, Phase 1 empty |
| **Backend / notifications** | `zunia-backend` config + CI | 🟡 Scaffold only |
| **Indexer / e2e / infra / security** | Repos scaffolded (`zunia-indexer`, `zunia-e2e`, `zunia-infra`, `zunia-security`) | 🟡 Config / private drafts |
| CI/CD, Dependabot | Added on product + new repos | 🟡 Green when lockfiles/pushed |
| Threat model, key-mgmt spec, legal | Threat outline in `zunia-security`; legal still open | ❌ Critical gap |

**Bottom line:** Phase 0 **repo + config scaffolds** are in place. Security-relevant **implementation** is still unwritten — answer ADRs before Phase 1 crypto.

---

## 1. Missing repositories / components

| Repo | Status |
|------|--------|
| `zunia-core` (TS) | ✅ Scaffold + ADRs + CI + vector placeholder |
| `zunia-backend` (API) | ✅ Scaffold + notification/privacy config |
| `zunia-indexer` | ✅ Decision config (`config/providers.yaml`) — vendor TBD |
| `zunia-sdk` | ✅ Web / React / Flutter packages |
| `zunia-e2e` | ✅ Playwright + Maestro harness (tests skipped) |
| `zunia-infra` | ✅ Pulumi stub + domain notes |
| `zunia-security` (private) | ✅ Local scaffold — **create GitHub repo as private** |

---

## 2. Decisions to make before writing code

Each of these changes the architecture. Answer them explicitly and record them as ADRs
(`docs/adr/NNNN-title.md`) in the repo they affect.

### 2.1 Product & scope
1. **Custody model:** self-custody only, or self-custody + social-login (MPC/AA) accounts side by side? This is the single biggest fork in the road — see §5. → **ADR-0003 proposed in `zunia-core`.**
2. **Chains at launch:** which 5–10 Cosmos chains ship enabled by default? EVM and SVM are in the registry — are they in v1 or v2?
3. **Feature set for v1:** send/receive, staking, IBC transfer, dApp connect, swaps, NFTs, governance, ledger — pick the minimum that is defensible.
4. **Platforms at launch:** extension only, or extension + mobile simultaneously? Simultaneous doubles the audit surface.
5. **Monetisation:** swap fee, staking commission (do you run validators?), none. Affects legal classification.

### 2.2 Technical
6. **Wallet kernel language:** TypeScript shared (extension/web) + separate Dart implementation, or one Rust core compiled to WASM + FFI for Flutter? Rust core = one audit, higher upfront cost. **Recommendation: Rust core if mobile is v1; TS + Dart split only if mobile is v2+.** → **ADR-0002 proposed.**
7. **Cosmos libs:** CosmJS vs `@cosmjs` + `cosmes` vs `telescope`-generated clients. Pin and document; protobuf registry drift is a real source of signing bugs. → **ADR-0004 proposed.**
8. **Monorepo vs polyrepo:** currently many independent git repos. Shared crypto across repos without a monorepo means version skew. **Consider collapsing extension + dashboard + core + ui into one pnpm/turbo monorepo.**
9. **State/storage:** extension (`chrome.storage.local` + session), mobile (`flutter_secure_storage` + Keychain/Keystore), web dashboard (**must be watch-only or hardware/WalletConnect — never hold keys in browser localStorage**). → Session config stub in `zunia-extension/config/session.yaml`.
10. **RPC strategy:** public endpoints (unreliable, privacy-leaking) vs paid providers vs own nodes. Users' IP + address correlation is a privacy question, not just an ops one.
11. **Versioning & release trains:** semver per repo, changesets, signed tags, reproducible builds.

### 2.3 Legal / compliance (do not skip)
12. Legal entity, jurisdiction, and whether a non-custodial wallet triggers VASP/MiCA registration where you operate.
13. Terms of Service, Privacy Policy, cookie/analytics consent — required by Chrome Web Store, Apple, and Google Play *before* submission.
14. Apple/Google policy: crypto wallet apps have extra review requirements; developer account must be an **organisation**, not individual, in several regions.
15. Export/crypto declaration for the App Store (encryption compliance, ECCN).
16. Data map: what personal data touches your servers (email for social login, push tokens, IPs)? GDPR basis for each.
17. Open-source licence consistency: Apache-2.0 in `zunia-ui` vs the Keplr fork's licence — verify fork obligations in `UPSTREAM.md`.

---

## 3. Wallet security — full requirements

This is the section that must be treated as spec, not aspiration. Group by lifecycle.

Config mirrors (not yet enforced in UI code):

- Mobile: `zunia-mobile/config/mnemonic_security.yaml`, `config/connect.yaml`
- Extension: `zunia-extension/config/security.yaml`, `config/session.yaml`, `config/connect.ts`

### 3.1 Key generation
- [ ] Entropy from platform CSPRNG only: `crypto.getRandomValues` (web/ext), `SecRandomCopyBytes`/`SecureRandom` on mobile. **Never** `Math.random`, never a JS PRNG, never user-typed "randomness" as the sole source.
- [ ] 128-bit (12-word) minimum; offer 256-bit (24-word) as an advanced option.
- [ ] BIP-39 with correct wordlist + checksum validation; support optional BIP-39 passphrase ("25th word") with a very clear warning that it is unrecoverable and creates a *different* wallet.
- [ ] BIP-44 paths: `m/44'/118'/0'/0/i` for Cosmos, `m/44'/60'/0'/0/i` for EVM chains, `m/44'/501'/i'/0'` for Solana. Support per-chain coin-type overrides (Terra=330, Secret=529, etc. — drive from the chain registry, not hardcoded).
- [ ] Deterministic account discovery on import (scan first N accounts for activity).
- [ ] Zeroise entropy/seed buffers after use where the runtime allows (Rust/Dart yes; JS best-effort — document the limitation honestly).

### 3.2 Mnemonic display & backup UX
- [ ] **Block screenshots and screen recording on every screen that shows or accepts a mnemonic or private key.** (Policy captured in `mnemonic_security.yaml`.)
  - Android: `WindowManager.LayoutParams.FLAG_SECURE` on the activity (Flutter: `flutter_windowmanager` / `secure_application`), applied on route push and removed on pop.
  - iOS: no true block — detect via `UIScreen.isCaptured` (recording) and `userDidTakeScreenshotNotification`, blur/overlay the content and warn the user; add a `UITextField.isSecureTextEntry` overlay trick for the screenshot case.
  - Extension/web: cannot block. Instead: never render the phrase until an explicit "reveal" tap, hide on blur/visibilitychange, auto-hide after N seconds, and warn that the browser is a lower-security environment.
- [ ] Blur-by-default with hold-to-reveal; auto re-blur on window blur, tab switch, or app backgrounding.
- [ ] Hide the app content in the OS app switcher (iOS `applicationWillResignActive` overlay, Android `FLAG_SECURE` covers it).
- [ ] Disable clipboard copy of the mnemonic by default; if allowed, warn + auto-clear clipboard after 30–60 s and never place it in a synced/universal clipboard.
- [ ] Disable OS autofill / keyboard learning on mnemonic inputs (`autocomplete="off"`, `autocorrect=off`, `spellcheck=false`, Android `IME_FLAG_NO_PERSONALIZED_LEARNING`, iOS `.oneTimeCode`-style suppression).
- [ ] Disable third-party keyboards on mnemonic entry where the platform allows.
- [ ] **Mandatory verification step:** ask the user to re-enter 3–4 words at random positions (not multiple-choice-only — typed entry, with the word list as an autocomplete to avoid transcription errors). Do not let the wallet be funded until verification passes. Allow "skip for now" only with an explicit, scary, logged confirmation and a persistent "unverified backup" banner.
- [ ] Never send the mnemonic anywhere: no analytics, no logs, no crash reports (scrub Sentry/Crashlytics with a deny-list and test it), no cloud backup of the plaintext.
- [ ] No mnemonic in `console.log`, React DevTools props, Redux devtools, or Flutter widget inspector — strip devtools in release builds.
- [ ] Offer alternative backups explicitly labelled with trade-offs: encrypted file export, iCloud/Google Drive *encrypted* backup (user password derived), Shamir/SLIP-39 split (advanced).

### 3.3 Key storage at rest
- [ ] Encrypt the seed with a key derived from the user password using **Argon2id** (preferred) or scrypt (N≥2^17) — not PBKDF2-SHA256 with a low iteration count. Tune params per platform and store them alongside the ciphertext for future migration.
- [ ] AEAD (XChaCha20-Poly1305 or AES-256-GCM) with a unique random nonce; version the ciphertext envelope so you can rotate KDF params later.
- [ ] Mobile: wrap the encryption key with the OS keystore — iOS Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` + Secure Enclave where possible; Android Keystore with `setUserAuthenticationRequired`, StrongBox when available. Never `SharedPreferences`.
- [ ] Biometric unlock gates *access to the keystore key*, it must not be the only thing between an attacker and the seed — always keep the password as the root secret.
- [ ] Extension: keep the decrypted key only in the service-worker memory for the session; MV3 service workers are killed — design for re-unlock, do not persist decrypted material to `chrome.storage`.
- [ ] Auto-lock: on timeout (default 5–15 min, configurable), on device lock, on browser close, on background for N minutes. Explicit "Lock now".
- [ ] Rate-limit password attempts with exponential backoff; optional wipe-after-N-failures (opt-in, with loud warning).
- [ ] Root/jailbreak detection + emulator detection → warn (do not silently block); play-integrity / app-attest on mobile.
- [ ] No plaintext keys in memory dumps where avoidable; disable core dumps, do not log key objects.

### 3.4 Signing & transaction safety
- [ ] Every signature requires explicit user approval on a screen that shows: chain, from/to, human-readable amount + fiat estimate, fee, memo, and decoded messages.
- [ ] **Decode `MsgExecuteContract` payloads**, not just show base64. Unknown message types → prominent "we cannot decode this" warning.
- [ ] `signArbitrary`/ADR-36 must show the exact payload and refuse payloads that could be valid transactions.
- [ ] Blind-signing off by default; opt-in per session with a warning.
- [ ] Simulate the tx (gas estimation + expected balance change) and show "you will receive/lose X" where possible.
- [ ] Warn on: sending to a never-before-used address, address that is a contract, chain-id mismatch, unusually high fee, token approval of unlimited amount, memo required by a known CEX deposit address (major cause of lost funds).
- [ ] Address checksum/bech32 prefix validation per chain; block cross-chain address pastes.
- [ ] Clipboard-hijack defence: re-verify the pasted address at signing time against what is displayed.
- [ ] Nonce/sequence handling and replay protection reviewed per chain.

### 3.5 dApp connection & extension hardening (browser)
- [x] Per-origin permission model **policy** in connect/security config (implementation TBD).
- [ ] The injected `window.zunia` provider must use an isolated message channel with origin checks on **both** sides; never `postMessage('*')`.
- [x] Strict CSP in the extension manifest (`wxt.config.ts`).
- [ ] Minimise permissions: current `host_permissions: ["https://*/*"]` is broad and will slow store review — narrow it or justify it in the listing.
- [x] Phishing protection **config** (`config/security.yaml`); blocklist feed TBD.
- [ ] Clickjacking defence on approval popups: use the extension popup/window, never an in-page iframe.
- [ ] Guard against a malicious page opening many approval prompts (rate-limit, queue, show origin prominently).
- [ ] Lock the extension when the popup closes if "require password per session" is on.
- [x] WalletConnect: `strict_namespace: true` in `connect.yaml`; session code TBD.

### 3.6 Supply chain & build integrity
- [x] Lockfiles + CI using frozen install where applicable.
- [ ] Dependency pinning and review policy for anything touching crypto; minimal dependency budget in `zunia-core`.
- [x] Dependabot configs added; [ ] CodeQL/Semgrep org-wide; [x] gitleaks workflow on `zunia-core` (extend to all).
- [ ] Reproducible extension builds + published build instructions (the docs already promise this — make it true).
- [ ] Signed git tags and signed release artifacts; SLSA provenance if feasible.
- [ ] Protect the release keys: Chrome Web Store, Firefox AMO, Apple, Google Play signing keys in an HSM/managed signing, 2-person release approval, hardware 2FA on every store + GitHub account.
- [ ] GitHub org: require 2FA, branch protection on `main`, required reviews, no force-push, restrict who can publish npm packages (`@zunialab/*` — reserve the npm scope now).

### 3.7 Audits & assurance
- [x] Threat model **outline** in `zunia-security/threat-model/` (expand before Phase 1).
- [ ] Third-party security audit of the wallet kernel + signing flow **before** mainnet marketing push. Budget 4–8 weeks lead time.
- [ ] Cryptography test vectors: BIP-39/32/44 official vectors, per-chain address derivation vectors, signature round-trip tests, encryption envelope tests. Placeholder dir: `zunia-core/tests/vectors/`.
- [ ] Fuzzing on tx decoding and registry JSON parsing.
- [x] `security.txt` on the website; contact `security@zuniawallet.com` (mailbox + PGP still to provision).
- [x] Incident response **draft** runbook in `zunia-security/runbooks/`.

---

## 4. Realtime notifications (web, mobile, extension)

### 4.1 What we want to notify about
- Incoming transfer received / outgoing tx confirmed or failed
- IBC transfer stuck, timed out, or completed
- Staking: rewards ready to claim, unbonding completed, validator jailed/slashed/commission change
- Governance: new proposal, voting period ending on a proposal you can vote on
- dApp connection request / signature request arriving from a paired device or WalletConnect
- Security: new device connected, session approved, unusual approval, wallet unlocked elsewhere
- Price alerts, low balance for gas
- App/product: new version, security advisory, chain upgrade/halt notice

### 4.2 Transport per platform

| Platform | Foreground / in-app | Background |
|---|---|---|
| Web (dashboard) | WebSocket or SSE from `zunia-backend` → in-app toast/popup | **Web Push (VAPID)** via Service Worker + Notification API (needs permission prompt; Safari requires the site to be installed as a PWA on iOS) |
| Extension | Long-lived port to the MV3 service worker; `chrome.runtime` messaging | `chrome.notifications` + badge text; **note: MV3 service workers sleep** — use `chrome.alarms` for polling and Web Push (`pushManager` is available in MV3) for true push |
| Mobile (Flutter) | In-app banner / overlay + local notifications | **FCM** (Android + iOS via APNs) or APNs directly; `flutter_local_notifications` for scheduled/local; Live Activities (iOS) for pending-tx progress is a nice differentiator |

Config mirror: `zunia-backend/config/notifications.ts` + `privacy.ts`.

### 4.3 Backend design for notifications
- **Event source:** subscribe to chain events. Options: (a) Tendermint/CometBFT WebSocket `subscribe` per chain (cheap, brittle at scale), (b) an indexer (Numia, SubQuery, Mintscan API, self-hosted), (c) block-polling worker. **Recommendation: indexer for history + CometBFT WS for realtime, with polling fallback.** → `zunia-indexer/config/providers.yaml`.
- **Fan-out:** an event bus (Redis Streams / NATS / Vercel Queues) → notification workers → per-user delivery. Idempotency keys so a chain reorg or reconnect does not double-notify.
- **Subscription registry:** map `address → devices` where a device is `{platform, push_token|endpoint, locale, timezone, prefs}`. Rotate/expire dead tokens on delivery failure.
- **Privacy problem (important):** a push backend that watches user addresses learns the full address ↔ device ↔ IP graph. Mitigations encoded in `PRIVACY_CONFIG`.
- **Delivery guarantees / preferences / localisation / deep links:** see backend config; deep links already in mobile `connect.yaml`.
- **Testing:** notification delivery is famously untestable in CI — build a staging harness and a "send test notification" debug button.

### 4.4 Concrete infra choices to pick
- Push: FCM (free, both platforms) vs OneSignal/Knock/Courier (faster, adds a third party to your privacy story).
- Realtime web: raw WS on Fly/Railway, Pusher/Ably, or Supabase Realtime.
- Given the rest of the stack is Vercel/Next: Vercel Functions + Vercel Queues + an external always-on worker for chain WS subscriptions (serverless cannot hold WS subscriptions).

---

## 5. Wallet creation with email / Google (social login)

This is a **fundamentally different custody model** from a seed-phrase wallet. Decide deliberately.

### 5.1 The options

| Approach | How it works | Trust assumption | Notes |
|---|---|---|---|
| **MPC / TSS** (Web3Auth, Privy, Particle, Capsule/Para, Turnkey, Dfns) | Key split into shares: device + provider + recovery (social login unlocks the provider share) | Provider cannot sign alone, but is a liveness dependency and often a business-continuity risk | Fastest path; check Cosmos/ADR-36 signing support explicitly — most are EVM-first |
| **Passkey / WebAuthn + secure enclave** | Key material protected by the platform passkey, synced via iCloud/Google Password Manager | Apple/Google | Great UX, but passkey-derived signing for Cosmos needs your own wrapper; recovery = the platform account |
| **Smart-account / account abstraction** | Contract account, social login controls a session key | Chain + your paymaster | Cosmos AA is immature (`x/accounts` in SDK v0.53+, Abstract Account contracts on some chains) — treat as experimental |
| **Encrypted seed + cloud backup** | Classic seed, encrypted with a password/KDF, blob stored in the user's own iCloud/Drive; Google login only locates the blob | User's password | Simplest to reason about, no third-party key custody. **Recommended default for "easy mode".** |
| **Custodial** | You hold keys | You | Triggers licensing almost everywhere. Avoid. |

**Recommendation:** ship self-custody seed as the primary path, and offer "Continue with Google/Apple/email" as an *encrypted-cloud-backup* or *MPC* onboarding — but make the custody model visible in the UI, never blur the line, and always give the user a path to export a real seed phrase and leave. → See ADR-0003.

### 5.2 Requirements whichever path you pick
- [ ] Auth provider decision: Clerk / Auth0 / Supabase Auth / Firebase Auth / your own OIDC. (Clerk is a native Vercel Marketplace integration if you stay on Vercel.)
- [ ] Sign in with Google **and** Apple — Apple is mandatory on iOS if you offer any other social login.
- [ ] Email OTP / magic link as the no-social fallback; rate-limit and expire codes; guard against email-enumeration.
- [ ] **Email account takeover = wallet takeover.** Mitigate: mandatory 2FA on the wallet-controlling account, a time-locked delay on recovery, a device-approval step, and email-change cooldowns.
- [ ] Session security: short-lived JWT + refresh rotation, device binding, revoke-all-sessions, visible session list.
- [ ] Account linking/unlinking rules; what happens if the user deletes their Google account.
- [ ] Recovery flow spec: how many shares, who holds them, what happens if the provider disappears (**exit plan is a contractual and technical requirement, not a footnote**).
- [ ] Migration path: social wallet → self-custody export (and document that the provider's share history means it is not equivalent to a fresh cold wallet).
- [ ] KYC/AML posture: social login + fee-taking edges toward regulated territory in some jurisdictions — get an opinion.
- [ ] Cost model: MPC providers charge per MAU; model it before you commit.

---

## 6. Cross-cutting engineering gaps

### 6.1 CI/CD
- [x] Per-repo GitHub Actions scaffolds (lint/typecheck/test/build as applicable).
- [x] Flutter analyze/test workflow on `zunia-mobile`.
- [x] Extension Chrome build workflow.
- [x] `vercel.json` on website / dashboard / docs.
- [ ] Required status checks + real CODEOWNERS teams (placeholder CODEOWNERS on `zunia-core`).
- [ ] Release automation: changesets/semantic-release, signed tags, changelog, GitHub Releases.
- [x] Dependabot + gitleaks (core); extend CodeQL org-wide.

### 6.2 Testing strategy (near-zero today)
- Unit: crypto vectors, derivation, encryption, amount/decimal math (**use integer/`Decimal` types — never JS floats for token amounts**), bech32.
- Integration: against a local chain (`wasmd`/`gaiad` in Docker) — send, delegate, IBC via a relayer in CI.
- Contract tests for the `window.zunia` provider API.
- E2E: Playwright harness in `zunia-e2e`; Maestro smoke YAML present.
- Manual test matrix: browsers × OS versions × devices; low-end Android; iOS with reduced motion/large text.
- Chaos: RPC down, chain halted, reorg, clock skew, offline mode, airplane mode mid-signing.

### 6.3 Observability
- Error tracking (Sentry) with **aggressive PII/secret scrubbing and a test proving mnemonics never appear**.
- Product analytics: opt-in only, no addresses, no amounts; state it in the privacy policy.
- Backend: OpenTelemetry traces, uptime checks per RPC endpoint, alerting + on-call.
- Client-side "RPC health" with automatic failover between endpoints.

### 6.4 Design system (`zunia-ui`)
- Only 9 components; no Storybook, no visual regression, no a11y tests, no dark-mode contract documented, no icon set.
- Needed for wallet UI: Modal/Sheet, Toast/Notification, List/TxRow, Skeleton, QR display + scanner, Select/ChainPicker, PasswordField with strength meter, MnemonicGrid + MnemonicInput (security-hardened, see §3.2), NumericKeypad, ProgressStepper, EmptyState, Avatar/Identicon, Tooltip, Tabs, BottomNav.
- Flutter parity: ✅ `packages/tokens-flutter` added. `ui-native` remains optional RN-only — **not** used by `zunia-mobile`.

### 6.5 Accessibility, i18n, UX
- WCAG 2.2 AA target; screen-reader labels on every amount/address; contrast verified in both themes.
- Address rendering: monospace, chunked, copy affordance, never truncate without a reveal.
- i18n framework + string extraction from day one; RTL layout support; locale-aware number/date formatting.
- Offline and degraded states designed, not improvised.
- Onboarding copy reviewed by someone who will read it as a non-crypto user.

### 6.6 Repo hygiene
- [x] Root `.gitignore` for `.DS_Store`, build artifacts.
- [x] `.editorconfig` propagated.
- [x] SECURITY.md → `security@zuniawallet.com`.
- [ ] Pre-commit hooks (lefthook/husky) per repo.
- [ ] Docs: mark roadmap claims as roadmap where still aspirational.
- Polyrepo retained for now; monorepo ADR still open (§2.2 #8).

### 6.7 Infrastructure & accounts to provision
- [ ] Domain + DNS (documented in `DEPLOY.md`, not yet executed): apex, `www`, `docs`, `wallet`, plus `api.`, `link.`, `status.`
- [ ] `security@`, `support@`, `press@` mailboxes; SPF/DKIM/DMARC (`p=reject` eventually).
- [x] `.well-known/apple-app-site-association` + `assetlinks.json` + `security.txt` on the website (replace TEAMID / SHA-256 / add PGP).
- [ ] WalletConnect Cloud project ID (placeholder in `connect.yaml`).
- [ ] Store accounts: Chrome Web Store ($5), Firefox AMO, Edge Add-ons, Apple Developer Program ($99/yr, org verification takes weeks — **start now**), Google Play ($25, + org verification).
- [ ] npm org `@zunialab` reserved.
- [ ] Secrets management: Vercel env / 1Password / Doppler; nothing in `.env` committed.
- [ ] Status page + incident comms channel (X account, Discord/Telegram).

---

## 7. Recommended sequencing

**Phase 0 — Decide & set up (1–2 weeks)** — *in progress*
ADRs drafted in `zunia-core`. Repos scaffolded. CI/Dependabot added. Hygiene + well-known + security contact path. **Still need:** accept ADRs, provision accounts, private `zunia-security` remote, expand threat model.

**Phase 1 — Wallet kernel (3–5 weeks)**
`zunia-core`: BIP-39/32/44, per-chain derivation from the registry, encrypted keyring, Amino + Direct signing, tx builders. Full crypto test-vector suite. No UI.

**Phase 2 — Extension MVP (4–6 weeks)**
Onboarding (create/import, §3.2 verification flow), unlock/lock, accounts, balances, send/receive, `window.zunia` provider + approval flows, chain registry consumption.

**Phase 3 — Backend + notifications (3–4 weeks, parallel with 2)**
Indexer integration, event pipeline, push registry, Web Push + FCM, notification centre, preferences.

**Phase 4 — Mobile (5–8 weeks)**
Flutter app on the same kernel (FFI or Dart port), secure storage, biometrics, `FLAG_SECURE`, WalletConnect, deep links, push.

**Phase 5 — Dashboard + website + docs (parallel)**
Watch-only/WalletConnect dashboard, real marketing site, docs that match reality.

**Phase 6 — Hardening & launch (4+ weeks)**
External audit, bug bounty, store submissions (allow 2–6 weeks review for a crypto app), reproducible builds, incident runbooks, staged rollout starting on testnet.

---

## 8. Open questions for the team

1. Is mobile in v1? (Decides Rust-core vs TS-only, and doubles the audit cost.)
2. Flutter *and* `ui-native` (React Native) — which one is real? → **Flutter is real; `tokens-flutter` added; `ui-native` optional RN only.**
3. Do we accept a third-party MPC provider in the trust chain, or is encrypted-cloud-backup the "easy mode"?
4. Who is the security owner, and is there budget for an external audit before launch?
5. Which chains ship enabled, and who maintains registry endpoint health?
6. Do we run our own RPC, and who pays for it?
7. Monorepo consolidation now, or live with polyrepo and version skew?
8. Legal entity + jurisdiction — resolved before store submission?
9. What is the notification privacy promise we are willing to publish?
10. Testnet-first launch, and for how long?

---

## 9. Non-negotiables checklist (gate for "real development can start")

- [ ] ADRs **accepted** for custody model, kernel language, chains, platforms (drafts exist)
- [ ] Threat model documented beyond outline
- [x] `zunia-core` repo exists with CI; [ ] crypto test-vector suite filled
- [ ] CI green on every **remote** repo (workflows added locally — push + fix lockfiles)
- [x] Secret scanning workflow started (gitleaks on core); [ ] org-wide dependency scanning
- [ ] 2FA enforced + branch protection on all repos
- [x] `security.txt` published in website tree; [ ] `security@` mailbox + PGP live
- [ ] Mnemonic-handling spec (§3.2) signed off by whoever owns security
- [ ] Sentry/analytics scrubbing test proving no key material leaves the device
- [ ] Legal review started; Privacy Policy + ToS drafted
- [ ] Apple/Google/Chrome store accounts created and verified
