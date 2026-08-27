# My Termux Dotfiles

This repository is a fork of my [`dotfiles`](https://github.com/phirrehan/dotfiles) repository, specifically designed for **Termux on Android**.

Previously, both environments shared a single repository. I separated them because the two environments had different requirements, which resulted in conflicts and ambiguities.

> **Note:** This repository is intended for **ARM-based Android devices running Termux**. If you want the regular x86_64 Arch Linux environment, see the [dotfiles](https://github.com/phirrehan/dotfiles) repository instead.

These dotfiles contain configurations for:

- `zsh`
- `neovim`
- `yazi`
- `tmux`
- `XFCE`

The setup uses:

- **Termux** as the Android host environment
- **proot-distro**
- **Arch Linux ARM**
- **Termux:X11**
- **PulseAudio**
- **XFCE**

The goal is to have a complete Arch Linux development environment running on Android while retaining access to Termux-specific functionality such as `Termux:API`, `Termux:Widget`, phone storage, and Termux:X11.

---

# Before Starting

## Install Termux

Install Termux from a supported source.

Do not mix Termux installations from different sources when using Termux plugins. Plugins such as Termux:X11, Termux:API and Termux:Widget need to be compatible with the installed Termux application.

---

## Install Termux:X11

Termux:X11 consists of two parts:

1. The Android application
2. The Termux companion package

Both are required.

Download and install the **Termux:X11 Android APK** from the official [Termux:X11 releases](https://github.com/termux/termux-x11/releases).

The setup script installs the Termux-side companion package automatically.

> **Note:** Termux:X11 requires Android 8 or newer.

See the official [Termux:X11 documentation](https://github.com/termux/termux-x11) for additional information and troubleshooting.

---

## Install Termux:API

Install the **Termux:API Android plugin** from the same compatible source as your Termux installation.

The Termux-side package is installed automatically by `setup_termux.sh`.

---

## Install Termux:Widget

If you want to use Termux widgets, install the **Termux:Widget Android plugin** from the same compatible source as your Termux installation.

---

# Setup Guide

Clone the repository into your Termux home directory:

```zsh
cd ~
git clone https://github.com/phirrehan/dotfiles-termux.git
cd ~/dotfiles-termux
```

Run the Termux setup:

```zsh
./.local/bin/setup_termux.sh
```

The Termux setup is responsible for configuring the Android/Termux side of the environment and installing Arch Linux ARM.

Arch Linux is installed using:

```zsh
proot-distro install danhunsaker/archlinuxarm
```

The setup script also copies the Arch setup script into Termux's shared temporary directory:

```text
/tmp/setup_proot.sh
```

This allows the script to be accessed from inside the Arch proot environment.

> **Important:** The Android Termux:X11 application must be installed manually before using the graphical desktop.

After `setup_termux.sh` completes, continue with the [Arch Linux Setup](#arch-linux-setup).

---

# Arch Linux Setup

The Arch environment is configured separately from Termux.

After `setup_termux.sh` has finished, enter Arch as root:

```zsh
proot-distro login archlinux --shared-tmp
```

The `--shared-tmp` option is important because Termux:X11 uses a Unix socket located in Termux's temporary directory. Sharing `/tmp` makes that socket available inside the Arch environment.

You should now see a root shell similar to:

```text
[root@localhost ~]#
```

The Termux setup has already copied `setup_proot.sh` into:

```text
/tmp/setup_proot.sh
```

Copy it into the root user's home directory:

```zsh
cp /tmp/setup_proot.sh /root/setup_proot.sh
```

Make it executable:

```zsh
chmod +x /root/setup_proot.sh
```

Then run it:

```zsh
/root/setup_proot.sh
```

Alternatively:

```zsh
bash /root/setup_proot.sh
```

---

# Entering Arch as the Normal User

After `setup_proot.sh` has completed, exit the root Arch environment:

```zsh
exit
```

Then enter Arch using the newly-created user:

```zsh
proot-distro login archlinux --user <username> --shared-tmp
```

You can now use Arch normally without logging in as root.

---

# Dotfiles

The Termux and Arch environments contain **separate clones** of this repository.

The Termux copy:

```text
~/dotfiles-termux
```

The Arch copy:

```text
/home/<username>/dotfiles-termux
```

These are independent Git repositories.

This is intentional.

Termux-specific configuration belongs to the Termux environment, while the normal shell, editor, terminal multiplexer, file manager, and desktop configuration is used inside Arch.

The automated setup performs this automatically.

---

# Termux Setup

## Package Manager

Termux uses `apt`/`pkg` for package management.

Install `nala`, a clean wrapper for apt:

```zsh
apt update
apt install nala
```

The setup scripts use `pkg` rather than `nala`.

Some useful aliases are defined in:

```text
~/dotfiles-termux/.config/zsh/aliases.zsh
```

Take a look at the aliases before using them.

---

# Termux:X11 + XFCE

The graphical environment uses:

```text
Android
│
└── Termux
    │
    ├── Termux:X11
    │
    ├── PulseAudio
    │
    └── proot-distro
        │
        └── Arch Linux ARM
            │
            └── XFCE
```

Termux:X11 provides the X server on Android while XFCE runs inside Arch Linux.

---

# PulseAudio

PulseAudio runs on the Termux host.

It provides audio support for applications running inside the Arch environment.

The XFCE startup script starts PulseAudio before launching the graphical session.

---

# Starting XFCE

Once the Arch setup is complete, XFCE can be started from Termux with:

```zsh
./.local/bin/start_xfce.sh
```

If `.local/bin` is in your `$PATH`, you can simply run:

```zsh
start_xfce.sh
```

---

# Starting Arch Manually

To enter Arch without starting XFCE:

```zsh
proot-distro login archlinux --user <username> --shared-tmp
```

Set the display:

```zsh
export DISPLAY=:0
```

Then start XFCE:

```zsh
dbus-run-session startxfce4
```

PulseAudio should be running in the Termux host before starting applications that require audio.

---

# Thank You

These are most of the general configurations I use on my Android/Termux setup.

Hope you find them useful and have a good day!
