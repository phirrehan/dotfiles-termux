#!/usr/bin/env bash
#
# setup_proot - bootstrap the Arch Linux ARM environment inside proot-distro.
#
# This script is intended to be run as root inside Arch Linux ARM.
#
# It:
#   - configures the Arch Linux ARM mirrors
#   - updates the system
#   - installs required packages
#   - creates a normal user
#   - grants the user sudo privileges
#   - clones and stows the dotfiles
#   - sets up zsh, zinit, tmux, neovim, yazi and XFCE
#
# The script is copied into Arch by setup_termux.sh:
#
#   /tmp/setup_proot.sh
#
# Run from the Arch environment:
#
#   /tmp/setup_proot.sh
#

set +e

DOTFILES_REPO="https://github.com/phirrehan/dotfiles-termux.git"
DOTFILES_DIR_NAME="dotfiles-termux"

have() {
  command -v "$1" >/dev/null 2>&1
}

# step "Human label" cmd args...
#
# Run command and warn instead of aborting.
step() {
  local label="$1"
  shift

  printf '\n==> %s\n' "$label"

  "$@"
  local status=$?

  if [ "$status" -eq 0 ]; then
    printf '    ok: %s\n' "$label"
  else
    printf '    WARN: %s failed (exit %d), continuing\n' \
      "$label" "$status" >&2
  fi
}

###############
#### Steps ####
###############

setup_mirrors() {
  cat >/etc/pacman.d/mirrorlist <<'EOF'
##
## Arch Linux ARM repository mirrorlist
##

## Geo-IP based mirror selection and load balancing
Server = http://mirror.archlinuxarm.org/$arch/$repo

## Germany
Server = http://de3.mirror.archlinuxarm.org/$arch/$repo
Server = http://de.mirror.archlinuxarm.org/$arch/$repo
Server = http://de4.mirror.archlinuxarm.org/$arch/$repo

## Taiwan
Server = http://tw2.mirror.archlinuxarm.org/$arch/$repo
Server = http://tw.mirror.archlinuxarm.org/$arch/$repo

## United States
Server = http://ca.us.mirror.archlinuxarm.org/$arch/$repo
Server = http://fl.us.mirror.archlinuxarm.org/$arch/$repo
Server = http://nj.us.mirror.archlinuxarm.org/$arch/$repo
EOF
}

configure_pacman() {
  local pacman_conf="/etc/pacman.conf"

  cat >"$pacman_conf" <<'EOF'
#
# /etc/pacman.conf
#
# See the pacman.conf(5) manpage for option and repository directives
#
# GENERAL OPTIONS
#
[options]
# The following paths are commented out with their default values listed.
# If you wish to use different paths, uncomment and update the paths.
#RootDir     = /
#DBPath      = /var/lib/pacman/
#CacheDir    = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg     = pacman glibc
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
#CleanMethod = KeepInstalled
Architecture = aarch64

# Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup
#IgnorePkg   =
#IgnoreGroup =

#NoUpgrade   =
#NoExtract   =

# Misc options
#UseSyslog
ILoveCandy
Color
#NoProgressBar
CheckSpace
#VerbosePkgLists
ParallelDownloads = 5
DownloadUser = alpm
DisableSandboxFilesystem
#DisableSandboxSyscalls

# By default, pacman accepts packages signed by keys that its local keyring
# trusts (see pacman-key and its man page), as well as unsigned packages.
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required

# NOTE: You must run `pacman-key --init` before first using pacman; the local
# keyring can then be populated with the keys of all official Arch Linux ARM
# packagers with `pacman-key --populate archlinuxarm`.

#
# REPOSITORIES
#
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[alarm]
Include = /etc/pacman.d/mirrorlist

[aur]
Include = /etc/pacman.d/mirrorlist

# An example of a custom package repository.
#[custom]
#SigLevel = Optional TrustAll
#Server = file:///home/custompkgs
EOF

  echo "    pacman.conf configured"
}

install_packages() {
  pacman -S --needed \
    git stow sudo \
    zsh curl \
    neovim fastfetch tmux yazi \
    fzf fd ffmpeg pdftk pdfgrep \
    7zip unrar unzip \
    python go rust nodejs npm \
    dbus \
    xfce4 xfce4-goodies \
    xorg-xinit xorg-xauth
}

create_user() {
  local username="${DOTFILES_USER:-}"

  if [ -z "$username" ]; then
    read -rp "Enter the Arch username to create: " username
  fi

  if [ -z "$username" ]; then
    echo "    No username supplied"
    return 1
  fi

  if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "    Invalid username: $username"
    return 1
  fi

  if id "$username" >/dev/null 2>&1; then
    echo "    User '$username' already exists, skipping creation"
  else
    useradd \
      --create-home \
      --groups wheel \
      --shell /bin/zsh \
      "$username"

    if [ $? -ne 0 ]; then
      return 1
    fi

    echo "    User '$username' created"

    echo
    echo "Set the password for '$username':"
    passwd "$username"

    if [ $? -ne 0 ]; then
      return 1
    fi
  fi

  DOTFILES_USER="$username"
  export DOTFILES_USER
}

setup_sudo() {
  local sudoers_file="/etc/sudoers.d/wheel"

  cat >"$sudoers_file" <<'EOF'
%wheel ALL=(ALL:ALL) ALL
EOF

  chmod 440 "$sudoers_file"

  # Validate sudoers configuration.
  visudo -cf /etc/sudoers

  if [ $? -ne 0 ]; then
    echo "    sudoers configuration is invalid"
    rm -f "$sudoers_file"
    return 1
  fi

  echo "    wheel group granted sudo privileges"
}

setup_dotfiles() {
  local username="$DOTFILES_USER"
  local user_home="/home/$username"
  local repo_dir="$user_home/$DOTFILES_DIR_NAME"

  if [ -d "$repo_dir/.git" ]; then
    echo "    dotfiles repository already present, skipping clone"
  else
    if [ -e "$repo_dir" ]; then
      echo "    $repo_dir exists but is not a git repository"
      return 1
    fi

    sudo -u "$username" git clone \
      "$DOTFILES_REPO" \
      "$repo_dir"

    if [ $? -ne 0 ]; then
      return 1
    fi
  fi

  chown -R "$username:$username" "$repo_dir"

  sudo -u "$username" bash -c "
    cd '$repo_dir' &&
    stow --restow --target='$user_home' .
  "
}

setup_zinit() {
  local username="$DOTFILES_USER"
  local user_home="/home/$username"
  local zinit_dir="$user_home/.local/share/zinit/zinit.git"

  if [ -d "$zinit_dir" ]; then
    echo "    zinit already present, skipping"
    return 0
  fi

  sudo -u "$username" mkdir -p \
    "$user_home/.local/share/zinit"

  sudo -u "$username" git clone \
    https://github.com/zdharma-continuum/zinit.git \
    "$zinit_dir"
}

setup_tpm() {
  local username="$DOTFILES_USER"
  local user_home="/home/$username"
  local tpm_dir="$user_home/.config/tmux/plugins/tpm"

  if [ ! -d "$tpm_dir" ]; then
    sudo -u "$username" mkdir -p \
      "$user_home/.config/tmux/plugins"

    sudo -u "$username" git clone \
      https://github.com/tmux-plugins/tpm \
      "$tpm_dir"
  else
    echo "    tpm already present, skipping clone"
  fi

  if [ -x "$tpm_dir/bin/install_plugins" ]; then
    sudo -u "$username" \
      "$tpm_dir/bin/install_plugins"
  else
    echo "    TPM install script not found"
    return 1
  fi
}

nvim_lazy_sync() {
  sudo -u "$DOTFILES_USER" \
    env HOME="/home/$DOTFILES_USER" \
    nvim --headless "+Lazy! sync" +qa
}

nvim_mason_install() {
  sudo -u "$DOTFILES_USER" \
    env HOME="/home/$DOTFILES_USER" \
    nvim --headless \
    -c "autocmd User MasonToolsUpdateCompleted quitall" \
    -c "MasonToolsInstall"
}

nvim_treesitter_install() {
  sudo -u "$DOTFILES_USER" \
    env HOME="/home/$DOTFILES_USER" \
    nvim --headless "+TSInstallSync all" +qa
}

setup_yazi_theme() {
  local username="$DOTFILES_USER"
  local user_home="/home/$username"
  local yazi_dir="$user_home/.config/yazi"

  sudo -u "$username" \
    env HOME="$user_home" \
    ya pkg add yazi-rs/flavors:catppuccin-mocha

  if [ $? -ne 0 ]; then
    return 1
  fi

  mkdir -p "$yazi_dir"

  cat >"$yazi_dir/theme.toml" <<'EOF'
[flavor]
dark = "catppuccin-mocha"
EOF

  chown "$username:$username" \
    "$yazi_dir/theme.toml"
}

setup_xfce() {
  local username="$DOTFILES_USER"
  local user_home="/home/$username"

  cat >"$user_home/.xinitrc" <<'EOF'
#!/bin/sh

export DISPLAY=:0

export XDG_CURRENT_DESKTOP=XFCE
export XDG_SESSION_DESKTOP=xfce
export XDG_CONFIG_DIRS=/etc/xdg/xdg-xfce:/etc/xdg
export XDG_DATA_DIRS=/usr/local/share:/usr/share

exec dbus-run-session startxfce4
EOF

  chmod +x "$user_home/.xinitrc"

  chown \
    "$username:$username" \
    "$user_home/.xinitrc"
}

###############
###### Run ####
###############

echo "Arch Linux ARM setup"

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: setup_proot.sh must be run as root."
  exit 1
fi

step "Configure Arch Linux ARM mirrors" \
  setup_mirrors

step "Configure pacman" configure_pacman

step "Update package database and system" \
  pacman -Syu

step "Install Arch packages" \
  install_packages

step "Create normal Arch user" \
  create_user

step "Configure sudo privileges" \
  setup_sudo

step "Clone and stow dotfiles" \
  setup_dotfiles

step "Install zinit" \
  setup_zinit

step "Install tpm + tmux plugins" \
  setup_tpm

step "neovim: sync lazy plugins" \
  nvim_lazy_sync

step "neovim: MasonToolsInstall" \
  nvim_mason_install

step "neovim: TSInstallSync all" \
  nvim_treesitter_install

step "Configure XFCE" \
  setup_xfce

step "Install Yazi catppuccin theme" \
  setup_yazi_theme

cat <<EOF

Setup complete.

Arch user:
  $DOTFILES_USER

Dotfiles:
  /home/$DOTFILES_USER/$DOTFILES_DIR_NAME

Enter Arch as your normal user from Termux:

  proot-distro login archlinux --user $DOTFILES_USER --shared-tmp

To start XFCE, exit Arch and run from Termux:

  ~/.local/bin/start_xfce.sh

EOF
