# Dependency updates checklist

## Dependabot

- [ ] `.github/dependabot.yml` has an entry for **every ecosystem in use**:
      the language package manager(s), `github-actions`, and `docker` (and
      `docker-compose`, `terraform`, etc. if present). One entry per directory
      that has a manifest, or use `directories:` for monorepos.
- [ ] Weekly schedule, with `groups:` so routine bumps land as one PR per
      ecosystem rather than dozens.
- [ ] A **cooldown** matching the package manager's release-age setting (7 days
      by default), so fresh, possibly hijacked releases aren't proposed:
      ```yaml
      version: 2
      updates:
        - package-ecosystem: npm
          directory: /
          schedule:
            interval: weekly
          cooldown:
            default-days: 7
          groups:
            prod:
              dependency-type: production
            dev:
              dependency-type: development
        - package-ecosystem: github-actions
          directory: /
          schedule:
            interval: weekly
          cooldown:
            default-days: 7
          groups:
            actions:
              patterns: ["*"]
      ```
      Confirm the current `cooldown` schema in the Dependabot docs before writing it.
- [ ] Security updates are **not** delayed: Dependabot security updates ignore
      the cooldown; make sure they're enabled (remote setting — give the user the
      Settings → Code security path).

## Renovate (if the repo uses it instead)

- [ ] `minimumReleaseAge: "7 days"` (globally or per manager), `pinDigests: true`
      for Docker and actions, `helpers:pinGitHubActionDigests` preset.
- [ ] `vulnerabilityAlerts` enabled and not subject to `minimumReleaseAge`.
- [ ] Don't add Dependabot alongside an active Renovate config — pick the one
      already in use.
