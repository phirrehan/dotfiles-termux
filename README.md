# My Termux Dotfiles

This repo is a fork of my `dotfiles` repo. It is made specifically for termux environment. Previously, both of them had a singluar repo. I have seperated them now because there were many conflicts and ambiguities in it.

> Note: This repo is for android terminal `termux`. If you want x86_64 architecture check the [dotfiles](https://github.com/phirrehan/dotfiles) repo instead.

# Requirements

Ensure you have git and stow installed:

```
pkg update
pkg install git stow --needed
```

These dotfiles contains configurations for `zsh`, `neovim`, `tmux`, `mpd`, and `rmpc`. Install these applications for using my dotfiles:

```
pkg install zsh neovim tmux mpd mpc rmpc
```

# Cloning Repository

Clone this repository to your `$HOME` directory

```
cd ~
git clone --recurse-submodules https://github.com/phirrehan/dotfiles-termux.git
```

# Setting up Symlinks

Use stow to create symbolic links from `$HOME/dotfiles-termux/` to `$HOME/` in exactly the same way as they appear in the former directory. e.g. `~/dotfiles-termux/.config/` will be symlinked to `~/.config`. Directories/Files like `.git` and `README.md` are ignored by stow

> Note: Any config files that conflict with the configurations of these `dotfiles`, should be backed up and removed to avoid errors.

```
cd dotfiles-termux
stow .
```

> Warning: Make sure that `~/.local`, `~/.config`, and `~/.cache` directories exist before running stow. Otherwise, These directories themselves will become symlinks. This is undesirable and should be prevented.

# Termux Setup

## Package Manager

Using termux's package manager(apt, pkg) can be slow and monotonous for the eyes. `nala` is a wrapper for apt and this will be used throughout the documentation. Install nala like so:

```
pkg update && pkg install nala
```

As typing on phone can be tedious, it is recommended to make short aliases in `.zshrc`. I have made a few important aliases which can be found in `~/dotfiles-termux/.config/zsh/aliases.zsh` file. Be sure to take a look at them and not accidentally write a command. Some useful aliases are:

| Alias | Function                       |
| ----- | ------------------------------ |
| i     | nala update && nala install $1 |
| rem   | nala remove $1                 |
| s     | nala search $1                 |
| u     | nala update && nala upgrade $1 |
| c     | clear                          |

> Note: $1 means the first argument of the alias. for examlple `s htop` means `nala search htop`

## Clean Login

To stop the text from appearing in termux startup, create a .hushlogin file at home directory.

```
touch ~/.hushlogin
```

## Storage Setup

Setup phone storage in termux.

```
termux-setup-storage
```

This creates a `./storage` directory. This directory contains symlinks to phone's internal storage's important directories like downloads, dcim, movies, music, pictures, and lastly shared.

## Termux:API

Most of the useful scripts use a termux package called `Termux:API`. Install this using nala for a funtional experience.

```
nala update && nala install termux-api
```

Take a look at the [official documentation](https://wiki.termux.com/wiki/Termux:API) of `Termux:API` for a list of things this package can do.

## Termux:Widget

To add a widget of termux in phone's launcher, install `Termux:Widget` from F-droid. It displays a list of scripts stored in `~/.shortcuts` which can be run with the press of a button. Copy `~/dotfiles-termux/.local/bin/` over to home directory.

> Note: symlink to home does not work.

```
cp -r ~/dotfiles-termux/.local/bin/ ~/.shortcuts
```

## Termux:Tasker

Termux-tasker is yet another plugin which connects termux with a third-party tasker app. This can be the infamous tasker or some other application like MacroDroid. It can be very useful for automation.

# Change Shell to Zsh

Change your default shell to zsh by using:

```
chsh -s $(which zsh)
```

# Setting a Nerd Font

This font is useful for nvim and tmux configurations. If you do not need those, you can skip this step. Install a nerd font of your choice. I personally like to use `JetBrainsMono` Nerd font.

```
curl -fLo JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
cp JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf
rm -rf JetBrainsMono
rm JetBrainsMono.zip
```

# Setting Up Zsh

Use the following command to source .zshrc file

```
source ~/.zshrc
```

This will install zinit(plugin manager for zsh) which will further install various plugins. This may take time on the first source or new zsh session. After all the installations, the zsh configurations will be setup.

# Setting up Tmux

While inside a tmux environment, run the following command

```
tmux source ~/.config/tmux/tmux.conf
```

Press `prefix` + <kbd>I</kbd> (capital i, as in **I**nstall) to fetch the plugin

> Prefix has been changed to `Ctrl` + <kbd>space</kbd> in `tmux.conf`

# Setting up Neovim

Neovim will lazy load everything when it is opened for the first time. It may take some time in the first launch.

# Scripts

All the scripts are located in `~/.local/bin` which is added to PATH environment variable in `.zprofile`. Thus, writing the full path of a script in this directory is not needed. For example, for executing `~/.local/bin/run` the path can be omitted and be directly written as `run`.

# Thank You

These were most of the general configurations I use. Hope you liked them and have a good day!
