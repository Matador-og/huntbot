#!/bin/sh
# huntbot installer
# curl -fsSL https://raw.githubusercontent.com/Matador-og/huntbot/master/install.sh | GITHUB_TOKEN=ghp_xxx sh
set -e

REPO="amine123ait/huntbot-dev"
INSTALL_DIR="${HUNTBOT_INSTALL_DIR:-$HOME/.local/bin}"
BINARY_NAME="huntbot"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

info() { printf "${BLUE}${BOLD}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
success() { printf "${GREEN}${BOLD}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
warn() { printf "${YELLOW}${BOLD}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
error() { printf "${RED}${BOLD}error:${RESET} %s\n" "$1" >&2; exit 1; }

detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    case "$OS" in
        Darwin) PLATFORM="darwin" ;;
        Linux)  PLATFORM="linux" ;;
        MINGW*|MSYS*|CYGWIN*) error "Windows is not supported. Use WSL instead." ;;
        *) error "Unsupported operating system: $OS" ;;
    esac

    case "$ARCH" in
        x86_64|amd64)  ARCH="x64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH" ;;
    esac

    BINARY="huntbot-${PLATFORM}-${ARCH}"
}

get_latest_version() {
    if [ -z "$GITHUB_TOKEN" ]; then
        error "GITHUB_TOKEN is required. Usage:
  curl -fsSL https://raw.githubusercontent.com/Matador-og/huntbot/master/install.sh | GITHUB_TOKEN=ghp_xxx sh"
    fi

    VERSION=$(curl -fsSL -H "Authorization: token ${GITHUB_TOKEN}" \
        "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null | \
        grep '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/' || echo "")

    if [ -z "$VERSION" ]; then
        error "Could not fetch latest release. Check your GITHUB_TOKEN has repo access."
    fi
}

download() {
    info "Downloading huntbot ${VERSION} for ${PLATFORM}-${ARCH}..."

    # Get asset download URL via GitHub API
    ASSET_ID=$(curl -fsSL -H "Authorization: token ${GITHUB_TOKEN}" \
        "https://api.github.com/repos/${REPO}/releases/tags/${VERSION}" 2>/dev/null | \
        grep -B 3 "\"name\": \"${BINARY}\"" | grep '"id"' | head -1 | \
        sed -E 's/.*"id": *([0-9]+).*/\1/' || echo "")

    if [ -z "$ASSET_ID" ]; then
        error "Could not find binary ${BINARY} in release ${VERSION}.
Available at: https://github.com/${REPO}/releases/tag/${VERSION}"
    fi

    TMPDIR=$(mktemp -d)
    TMPFILE="${TMPDIR}/${BINARY_NAME}"

    HTTP_CODE=$(curl -fsSL -w '%{http_code}' \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/octet-stream" \
        -o "$TMPFILE" \
        "https://api.github.com/repos/${REPO}/releases/assets/${ASSET_ID}" 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" != "200" ] || [ ! -s "$TMPFILE" ]; then
        rm -rf "$TMPDIR"
        error "Download failed (HTTP ${HTTP_CODE}). Check your GITHUB_TOKEN permissions."
    fi

    chmod +x "$TMPFILE"
}

install() {
    mkdir -p "$INSTALL_DIR"
    mv "$TMPFILE" "${INSTALL_DIR}/${BINARY_NAME}"
    rm -rf "$TMPDIR"
    success "Installed huntbot to ${INSTALL_DIR}/${BINARY_NAME}"
}

ensure_path() {
    case ":$PATH:" in
        *":${INSTALL_DIR}:"*) return ;;
    esac

    SHELL_NAME=$(basename "$SHELL")

    case "$SHELL_NAME" in
        zsh)  PROFILE="$HOME/.zshrc" ;;
        bash)
            if [ -f "$HOME/.bash_profile" ]; then PROFILE="$HOME/.bash_profile"
            elif [ -f "$HOME/.bashrc" ]; then PROFILE="$HOME/.bashrc"
            else PROFILE="$HOME/.profile"; fi ;;
        fish) PROFILE="$HOME/.config/fish/config.fish" ;;
        *)    PROFILE="$HOME/.profile" ;;
    esac

    if [ -n "$PROFILE" ] && [ -f "$PROFILE" ]; then
        if ! grep -q "$INSTALL_DIR" "$PROFILE" 2>/dev/null; then
            if [ "$SHELL_NAME" = "fish" ]; then
                printf "\n# huntbot\nfish_add_path %s\n" "$INSTALL_DIR" >> "$PROFILE"
            else
                printf "\n# huntbot\nexport PATH=\"%s:\$PATH\"\n" "$INSTALL_DIR" >> "$PROFILE"
            fi
            warn "Added ${INSTALL_DIR} to PATH in ${PROFILE}"
        fi
    fi
}

verify() {
    if [ -x "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        INSTALLED_VERSION=$("${INSTALL_DIR}/${BINARY_NAME}" --version 2>/dev/null || echo "unknown")
        success "${INSTALLED_VERSION} installed successfully!"
    else
        error "Installation verification failed"
    fi
}

main() {
    printf "\n"
    printf "  ${BOLD}huntbot${RESET} installer\n"
    printf "  Autonomous bug bounty hunting pipeline\n"
    printf "\n"

    detect_platform
    info "Platform: ${PLATFORM}-${ARCH}"

    get_latest_version
    info "Version: ${VERSION}"

    download
    install
    ensure_path
    verify

    printf "\n"
    printf "  ${BOLD}Get started:${RESET}\n"
    printf "    huntbot setup              Install dependencies\n"
    printf "    huntbot init <target>      Create a workspace\n"
    printf "    huntbot auto <target>      Start hunting\n"
    printf "\n"
}

main
