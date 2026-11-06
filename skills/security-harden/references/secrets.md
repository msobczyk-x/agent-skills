# Secrets checklist

## Scanning

- [ ] TruffleHog runs on every PR and on main, over **full history**:
      ```yaml
      secrets:
        runs-on: ubuntu-latest
        timeout-minutes: 10
        permissions:
          contents: read
        steps:
          - uses: actions/checkout@<sha> # vX.Y.Z
            with:
              fetch-depth: 0
              persist-credentials: false
          - uses: trufflesecurity/trufflehog@<sha> # vX.Y.Z
            with:
              extra_args: --results=verified,unknown
      ```
- [ ] Before adding the gate, run TruffleHog locally (if installed) so existing
      findings are known up front:
      `trufflehog git file://. --results=verified,unknown`.
- [ ] GitHub secret scanning + push protection enabled (remote setting — give the
      user the Settings → Code security path; don't change it yourself).

## Storage

- [ ] Secrets live only in CI secrets / environment secrets, a secrets manager,
      or git-ignored `.env` files. Nothing committed.
- [ ] `.gitignore` covers `.env`, `.env.*` (keep an `!.env.example` with
      placeholder values only).
- [ ] `.dockerignore` exists and also excludes `.env*`, `.git`, and local
      credential files, so they never enter a build context.
- [ ] No secrets in workflow `env:` blocks as literals, in Dockerfile `ARG`/`ENV`,
      or in compose files. Build-time secrets use BuildKit `--secret`.
- [ ] Logs never print tokens or auth headers (check for `set -x` around
      secret-using steps, debug logging of request headers).

## Least privilege

- [ ] Each token is scoped to the minimum: fine-grained PATs with specific repos
      and permissions, IAM users/roles with narrow policies, per-service API keys.
- [ ] Prefer short-lived credentials (OIDC to cloud) over static keys.

## If a secret leaked

Report it as HIGH and tell the user — **do not** rotate or rewrite history
yourself:

1. **Rotate first** (revoke the leaked value at the provider). History cleanup
   doesn't help once a value is public.
2. Then remove it from the code and, if wanted, from history
   (`git filter-repo`), and force-push only with the user's explicit decision.
3. Check provider audit logs for use of the leaked credential.
