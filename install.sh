#!/bin/sh
# huntbot installer
# curl -fsSL https://matador.indiesecurity.com/huntbot/install.sh | sh
set -e

RELEASE_URL="https://github.com/Matador-og/huntbot/releases/latest/download"
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

download() {
    DOWNLOAD_URL="${RELEASE_URL}/${BINARY}"

    info "Downloading huntbot for ${PLATFORM}-${ARCH}..."

    TMPDIR=$(mktemp -d)
    TMPFILE="${TMPDIR}/${BINARY_NAME}"

    if command -v curl > /dev/null 2>&1; then
        HTTP_CODE=$(curl -fsSL -w '%{http_code}' -o "$TMPFILE" "$DOWNLOAD_URL" 2>/dev/null || echo "000")
    elif command -v wget > /dev/null 2>&1; then
        wget -q -O "$TMPFILE" "$DOWNLOAD_URL" 2>/dev/null && HTTP_CODE="200" || HTTP_CODE="000"
    else
        error "Neither curl nor wget found. Install one and try again."
    fi

    if [ "$HTTP_CODE" != "200" ] || [ ! -s "$TMPFILE" ]; then
        rm -rf "$TMPDIR"
        error "Download failed (HTTP ${HTTP_CODE}).
  URL: ${DOWNLOAD_URL}
  Check https://github.com/Matador-og/huntbot/releases for available binaries."
    fi

    chmod +x "$TMPFILE"
}

install() {
    mkdir -p "$INSTALL_DIR"

    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        info "Updating existing installation..."
    fi

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

    # Make it available in the current session immediately
    export PATH="${INSTALL_DIR}:$PATH"
}

verify() {
    if [ ! -x "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        error "Installation verification failed — binary not executable"
    fi

    INSTALLED_VERSION=$(huntbot --version 2>&1 || true)
    if echo "$INSTALLED_VERSION" | grep -q "huntbot"; then
        success "${INSTALLED_VERSION} installed successfully!"
    else
        success "Installed to ${INSTALL_DIR}/${BINARY_NAME}"
        if [ -n "$INSTALLED_VERSION" ]; then
            warn "Note: ${INSTALLED_VERSION}"
        fi
    fi
}

main() {
    printf "\n"
    printf "  ${BOLD}huntbot${RESET} installer\n"
    printf "  Autonomous bug bounty hunting pipeline\n"
    printf "\n"

    detect_platform
    info "Platform: ${PLATFORM}-${ARCH}"

    download
    install
    ensure_path
    verify

    # Check if huntbot is on PATH right now
    if ! command -v huntbot > /dev/null 2>&1; then
        printf "\n"
        warn "To start using huntbot, run:"
        printf "    ${BOLD}source ~/.bashrc${RESET}  ${YELLOW}# or restart your terminal${RESET}\n"
    fi

    printf "\n"
    printf "  ${BOLD}Get started:${RESET}\n"
    printf "    huntbot setup              Install dependencies\n"
    printf "    huntbot init <target>      Create a workspace\n"
    printf "    huntbot auto <target>      Start hunting\n"
    printf "\n"
}

main
