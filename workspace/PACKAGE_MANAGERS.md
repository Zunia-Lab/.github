# Package manager policy (Zunia Lab)

**Canonical JS package manager: `pnpm@9`** (`packageManager` field in each Node repo).

| Repo | Manager | Notes |
|------|---------|--------|
| Product Node apps (`zunia-ui`, `sdk`, `core`, `backend`, `indexer`, `docs`, `e2e`, `infra`, `website`, `dashboard`, `extension`) | **pnpm** | Commit `pnpm-lock.yaml`; CI `pnpm install --frozen-lockfile` |
| `zunia-chain-registry` | yarn 3 (upstream) | Keep until dedicated migration |
| `zunia-mobile` | pub | Commit `pubspec.lock` |

Do not add npm/yarn lockfiles to new product repos.
