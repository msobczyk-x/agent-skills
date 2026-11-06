---
name: security-harden-jvm
description: Scan and harden a Java/Kotlin (JVM) project's supply chain — Gradle dependency locking and verification metadata or Maven pinned/enforced versions, restricted repositories, OWASP Dependency-Check, Socket, Semgrep SAST, constraint/BOM security floors, wrapper validation, and distroless/jlink runtime images. Use when hardening a Java, Kotlin, Gradle, or Maven repo's security, or when security-harden delegates the JVM checks.
---

# Security Harden — Java / Kotlin (JVM)

Language subskill of `security-harden`. It runs in two modes:

- **scan** — report each measure below as present / partial / missing, with the
  file and the concrete change. No edits.
- **apply** — make the changes the user confirmed, nothing else.

When invoked directly (not from `security-harden`), scan first, show the report,
and wait for explicit confirmation before applying.

**Verify before you write.** Check the Gradle/Maven, JDK, and plugin versions
(`./gradlew --version`, `mvn -v`, plugin portal / Maven Central) and their docs
before adding a setting; propose upgrades as their own batch.

## Supply chain — Gradle

- [ ] **Wrapper pinned and validated**: `gradle-wrapper.properties` has
      `distributionSha256Sum`; CI runs `gradle/actions/wrapper-validation`
      (pinned by SHA) or the setup action with validation on.
- [ ] **Dependency locking**: `dependencyLocking { lockAllConfigurations() }`
      and committed `gradle.lockfile`s; CI fails if locks are stale.
- [ ] **Dependency verification**: `gradle/verification-metadata.xml` with
      sha256 checksums (and PGP where available), generated with
      `./gradlew --write-verification-metadata sha256,pgp help`.
- [ ] **Repositories restricted**: declared once in `settings.gradle(.kts)` with
      `repositoriesMode = FAIL_ON_PROJECT_REPOS`; no `mavenLocal()`, no
      `jcenter()`, no plain `http://` repos; internal artifacts scoped with
      `content { includeGroup(...) }` / `exclusiveContent` (dependency confusion).
- [ ] No dynamic versions (`+`, `latest.release`, ranges) in builds.
- [ ] **Security floors** via `constraints { implementation("g:a:x.y.z") { because("CVE-…, drop when …") } }`
      or a platform/BOM.

## Supply chain — Maven

- [ ] Maven Wrapper with `distributionSha256Sum`; Maven version current.
- [ ] Versions pinned (no ranges / `LATEST` / `RELEASE`); `maven-enforcer-plugin`
      with `requireUpperBoundDeps`, `banDynamicVersions`, `requireMavenVersion`.
- [ ] Repositories restricted (no `http://`, no project-level repos pulling
      internal group ids from public mirrors).
- [ ] Security floors via `<dependencyManagement>` / BOM, each with a comment.
- [ ] Checksum policy `fail` (`-C` / `checksumPolicy`).

## Release cooldown

No native setting — rely on Renovate `minimumReleaseAge` or the Dependabot
cooldown (7 days) and note it.

## CI gates (every PR + main)

- [ ] **CVE audit**: OWASP Dependency-Check (`org.owasp.dependencycheck` Gradle
      plugin / `dependency-check-maven`) with `failBuildOnCVSS=7`, NVD API key as a
      secret, and the data cache persisted between runs. Alternative: Trivy
      `fs` scan on the lockfiles.
- [ ] **Socket** (`socket ci`) — supports Maven.
- [ ] **SAST**: Semgrep `p/default p/java` (+ `p/kotlin`, `p/spring` as
      applicable) with `--error` + SARIF. Optionally SpotBugs + FindSecBugs.
- [ ] Compile with `-Werror` / Kotlin `allWarningsAsErrors` if the repo already
      tolerates it; tests and lint as real gates.

## App-level

- [ ] Spring/Ktor: actuator endpoints not exposed publicly; auth fails closed;
      CSRF on for cookie sessions; security headers on.
- [ ] Deserialization of untrusted input avoided (Java serialization, Jackson
      default typing off).
- [ ] Outbound HTTP clients have connect/read timeouts.
- [ ] Logs scrub tokens and PII; no Log4j 2 < patched versions.

## Containers

- [ ] Multi-stage: build in a JDK image pinned by digest; run on a distroless
      Java or a `jlink`-built minimal JRE, pinned by digest.
- [ ] Non-root user; no build tools (Gradle/Maven caches) in the runtime image.
- [ ] JVM flags respect container limits (`-XX:MaxRAMPercentage`).

## Verify

Run the build with locking/verification enabled, Dependency-Check, linters, and
tests; report the real output.
