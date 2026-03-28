#!/usr/bin/env bash
set -euo pipefail

# Build Asterisk .deb package from this packaging repository.
# Usage:
#   ./build-deb.sh
#   ./build-deb.sh --version 22.8-cert2 --workdir /opt/build --no-install-deps

VERSION="current"
WORKDIR="/opt/build"
INSTALL_DEPS=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --workdir)
      WORKDIR="$2"
      shift 2
      ;;
    --no-install-deps)
      INSTALL_DEPS=0
      shift
      ;;
    -h|--help)
      cat <<'EOF'
Usage: ./build-deb.sh [options]

Options:
  --version <ver>        Asterisk version to build (default: current)
  --workdir <dir>        Build workspace (default: /opt/build)
  --no-install-deps      Skip apt/contrib dependency installation
  -h, --help             Show this help
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${WORKDIR}/asterisk-${VERSION}"
TARBALL_URL="https://downloads.asterisk.org/pub/telephony/certified-asterisk/asterisk-certified-${VERSION}.tar.gz"

run_privileged() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    echo "Need root privileges for: $* (install sudo or run as root)" >&2
    exit 1
  fi
}

if [[ "${INSTALL_DEPS}" -eq 1 ]]; then
  run_privileged apt-get update
  run_privileged apt-get install -y \
    build-essential \
    devscripts \
    debhelper \
    dh-make \
    fakeroot \
    lintian \
    quilt \
    git \
    curl \
    subversion
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required" >&2
  exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
  echo "tar is required" >&2
  exit 1
fi

if ! command -v dpkg-buildpackage >/dev/null 2>&1; then
  echo "dpkg-buildpackage is required (install package: devscripts)" >&2
  exit 1
fi

mkdir -p "${SRC_DIR}"

if [[ -n "$(ls -A "${SRC_DIR}" 2>/dev/null)" ]]; then
  echo "Build directory is not empty: ${SRC_DIR}" >&2
  echo "Removing existing contents..." >&2
  rm -rf "${SRC_DIR}" && mkdir -p "${SRC_DIR}"
fi

echo "Downloading Asterisk ${VERSION}..."
curl -fsSL "${TARBALL_URL}" | tar --strip-components=1 -xz -C "${SRC_DIR}"

# Apply packaging from this repository.
rm -rf "${SRC_DIR}/debian"
cp -a "${SCRIPT_DIR}/debian" "${SRC_DIR}/debian"

chmod +x \
  "${SRC_DIR}/debian/asterisk.postinst" \
  "${SRC_DIR}/debian/asterisk.postrm"

# .install must be a plain data file; executable bit can make debhelper treat it as a script.
chmod 0644 "${SRC_DIR}/debian/asterisk.install"

if [[ "${INSTALL_DEPS}" -eq 1 ]]; then
#   run_privileged bash -lc "cd '${SRC_DIR}' && contrib/scripts/get_mp3_source.sh"
  run_privileged bash -lc "cd '${SRC_DIR}' && contrib/scripts/install_prereq install"
fi

echo "Building Debian package..."
cd "${SRC_DIR}"
dpkg-buildpackage -us -uc -b -d

echo
echo "Build completed. Packages are in:"
echo "  ${WORKDIR}"
