#!/usr/bin/env bash
# Detect the languages, package managers, and security-relevant files in a repo.
# Usage: detect-stack.sh [repo-path]   (defaults to the current directory)
# Prints JSON to stdout; progress to stderr. Compatible with macOS bash 3.2.
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"
echo "Scanning $(pwd)..." >&2

# Find files by name pattern, skipping vendored/build directories. One path per line.
find_files() {
  find . \( -name node_modules -o -name .git -o -name vendor -o -name target \
    -o -name dist -o -name build -o -name .venv -o -name venv -o -name .next \
    -o -name .gradle -o -name __pycache__ \) -prune -o \
    -type f \( "$@" \) -print 2>/dev/null | sed 's|^\./||' | sort
}

json_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# Turn newline-separated input into a JSON array of strings.
json_array() {
  local first=1 line
  printf '['
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    if [ "$first" -eq 1 ]; then first=0; else printf ','; fi
    printf '"%s"' "$(json_escape "$line")"
  done
  printf ']'
}

exists() { [ -e "$1" ] && echo true || echo false; }

first_existing() {
  local f
  for f in "$@"; do
    if [ -e "$f" ]; then printf '"%s"' "$f"; return; fi
  done
  printf 'null'
}

# --- languages ---------------------------------------------------------------
languages=""
add_lang() { languages="${languages}${1}"$'\n'; }

node_manifests="$(find_files -name package.json)"
python_manifests="$(find_files -name pyproject.toml -o -name 'requirements*.txt' -o -name setup.py -o -name Pipfile)"
go_manifests="$(find_files -name go.mod)"
jvm_manifests="$(find_files -name build.gradle -o -name build.gradle.kts -o -name pom.xml)"
rust_manifests="$(find_files -name Cargo.toml)"

[ -n "$node_manifests" ] && add_lang js
[ -n "$python_manifests" ] && add_lang python
[ -n "$go_manifests" ] && add_lang go
[ -n "$jvm_manifests" ] && add_lang jvm
[ -n "$rust_manifests" ] && add_lang rust

# --- JS package manager --------------------------------------------------------
js_pm="null"
if [ -n "$node_manifests" ]; then
  if [ -f pnpm-lock.yaml ] || [ -f pnpm-workspace.yaml ]; then js_pm='"pnpm"'
  elif [ -f yarn.lock ]; then js_pm='"yarn"'
  elif [ -f bun.lockb ] || [ -f bun.lock ]; then js_pm='"bun"'
  elif [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then js_pm='"npm"'
  else js_pm='"unknown"'
  fi
fi

# --- Python package manager ----------------------------------------------------
py_pm="null"
if [ -n "$python_manifests" ]; then
  if [ -f uv.lock ]; then py_pm='"uv"'
  elif [ -f poetry.lock ]; then py_pm='"poetry"'
  elif [ -f Pipfile.lock ]; then py_pm='"pipenv"'
  elif [ -f pdm.lock ]; then py_pm='"pdm"'
  else py_pm='"pip"'
  fi
fi

# --- JVM build tool --------------------------------------------------------------
jvm_tool="null"
if [ -n "$jvm_manifests" ]; then
  if printf '%s\n' "$jvm_manifests" | grep -q 'build.gradle'; then jvm_tool='"gradle"'; else jvm_tool='"maven"'; fi
fi

lockfiles="$(find_files -name pnpm-lock.yaml -o -name yarn.lock -o -name package-lock.json \
  -o -name npm-shrinkwrap.json -o -name bun.lockb -o -name bun.lock -o -name uv.lock \
  -o -name poetry.lock -o -name Pipfile.lock -o -name pdm.lock -o -name go.sum \
  -o -name Cargo.lock -o -name gradle.lockfile -o -name verification-metadata.xml)"

dockerfiles="$(find_files -name 'Dockerfile*' -o -name 'Containerfile*' -o -name '*.Dockerfile')"
compose_files="$(find_files -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' -o -name 'compose*.yml' -o -name 'compose*.yaml')"

workflows=""
if [ -d .github/workflows ]; then
  workflows="$(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)"
fi
other_ci="$(for f in .gitlab-ci.yml .circleci/config.yml bitbucket-pipelines.yml azure-pipelines.yml Jenkinsfile .buildkite/pipeline.yml; do [ -e "$f" ] && echo "$f"; done || true)"

env_files="$(find_files -name '.env' -o -name '.env.*' | grep -v '\.example$' || true)"
env_gitignored=false
if [ -f .gitignore ] && grep -Eq '^\s*/?\.env' .gitignore; then env_gitignored=true; fi
env_dockerignored=false
if [ -f .dockerignore ] && grep -Eq '^\s*/?\.env' .dockerignore; then env_dockerignored=true; fi

cat <<JSON
{
  "root": "$(json_escape "$(pwd)")",
  "languages": $(printf '%s' "$languages" | json_array),
  "manifests": {
    "js": $(printf '%s' "$node_manifests" | json_array),
    "python": $(printf '%s' "$python_manifests" | json_array),
    "go": $(printf '%s' "$go_manifests" | json_array),
    "jvm": $(printf '%s' "$jvm_manifests" | json_array),
    "rust": $(printf '%s' "$rust_manifests" | json_array)
  },
  "packageManagers": {
    "js": $js_pm,
    "python": $py_pm,
    "jvm": $jvm_tool
  },
  "lockfiles": $(printf '%s' "$lockfiles" | json_array),
  "containers": {
    "dockerfiles": $(printf '%s' "$dockerfiles" | json_array),
    "compose": $(printf '%s' "$compose_files" | json_array),
    "dockerignore": $(exists .dockerignore),
    "trivyignore": $(exists .trivyignore)
  },
  "ci": {
    "githubWorkflows": $(printf '%s' "$workflows" | json_array),
    "other": $(printf '%s' "$other_ci" | json_array)
  },
  "dependencyUpdates": {
    "dependabot": $(first_existing .github/dependabot.yml .github/dependabot.yaml),
    "renovate": $(first_existing renovate.json renovate.json5 .renovaterc .renovaterc.json .github/renovate.json .github/renovate.json5)
  },
  "governance": {
    "codeowners": $(first_existing .github/CODEOWNERS CODEOWNERS docs/CODEOWNERS),
    "securityPolicy": $(first_existing SECURITY.md .github/SECURITY.md docs/SECURITY.md)
  },
  "scanners": {
    "socket": $(first_existing socket.yml socket.yaml),
    "semgrep": $(first_existing .semgrep.yml .semgrep.yaml .semgrep),
    "cargoDeny": $(first_existing deny.toml)
  },
  "secrets": {
    "envFiles": $(printf '%s' "$env_files" | json_array),
    "envGitignored": $env_gitignored,
    "envDockerignored": $env_dockerignored
  }
}
JSON
