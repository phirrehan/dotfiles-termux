#!/usr/bin/env bash
#
# setup_proot.sh
#
# Configure Arch Linux running inside Termux/proot-distro.
#
# Responsibilities:
#   - Configure pacman for proot
#   - Install CLI packages
#   - Install XFCE
#   - Install X11/desktop dependencies
#   - Stow dotfiles
#   - Install/configure zinit + zsh
#   - Install/configure tmux + TPM
#   - Provision Neovim
#   - Configure Yazi
#
# Normally invoked by setup_termux.sh.
#
# Can also be run manually from inside Arch:
#
#   ./scripts/setup_proot.sh
#

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
    printf '    WARN: %s failed (exit %d), continuing\n' \
      "$label" "$rc" >&2
  fi
}

########################
#### Pacman ############
########################

configure_pacman() {
  #
  # PRoot cannot provide all Linux namespace/sandbox functionality.
  # Disable pacman's sandbox so package installation works reliably.
  #

  if grep -qE '^[[:space:]]*DisableSandbox[[:space:]]*$' \
    /etc/pacman.conf; then

    echo "    pacman sandbox already disabled"
    return 0
  fi

  printf '\nDisableSandbox\n' >>/etc/pacman.conf
}

########################
#### Packages ##########
########################

install_packages() {
  pacman -Syu --noconfirm

  pacman -S --needed --noconfirm \
    git \
    stow \
    zsh \
    curl \
    neovim \
    fastfetch \
    tmux \
    yazi \
    fzf \
    fd \
    ffmpeg \
    pdftk \
    pdfgrep \
    7zip \
    unrar \
    unzip \
    python \
    go \
    rust \
    nodejs \
    npm
}

install_xfce() {
  #
  # Termux:X11 is the actual X server.
  # We therefore do NOT install a traditional Xorg server.
  #
  # dbus is required for a proper XFCE desktop session.
  #

  pacman -S --needed --noconfirm \
    xfce4 \
    xfce4-goodies \
    dbus \
    xorg-xinit \
    xorg-xauth
}

########################
#### Dotfiles ##########
########################

get_repo_dir() {
  if [ -n "${DOTFILES_REPO_DIR:-}" ]; then
    printf '%s\n' "$DOTFILES_REPO_DIR"
    return 0
  fi

  local script_dir

  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

  printf '%s\n' "$(dirname -- "$script_dir")"
}

stow_dotfiles() {
  local repo_dir="$1"

  if [ ! -d "$repo_dir" ]; then
    echo "    repository not found: $repo_dir"
    return 1
  fi

  echo "    repository: $repo_dir"
  echo "    target:     $HOME"

  stow \
    --restow \
    --target="$HOME" \
    --dir="$repo_dir" \
    .
}

########################
#### zsh / zinit #######
########################

setup_zinit() {
  local zinit_dir="$HOME/.local/share/zinit/zinit.git"

  if [ -d "$zinit_dir" ]; then
    echo "    zinit already present, skipping"
    return 0
  fi

  mkdir -p "$(dirname "$zinit_dir")"

  git clone \
    https://github.com/zdharma-continuum/zinit.git \
    "$zinit_dir"
}

setup_default_shell() {
  local zsh_path

  zsh_path="$(command -v zsh)" || {
    echo "    zsh not installed, skipping"
    return 1
  }

  if [ "${SHELL:-}" = "$zsh_path" ]; then
    echo "    default shell already zsh, skipping"
    return 0
  fi

  chsh -s "$zsh_path"
}

########################
#### tmux / TPM ########
########################

setup_tpm() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"

  if [ ! -d "$tpm_dir" ]; then
    mkdir -p "$(dirname "$tpm_dir")"

    git clone \
      https://github.com/tmux-plugins/tpm \
      "$tpm_dir" || return 1
  else
    echo "    tpm already present, skipping clone"
  fi

  "$tpm_dir/bin/install_plugins"
}

########################
#### Neovim ############
########################

nvim_lazy_sync() {
  nvim --headless "+Lazy! sync" +qa
}

nvim_mason_install() {
  nvim --headless \
    -c "autocmd User MasonToolsUpdateCompleted quitall" \
    -c "MasonToolsInstall"
}

nvim_treesitter_install() {
  nvim --headless "+TSInstallSync all" +qa
}

########################
#### Yazi ##############
########################

setup_yazi_theme() {
  ya pkg add yazi-rs/flavors:catppuccin-mocha || return 1

  mkdir -p "$HOME/.config/yazi"

  cat >"$HOME/.config/yazi/theme.toml" <<'EOF'
[flavor]
dark = "catppuccin-mocha"
EOF
}

########################
#### XFCE ##############
########################

setup_xfce_environment() {
  local env_dir="$HOME/.config/environment.d"

  mkdir -p "$env_dir"

  cat >"$env_dir/xfce.conf" <<'EOF'
DISPLAY=:0
PULSE_SERVER=127.0.0.1
XDG_RUNTIME_DIR=/tmp
LIBGL_ALWAYS_SOFTWARE=1
EOF
}

setup_xfce_launcher() {
  local bin_dir="$HOME/.local/bin"

  mkdir -p "$bin_dir"

  cat >"$bin_dir/xfce-session" <<'EOF'
#!/usr/bin/env bash

export DISPLAY="${DISPLAY:-:0}"
export PULSE_SERVER="${PULSE_SERVER:-127.0.0.1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"

exec dbus-run-session startxfce4
EOF

  chmod +x "$bin_dir/xfce-session"
}

########################
#### Main ##############
########################

REPO_DIR="$(get_repo_dir)"

echo "dotfiles: Arch/proot setup"
echo "repo:     $REPO_DIR"
echo "home:     $HOME"

if [ ! -f "$REPO_DIR/scripts/setup_proot.sh" ]; then
  echo
  echo "ERROR: Cannot find setup_proot.sh:"
  echo "       $REPO_DIR/scripts/setup_proot.sh"
  exit 1
fi

step "Configure pacman for proot" \
  configure_pacman

step "Install Arch packages" \
  install_packages

step "Install XFCE + X11 dependencies" \
  install_xfce

step "Stow dotfiles into $HOME" \
  stow_dotfiles "$REPO_DIR"

step "Install zinit" \
  setup_zinit

step "Set zsh as default shell" \
  setup_default_shell

step "Install tpm + tmux plugins" \
  setup_tpm

step "neovim: sync lazy plugins" \
  nvim_lazy_sync

step "neovim: MasonToolsInstall" \
  nvim_mason_install

step "neovim: TSInstallSync all" \
  nvim_treesitter_install

step "Configure XFCE environment" \
  setup_xfce_environment

step "Create XFCE session launcher" \
  setup_xfce_launcher

step "Install Yazi catppuccin theme" \
  setup_yazi_theme

cat <<'EOF'

========================================
 Arch setup complete
========================================

Enter Arch from Termux:

  proot-distro login archlinux --shared-tmp

Start XFCE:

  xfce-session

Or from Termux:

  ./scripts/start_xfce.sh

If any step logged a WARN above, fix the
problem and run setup_proot.sh again.
EOF
