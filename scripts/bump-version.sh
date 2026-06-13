#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <marketing-version>" >&2
  echo "Example: $0 0.2.0" >&2
  exit 1
fi

VERSION="$1"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/TokenBar.xcodeproj/project.pbxproj"

if [[ ! -f "$PROJECT_FILE" ]]; then
  echo "Could not find project file at $PROJECT_FILE" >&2
  exit 1
fi

CURRENT_BUILD="$(grep -m1 'CURRENT_PROJECT_VERSION =' "$PROJECT_FILE" | sed -E 's/.*= ([0-9]+);/\1/')"
NEXT_BUILD=$((CURRENT_BUILD + 1))

perl -pi -e "s/MARKETING_VERSION = [^;]+;/MARKETING_VERSION = ${VERSION};/g" "$PROJECT_FILE"
perl -pi -e "s/CURRENT_PROJECT_VERSION = [0-9]+;/CURRENT_PROJECT_VERSION = ${NEXT_BUILD};/g" "$PROJECT_FILE"

echo "Updated MARKETING_VERSION to ${VERSION}"
echo "Updated CURRENT_PROJECT_VERSION to ${NEXT_BUILD}"
