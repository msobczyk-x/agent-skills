# Containers checklist

Applies to every `Dockerfile` / `Containerfile` and compose file found.

## Dockerfile

- [ ] Base images pinned by **digest**, keeping the tag for readability:
      `FROM node:22-alpine@sha256:<digest>`. Resolve with
      `docker buildx imagetools inspect <image>:<tag>`.
- [ ] Multi-stage build: dependencies and compilers stay in the build stage; the
      runtime stage copies only the artifacts.
- [ ] Runtime stage runs as a **non-root** user (`USER node`, `USER 65532`, or a
      created user). Files it must write are owned by that user.
- [ ] Runtime image is minimal (slim / distroless / scratch — see the language
      subskill), and unused package managers are removed (e.g. npm, corepack,
      yarn in a Node runtime; pip in a Python runtime).
- [ ] Production mode is set in the image (`ENV NODE_ENV=production` or the
      language equivalent), not only in an env file.
- [ ] Installs use the locked/frozen flag of the ecosystem.
- [ ] No secrets in `ARG`/`ENV`; build secrets via `RUN --mount=type=secret`.
- [ ] `.dockerignore` present (see [secrets.md](secrets.md)).
- [ ] `HEALTHCHECK` defined where the orchestrator doesn't provide one.

## Image scanning

- [ ] Trivy scans the built image in CI and fails on fixable highs:
      ```yaml
      - uses: aquasecurity/trivy-action@<sha> # vX.Y.Z
        with:
          image-ref: <image>@<digest-or-local-tag>
          severity: CRITICAL,HIGH
          ignore-unfixed: true
          exit-code: '1'
      ```
- [ ] Accepted findings go in `.trivyignore` with a reason and review date.

## Compose / runtime

For each service in `docker-compose*.yml` / `compose*.yml`:

- [ ] `read_only: true`, with `tmpfs:` for directories that must be writable.
- [ ] `cap_drop: [ALL]` (add back only what is required).
- [ ] `security_opt: ["no-new-privileges:true"]`.
- [ ] Memory (and ideally CPU / pids) limits set.
- [ ] Ports bound to `127.0.0.1:` when a reverse proxy fronts the service;
      databases and caches never published on `0.0.0.0`.
- [ ] Images referenced by digest or a unique tag, not `latest`.
- [ ] Secrets via `env_file` that is git-ignored or compose `secrets:`, never inline.
