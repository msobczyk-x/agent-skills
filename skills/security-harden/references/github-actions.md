# GitHub Actions / CI/CD checklist

Check every file under `.github/workflows/` (and composite actions under
`.github/actions/`). Other CI systems (GitLab CI, CircleCI, Buildkite): apply the
same intent with that system's equivalents.

## Pinning

- [ ] Every third-party action is pinned to a **full 40-char commit SHA** with a
      trailing `# vX.Y.Z` comment. First-party `actions/*` too — tags are mutable.
      ```yaml
      - uses: actions/checkout@<full-sha> # v4.2.2
      ```
      Resolve SHAs with `scripts/pin-actions.sh`; never type one from memory.
- [ ] Docker-based actions / `container:` images are pinned by digest.
- [ ] Dependabot (`github-actions` ecosystem) is configured so pinned SHAs keep
      getting bumped — see [dependency-updates.md](dependency-updates.md).

## Token permissions

- [ ] Top-level `permissions: {}` (or `contents: read`) in every workflow.
- [ ] Each job grants only what it needs, e.g. `packages: write` only on the job
      that pushes an image, `security-events: write` only on SARIF upload,
      `id-token: write` only for OIDC.
- [ ] Prefer OIDC (`id-token: write` + cloud role) over long-lived cloud keys.

## Job hygiene

- [ ] `actions/checkout` uses `persist-credentials: false` unless a later step
      genuinely pushes with the token.
- [ ] Every job has `timeout-minutes`.
- [ ] Workflows have `concurrency` (cancel-in-progress for PR CI; not for deploys).
- [ ] No `pull_request_target` that checks out and runs PR code. If it exists,
      flag HIGH.
- [ ] Untrusted input (`github.event.*.title`, `body`, `head_ref`, branch names)
      is never interpolated directly into `run:` — pass through `env:` instead.

## Deploys

- [ ] Deploy jobs use a GitHub `environment` (e.g. `production`) so secrets are
      scoped and required reviewers can be set.
- [ ] SSH deploys verify the host key against a fingerprint/known_hosts stored in
      a secret — no `StrictHostKeyChecking=no`, no `ssh-keyscan` trust-on-first-use.
- [ ] Deploy by immutable **image digest** (or unique tag), not `latest`.
- [ ] A `workflow_dispatch` input allows re-deploying a previous digest/tag
      (rollback).

## Security gates (every PR + main)

These jobs should exist and fail the build; the language subskills supply the
ecosystem-specific commands:

- [ ] Secret scan (TruffleHog) — see [secrets.md](secrets.md).
- [ ] Dependency CVE audit gate.
- [ ] Malicious-package scan (Socket) where the ecosystem is supported.
- [ ] SAST: Semgrep CE with `--error` and SARIF upload
      (`github/codeql-action/upload-sarif`). Free alternative to CodeQL on private
      repos; on public repos CodeQL is free and can run alongside.
- [ ] Image scan (Trivy) if a container is built — see [containers.md](containers.md).
- [ ] Lint and typecheck are real gates (not `|| true`, not `continue-on-error`).

Semgrep job shape (confirm the current image tag first):

```yaml
semgrep:
  runs-on: ubuntu-latest
  timeout-minutes: 15
  permissions:
    contents: read
    security-events: write
  container:
    image: semgrep/semgrep@<digest>
  steps:
    - uses: actions/checkout@<sha> # vX.Y.Z
      with:
        persist-credentials: false
    - run: semgrep scan --config p/default <language packs> --error --sarif --output semgrep.sarif
    - uses: github/codeql-action/upload-sarif@<sha> # vX.Y.Z
      if: always()
      with:
        sarif_file: semgrep.sarif
```

Suppressions need `# nosemgrep: <rule-id>` with a reason on the same line.
