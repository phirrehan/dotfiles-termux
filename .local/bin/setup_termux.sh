#!/usr/bin/env bash
#
# setup_termux.sh
#
# Bootstrap the Termux host and install Arch Linux ARM through proot-distro.
#
# Responsibilities:
#   - Install Termux packages
#   - Install/configure Termux:X11
#   - Install PulseAudio
#   - Configure Termux storage
#   - Configure Termux widgets
#   - Install JetBrainsMono Nerd Font
#   - Install Arch Linux ARM
#   - Run setup_proot.sh inside Arch
#
# Run from the repository root:
#
#   ./scripts/setup_termux.sh
#
# The Termux:X11 Android application must be installed separately.
# The companion Termux package is installed by this script.
#

set +e

########################
#### Configuration #####
########################

ARCH_NAME="archlinux"

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
    printf '    WARN: %s failed (exit %d), continuing\n' \
      "$label" "$rc" >&2
  fi
}

########################
#### Termux packages ###
########################

install_termux_packages() {
  pkg update

  pkg install -y \
    proot-distro \
    git \
    curl \
    unzip \
    termux-api

  # Termux:X11 repository and companion package.
  pkg install -y x11-repo
  pkg install -y termux-x11-nightly

  # Audio server used by applications running inside Arch/XFCE.
  pkg install -y pulseaudio
}

########################
#### Termux settings ###
########################

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
  local source="$HOME/dotfiles-termux/.local/bin"
  local target="$HOME/.shortcuts"

  mkdir -p "$target"

  if [ ! -d "$source" ]; then
    echo "    widget source not found: $source"
    echo "    skipping widget setup"
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
#### Arch installation #
########################

arch_installed() {
  proot-distro login "$ARCH_NAME" -- true >/dev/null 2>&1
}

install_arch() {
  if arch_installed; then
    echo "    Arch Linux already installed, skipping"
    return 0
  fi

  proot-distro install danhunsaker/archlinuxarm
}

########################
#### Arch setup ########
########################

run_proot_setup() {
  local repo_dir="$1"
  local setup_script="$repo_dir/scripts/setup_proot.sh"

  if [ ! -f "$setup_script" ]; then
    echo "    setup_proot.sh not found:"
    echo "    $setup_script"
    return 1
  fi

  echo
  echo "========================================"
  echo " Entering Arch Linux"
  echo "========================================"

  #
  # --shared-tmp is required so that Arch can access
  # the Termux:X11 socket and PulseAudio runtime.
  #

  proot-distro login "$ARCH_NAME" \
    --shared-tmp \
    -- \
    env \
    DOTFILES_REPO_DIR="$repo_dir" \
    DISPLAY=":0" \
    PULSE_SERVER="127.0.0.1" \
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

if arch_installed; then
  step "Configure Arch Linux" \
    run_proot_setup "$REPO_DIR"
else
  echo
  echo "WARN: Arch Linux does not appear to be installed."
  echo "      Run setup_termux.sh again after fixing the problem."
fi

cat <<'EOF'

========================================
 Termux setup complete
========================================

Enter Arch manually:

  proot-distro login archlinux --shared-tmp

Start XFCE:

  ./scripts/start_xfce.sh

If any step logged a WARN above, fix the
problem and run setup_termux.sh again.
EOF
