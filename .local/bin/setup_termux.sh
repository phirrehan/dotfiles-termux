#!/usr/bin/env bash
#
# setup_termux.sh
#
# Bootstrap Termux and install/configure an Arch Linux proot environment.
#
# Run this from the root of the dotfiles repository:
#
#   ./scripts/setup_termux.sh
#
# This script is responsible ONLY for the Termux host.
#
# Arch-specific configuration is handled by:
#
#   ./scripts/setup_proot.sh
#
# The repository remains on the Termux filesystem and is accessible
# from inside the Arch proot environment.

set +e

########################
#### Helpers ###########
########################

step() {
  local label="$1"
  shift

  printf '\n==> %s\n' "$label"

  if "$@"; then
    printf '    ok: %s\n' "$label"
  else
    local rc=$?
    printf '    WARN: %s failed (exit %d), continuing\n' "$label" "$rc" >&2
  fi
}

########################
#### Termux setup ######
########################

install_termux_packages() {
  pkg update

  pkg install -y \
    proot-distro \
    git \
    curl \
    unzip \
    termux-api
}

setup_hushlogin() {
  touch "$HOME/.hushlogin"
}

setup_storage() {
  if [ -d "$HOME/storage" ]; then
    echo "    Termux storage already configured, skipping"
    return 0
  fi

  termux-setup-storage
}

setup_widgets() {
  local source="$HOME/.local/bin"
  local target="$HOME/.shortcuts"

  mkdir -p "$target"

  if [ ! -d "$source" ]; then
    echo "    $source not found, skipping widget setup"
    return 1
  fi

  cp -r "$source/"* "$target/" 2>/dev/null
}

setup_font() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  echo "    downloading JetBrainsMono Nerd Font"

  if ! curl -fL \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
    -o "$tmp_dir/JetBrainsMono.zip"; then
    rm -rf "$tmp_dir"
    return 1
  fi

  if ! unzip -q \
    "$tmp_dir/JetBrainsMono.zip" \
    -d "$tmp_dir/JetBrainsMono"; then
    rm -rf "$tmp_dir"
    return 1
  fi

  mkdir -p "$HOME/.termux"

  cp \
    "$tmp_dir/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf" \
    "$HOME/.termux/font.ttf"

  rm -rf "$tmp_dir"
}

setup_termux() {
  setup_hushlogin
  setup_storage
  setup_widgets
  setup_font
}

########################
#### Arch / proot ######
########################

install_arch() {
  if proot-distro list 2>/dev/null | grep -q '^archlinux.*Installed'; then
    echo "    Arch Linux already installed, skipping"
    return 0
  fi

  proot-distro install archlinux
}

run_proot_setup() {
  local repo_dir="$1"

  if [ ! -f "$repo_dir/scripts/setup_proot.sh" ]; then
    echo "    setup_proot.sh not found:"
    echo "    $repo_dir/scripts/setup_proot.sh"
    return 1
  fi

  echo
  echo "========================================"
  echo " Entering Arch Linux"
  echo "========================================"

  proot-distro login archlinux -- \
    env DOTFILES_REPO_DIR="$repo_dir" \
    bash -lc '
      bash "$DOTFILES_REPO_DIR/scripts/setup_proot.sh"
    '
}

########################
#### Main ##############
########################

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname -- "$SCRIPT_DIR")"

echo "dotfiles: Termux setup"
echo "repo:     $REPO_DIR"

step "Install Termux packages" \
  install_termux_packages

step "Configure Termux" \
  setup_termux

step "Install Arch Linux" \
  install_arch

if proot-distro list 2>/dev/null | grep -q '^archlinux.*Installed'; then
  step "Configure Arch Linux" \
    run_proot_setup "$REPO_DIR"
else
  echo
  echo "WARN: Arch Linux does not appear to be installed."
  echo "      Run this script again after fixing the installation."
fi

cat <<'EOF'

========================================
 Termux setup complete
========================================

You can enter Arch manually with:

  proot-distro login archlinux

Or re-run:

  ./scripts/setup_termux.sh

The Arch-specific setup is handled by:

  ./scripts/setup_proot.sh
EOF
