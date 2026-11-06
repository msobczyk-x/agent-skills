---
name: security-harden-go
description: Scan and harden a Go module's supply chain — verified, read-only module resolution, checksum database, minimal GOPRIVATE, govulncheck, Socket, Semgrep + gosec SAST, security floors in go.mod, and static binaries on distroless/scratch. Use when hardening a Go repo's security, or when security-harden delegates the Go checks.
---

# Security Harden — Go

Language subskill of `security-harden`. It runs in two modes:

- **scan** — report each measure below as present / partial / missing, with the
  file and the concrete change. No edits.
- **apply** — make the changes the user confirmed, nothing else.

When invoked directly (not from `security-harden`), scan first, show the report,
and wait for explicit confirmation before applying.

**Verify before you write.** Check `go version`, the latest Go release
(go.dev/dl), and current tool versions before pinning anything.

## Supply chain

- [ ] `go` directive and `toolchain` line in `go.mod` on a **supported** Go
      release (the two most recent minors); older → HIGH.
- [ ] `go.sum` committed; CI runs `go mod verify` and fails on drift
      (`go mod tidy && git diff --exit-code go.mod go.sum`).
- [ ] Builds are read-only: `GOFLAGS=-mod=readonly` in CI and Dockerfiles (or
      `-mod=vendor` if the repo vendors).
- [ ] Checksum database on: `GONOSUMDB` / `GOINSECURE` not
      set broadly; `GOPRIVATE` lists only the org's own module paths.
      `GOSUMDB=off` → HIGH.
- [ ] `GOPROXY` is the default or a trusted proxy — no `direct`-only setups
      without reason.
- [ ] Release cooldown: Go has no built-in setting — rely on the Dependabot /
      Renovate cooldown (7 days) and note it.
- [ ] `replace` directives point to module versions, not local paths or forks,
      unless justified in a comment.
- [ ] Security floors: bump the vulnerable module directly in `go.mod`
      (`go get mod@vX.Y.Z`) with a comment noting the GO-/CVE id.
- [ ] Tool dependencies use the `tool` directive (Go 1.24+) or are pinned by
      version in CI — never `go install …@latest`.

## CI gates (every PR + main)

- [ ] **govulncheck** (`golang/govulncheck-action` pinned by SHA, or
      `go run golang.org/x/vuln/cmd/govulncheck@vX.Y.Z ./...`) — reachability-aware,
      fails on called vulnerable code.
- [ ] **Socket** (`socket ci`) — supports Go modules.
- [ ] **SAST**: Semgrep `p/default p/golang` with `--error` + SARIF, and gosec
      (`securego/gosec` pinned) or `golangci-lint` with `gosec` enabled.
      Suppressions need `// #nosec G<id> -- reason` / `// nosemgrep` with a reason.
- [ ] `go vet` and `golangci-lint` as real gates; tests with `-race`.

## App-level

- [ ] `http.Server` sets `ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`,
      `IdleTimeout` (zero means no timeout); outbound `http.Client` has `Timeout`.
- [ ] Paths built from input go through `filepath.Clean` + a root check (or
      `os.Root`, Go 1.24+); IDs validated before reaching paths/URLs.
- [ ] `crypto/rand` for tokens, never `math/rand`.
- [ ] Auth fails closed; logs never include tokens or auth headers.

## Containers

- [ ] Multi-stage: build with `CGO_ENABLED=0 go build -trimpath -ldflags="-s -w"`
      in a `golang` image pinned by digest; copy the static binary into
      `gcr.io/distroless/static-debian12:nonroot` (or `scratch` + CA certs),
      pinned by digest.
- [ ] Runtime runs as non-root (`USER nonroot:nonroot` / `65532`).

## Verify

Run `go mod verify`, `go build ./...`, `go vet ./...`, `govulncheck ./...`, the
linters, and `go test -race ./...`; report the real output.
