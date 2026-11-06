# Repo governance checklist

## CODEOWNERS

- [ ] `.github/CODEOWNERS` (or `CODEOWNERS` / `docs/CODEOWNERS`) exists.
- [ ] It covers everything that can ship code, secrets, or auth:
      ```
      /.github/                 @org/security-owners
      /scripts/                 @org/security-owners
      Dockerfile*               @org/security-owners
      *compose*.y*ml            @org/security-owners
      # package-manager config, e.g.:
      /pnpm-workspace.yaml      @org/security-owners
      /.npmrc                   @org/security-owners
      /package.json             @org/security-owners
      # auth / payment / config modules:
      /src/auth/                @org/security-owners
      ```
      Use real owners from the repo (git log authors, existing CODEOWNERS, ask the
      user) — never invent handles. If unknown, leave a `TODO` and ask.

## Branch protection (remote — print, don't apply)

Give the user the commands or Settings path for `main`:

- required status checks (the security gates added in CI);
- required pull-request review **with code-owner review**;
- dismiss stale approvals on new commits;
- no force-push, no deletion;
- optionally require signed commits and linear history.

Example to hand over (verify against the current rulesets API first):

```bash
gh api repos/{owner}/{repo}/rulesets --method POST --input ruleset.json
```

## SECURITY.md

- [ ] `SECURITY.md` (root or `.github/`) exists with:
  - a **private** reporting channel (GitHub private vulnerability reporting or a
    security email) — never "open an issue";
  - a response SLA (e.g. acknowledge within 3 business days);
  - scope (what's in / out);
  - supported versions, if the project ships releases;
  - secret-handling rules for contributors (no secrets in issues/PRs, rotate on
    leak).

Ask the user for the contact address and SLA instead of making them up.
