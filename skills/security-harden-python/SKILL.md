---
name: security-harden-python
description: Scan and harden a Python project's supply chain — locked/hashed installs, release cooldown, registry-only sources, pip-audit, Socket, Semgrep + Bandit SAST, constraint-file security floors, and minimal runtime images. Supports uv, pip, poetry, and pdm. Use when hardening a Python repo's security, or when security-harden delegates the Python checks.
---

# Security Harden — Python

Language subskill of `security-harden`. It runs in two modes:

- **scan** — report each measure below as present / partial / missing, with the
  file and the concrete change. No edits.
- **apply** — make the changes the user confirmed, nothing else.

When invoked directly (not from `security-harden`), scan first, show the report,
and wait for explicit confirmation before applying.

**Verify before you write.** Check the installed and latest tool versions
(`uv --version`, `pip index versions uv`) and the docs for each setting before
adding it; propose upgrades as their own batch.

## Detect the tooling

`uv.lock` → uv · `poetry.lock` → poetry · `pdm.lock` → pdm · `Pipfile.lock` →
pipenv · only `requirements*.txt` → pip. Check every `pyproject.toml`.

## Supply chain

| Measure | uv | pip | poetry |
|---------|----|-----|--------|
| Pin tool + Python | `required-version` in `[tool.uv]`, `requires-python`, `.python-version` | pinned in CI setup | `poetry` version pinned in CI, `requires-python` |
| Locked install | `uv sync --locked` (`--frozen` in Docker) | `pip install --require-hashes -r requirements.txt` (generate with `uv pip compile --generate-hashes` or `pip-compile --generate-hashes`) | `poetry install --sync` with lock checked (`poetry check --lock`) |
| Release cooldown (7 days) | `exclude-newer` (relative value if the uv version supports it; otherwise a date bumped by automation) | — use Renovate `minimumReleaseAge` / Dependabot cooldown | same as pip |
| Registry-only sources | no `git+`/URL/path deps in `[tool.uv.sources]` except first-party | no `git+`/URL lines; `--only-binary :all:` where possible | no `git`/`url` deps |
| Security floors | `constraint-dependencies` / `override-dependencies` | `-c constraints.txt` | direct pin with comment |

Rules:

- [ ] Python version is a supported release (check python.org status; EOL → HIGH).
- [ ] Every install in CI and Dockerfiles uses the locked/hashed form.
- [ ] Release cooldown matches the Dependabot cooldown (7 days).
- [ ] VCS/URL/sdist-only dependencies flagged; prefer wheels from PyPI.
- [ ] A private index, if used, is configured so packages can't be shadowed from
      PyPI (dependency confusion): uv `index` with `explicit = true`, pip
      `--index-url` only (never `--extra-index-url` for internal names).
- [ ] Each floor/constraint has a comment with date, CVE/GHSA, and drop condition.

## CI gates (every PR + main)

- [ ] **CVE audit**: `pip-audit` against the locked set
      (`uv export --format requirements-txt | pip-audit -r /dev/stdin --strict`,
      or `pip-audit -r requirements.txt`). Fail on any fixable vuln.
- [ ] **Socket** (`socket ci`) — supports PyPI.
- [ ] **SAST**: Semgrep `p/default p/python` (+ `p/django` / `p/flask` /
      `p/fastapi` as applicable) with `--error` + SARIF, and Bandit
      (`bandit -r <src> -ll`). Suppressions need `# nosec <id>` / `# nosemgrep`
      with a reason.
- [ ] Lint (ruff) and type-check (mypy/pyright) are real gates.

## App-level

- [ ] Settings validated at boot (pydantic-settings); debug mode refuses to run in
      production (`DEBUG=False`, Django `ALLOWED_HOSTS`, `SECRET_KEY` from env).
- [ ] Outbound HTTP calls have timeouts (`requests` has none by default).
- [ ] No `pickle`/`yaml.load`/`eval` on untrusted input; `yaml.safe_load`.
- [ ] Auth fails closed; IDs validated before reaching paths/URLs; logs and
      Sentry scrub tokens and PII.

## Containers

- [ ] Multi-stage: build venv in a builder stage, copy only the venv + app into a
      `python:*-slim` or distroless runtime pinned by digest.
- [ ] No pip / uv / build tools in the runtime stage; non-root `USER`.
- [ ] `PYTHONDONTWRITEBYTECODE=1`, `PYTHONUNBUFFERED=1`, and the app's production
      setting in the image.

## Verify

Run the locked install, `pip-audit`, `bandit`, ruff, the type checker, and tests;
report the real output.
