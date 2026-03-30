#!/usr/bin/env bash
set -euo pipefail

VERSION="${ASTERISK_VERSION:-current}"
WORKDIR="${BUILD_WORKDIR:-/opt/build}"
OUT_DIR="${OUT_DIR:-/out}"

mkdir -p "${OUT_DIR}"

/workspace/build-deb.sh --version "${VERSION}" --workdir "${WORKDIR}"

find "${WORKDIR}" -maxdepth 1 -type f \( \
  -name "*.deb" -o \
  -name "*.changes" -o \
  -name "*.buildinfo" -o \
  -name "*.dsc" -o \
  -name "*.tar.*" \
\) -exec cp -a {} "${OUT_DIR}/" \;

echo "Exported build artifacts to ${OUT_DIR}:"
ls -lh "${OUT_DIR}"
