---
name: security-harden-rust
description: Scan and harden a Rust (Cargo) project's supply chain — locked builds, pinned toolchain, cargo-deny sources/advisories/bans/licenses, cargo-audit, Socket, Semgrep + clippy SAST, [patch] security floors, and distroless/scratch runtime images. Use when hardening a Rust repo's security, or when security-harden delegates the Rust checks.
---

# Security Harden — Rust

Language subskill of `security-harden`. It runs in two modes:

- **scan** — report each measure below as present / partial / missing, with the
  file and the concrete change. No edits.
- **apply** — make the changes the user confirmed, nothing else.

When invoked directly (not from `security-harden`), scan first, show the report,
and wait for explicit confirmation before applying.

**Verify before you write.** Check `rustc --version`, the latest stable Rust, and
current `cargo-deny` / `cargo-audit` versions and config schema before adding them.

## Supply chain

- [ ] `rust-toolchain.toml` pins the channel/version; `rust-version` (MSRV) set in
      `Cargo.toml`.
- [ ] `Cargo.lock` committed (for binaries and workspaces with binaries).
- [ ] Every CI and Docker build uses `--locked` (`cargo build --locked`,
      `cargo test --locked`, `cargo install --locked`).
- [ ] **cargo-deny** with a `deny.toml`:
      - `[sources]`: `unknown-registry = "deny"`, `unknown-git = "deny"`, explicit
        `allow-git` only for justified repos;
      - `[advisories]`: deny vulnerabilities and unmaintained crates, with
        `ignore` entries carrying a reason;
      - `[bans]`: `multiple-versions = "warn"`, deny known-bad crates;
      - `[licenses]`: the allowed license list.
      Generate a starting point with `cargo deny init`, then tighten.
- [ ] Release cooldown: no native setting — rely on the Dependabot / Renovate
      cooldown (7 days) and note it.
- [ ] **Security floors** via a direct version bump or `[patch.crates-io]`, each
      with a comment noting the RUSTSEC id and drop condition.
- [ ] `build.rs` and proc-macro dependencies reviewed — they run at build time.

## CI gates (every PR + main)

- [ ] **cargo-deny** (`EmbarkStudios/cargo-deny-action` pinned by SHA):
      `cargo deny check advisories sources bans licenses`.
- [ ] **cargo-audit** (`cargo audit --deny warnings`) if the repo prefers it;
      cargo-deny's advisories check covers the same RustSec database.
- [ ] **Socket** (`socket ci`) where supported for crates.
- [ ] **SAST**: Semgrep `p/default p/rust` with `--error` + SARIF, and
      `cargo clippy --all-targets --all-features --locked -- -D warnings`.
- [ ] `unsafe` usage tracked (`#![forbid(unsafe_code)]` where the crate doesn't
      need it; `cargo geiger` optional).

## App-level

- [ ] Server timeouts and body-size limits set (axum/tower `TimeoutLayer`,
      `RequestBodyLimitLayer`); outbound `reqwest` clients have `.timeout()`.
- [ ] Auth fails closed; IDs validated before reaching paths/URLs; logs/tracing
      skip secrets (`#[instrument(skip(...))]`, redacting `Debug` impls).

## Containers

- [ ] Multi-stage: build in a `rust` image pinned by digest (`--locked
      --release`); run on `gcr.io/distroless/cc-debian12:nonroot` (or
      `static` / `scratch` for musl builds), pinned by digest.
- [ ] Runtime runs as non-root; no cargo/rustup in the runtime image.

## Verify

Run `cargo build --locked`, `cargo deny check`, `cargo clippy … -D warnings`, and
`cargo test --locked`; report the real output.
