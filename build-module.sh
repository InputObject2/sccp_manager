#!/usr/bin/env bash
# Build FreePBX module package for sccp_manager
# Run from repo root: ./build-module.sh
# Output: dist/sccp_manager-<version>.tar.gz
set -euo pipefail

RAWNAME="sccp_manager"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get version from module.xml
VERSION="$(grep -oP '(?<=<version>)[^<]+' "${SCRIPT_DIR}/module.xml" | head -1)"
if [[ -z "$VERSION" ]]; then
  echo "ERROR: could not read version from module.xml" >&2
  exit 1
fi

DIST_DIR="${SCRIPT_DIR}/dist"
STAGE_DIR="${DIST_DIR}/${RAWNAME}"
ARCHIVE="${DIST_DIR}/${RAWNAME}-${VERSION}.tar.gz"

mkdir -p "$DIST_DIR"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

# Copy only tracked files to avoid packaging local temp files
git -C "$SCRIPT_DIR" ls-files | while IFS= read -r relpath; do
  [[ "$relpath" == "build-module.sh" ]] && continue
  [[ "$relpath" == "build-module.ps1" ]] && continue
  [[ "$relpath" == dist/* ]] && continue
  [[ "$relpath" == *.tar.gz ]] && continue
  [[ "$relpath" == *.zip ]] && continue
  src="${SCRIPT_DIR}/${relpath}"
  dst="${STAGE_DIR}/${relpath}"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
done

rm -f "$ARCHIVE"
tar -czf "$ARCHIVE" -C "$DIST_DIR" "$RAWNAME"
rm -rf "$STAGE_DIR"

echo "Built: $ARCHIVE"
echo "Version: $VERSION"
echo "Install in FreePBX: Admin -> Module Admin -> Upload Modules -> path to tar.gz or URL"
