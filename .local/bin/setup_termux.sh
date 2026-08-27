#!/usr/bin/env bash
#
# setup_termux - bootstrap the Termux environment for the Arch Linux setup.
#
# Installs Termux dependencies, configures Android/Termux integration,
# installs proot-distro + Arch Linux ARM, and copies setup_proot.sh into
# the freshly installed Arch environment.
#
# Run from the repository root:
#   ./.local/bin/setup_termux.sh
#

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

have() {
  command -v "$1" >/dev/null 2>&1
}

# step "Human label" cmd args...
#
# Runs a step and continues if it fails.
step() {
  local label="$1"
  shift

  printf '\n==> %s\n' "$label"

  if "$@"; then
    printf '    ok: %s\n' "$label"
  else
    local status=$?
    printf '    WARN: %s failed (exit %d), continuing\n' \
      "$label" "$status" >&2
  fi
}

###############
#### Steps ####
###############

install_packages() {
  pkg update

  pkg install -y \
    git \
    curl \
    unzip \
    proot-distro \
    termux-api \
    pulseaudio
}

setup_termux() {
  # Suppress the standard Termux login message.
  touch "$HOME/.hushlogin"

  # Request access to Android shared storage.
  termux-setup-storage

  # Install Termux:X11 companion package.
  if ! have termux-x11; then
    pkg install -y x11-repo
    pkg install -y termux-x11-nightly
  else
    echo "    Termux:X11 package already installed, skipping"
  fi

  # Install Termux:Widget scripts.
  mkdir -p "$HOME/.shortcuts"

  if [ -d "$REPO_DIR/.local/bin" ]; then
    cp -r "$REPO_DIR/.local/bin/." "$HOME/.shortcuts/"
  else
    echo "    .local/bin directory not found"
    return 1
  fi
}

install_nerd_font() {

  if [ -f "$HOME/.termux/font.ttf" ]; then
    echo "the font is already intalled"
    return 0
  fi

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  curl -fLo "$tmp_dir/JetBrainsMono.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

  unzip -q "$tmp_dir/JetBrainsMono.zip" \
    -d "$tmp_dir/JetBrainsMono"

  mkdir -p "$HOME/.termux"

  cp \
    "$tmp_dir/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf" \
    "$HOME/.termux/font.ttf"

  rm -rf "$tmp_dir"

  echo "    JetBrainsMono Nerd Font installed"
}

install_arch() {
  local arch_root="$PREFIX/var/lib/proot-distro/installed-rootfs/archlinux"

  if [ -d "$arch_root" ]; then
    echo "    Arch Linux rootfs already exists, skipping"
    return 0
  fi

  proot-distro install danhunsaker/archlinuxarm
}

copy_proot_setup_script() {
  local script="$REPO_DIR/.local/bin/setup_proot.sh"
  local arch_root="$PREFIX/var/lib/proot-distro/containers/archlinuxarm/rootfs"
  local target="$arch_root/tmp/setup_proot.sh"

  if [ ! -f "$script" ]; then
    echo "    setup_proot.sh not found: $script"
    return 1
  fi

  if [ ! -d "$arch_root" ]; then
    echo "    Arch Linux rootfs not found: $arch_root"
    return 1
  fi

  cp "$script" "$target"
  chmod +x "$target"

  echo "    copied setup_proot.sh to Arch:/tmp/setup_proot.sh"
}

###############
###### Run ####
###############

echo "Termux setup"
echo "repository: $REPO_DIR"

step "Install Termux packages" install_packages
step "Configure Termux" setup_termux
step "Install JetBrainsMono Nerd Font" install_nerd_font
step "Install Arch Linux ARM" install_arch
step "Copy setup_proot.sh into Arch" copy_proot_setup_script

cat <<'EOF'

Termux setup complete.

Next:

  1. Enter Arch Linux:

       proot-distro login archlinuxarm --shared-tmp

  2. Run the Arch setup:

       /tmp/setup_proot.sh

  3. After setup_proot.sh creates your normal user, exit Arch:

       exit

  4. Log back into Arch as your normal user:

       proot-distro login archlinux --user <username> --shared-tmp

  5. To start XFCE:

       ~/dotfiles-termux/.local/bin/start_xfce.sh

EOF
