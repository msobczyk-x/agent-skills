#!/usr/bin/env bash
# Install the Vercel React/React Native companion skills globally so
# pragmatic-review can delegate to them. Run only after the user approves.
set -euo pipefail

REPO="vercel-labs/agent-skills"
# Upstream directory names (not the SKILL.md `name` fields).
SKILLS=(react-best-practices react-native-skills composition-patterns)

for skill in "${SKILLS[@]}"; do
  echo "Installing ${skill} (global)..."
  npx --yes skills add "${REPO}" --skill "${skill}" --global
done

echo "Done. Installed: ${SKILLS[*]}"
