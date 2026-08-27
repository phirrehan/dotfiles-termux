#!/usr/bin/env bash
#
# setup_proot.sh
#
# Configure Arch Linux running inside Termux/proot-distro.
#
# This script is intended to be executed INSIDE Arch Linux.
#
# It can also be run directly:
#
#   ./scripts/setup_proot.sh
#
# The dotfiles repository is expected to be accessible through:
#
#   $DOTFILES_REPO_DIR
#
# When invoked by setup_termux.sh, this variable is set automatically.

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
#### Package setup #####
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

########################
#### Dotfiles ##########
########################

get_repo_dir() {
  if [ -n "${DOTFILES_REPO_DIR:-}" ]; then
    printf '%s\n' "$DOTFILES_REPO_DIR"
    return 0
  fi

  #
  # If the script is run directly from the repository, resolve it normally.
  #
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
#### Main ##############
########################

REPO_DIR="$(get_repo_dir)"

echo "dotfiles: Arch/proot setup"
echo "repo:     $REPO_DIR"
echo "home:     $HOME"

if [ ! -f "$REPO_DIR/scripts/setup_proot.sh" ]; then
  echo
  echo "ERROR: Cannot find repository:"
  echo "       $REPO_DIR"
  exit 1
fi

step "Install Arch packages" \
  install_packages

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

step "Install Yazi catppuccin theme" \
  setup_yazi_theme

cat <<'EOF'

========================================
 Arch setup complete
========================================

To enter Arch:

  proot-distro login archlinux

Inside Arch:

  exec zsh
  tmux

If any step logged a WARN above, fix the
problem and run:

  ./scripts/setup_proot.sh
EOF
