# My dotfiles
This repository contains the dotfiles for both my desktop and termux. It uses Arch Linux package manager pacman and for termux it uses pkg. If you have a different linux distribution, replace pacman with your distribution's package manager. Note: in case of termux environment, both pkg or apt can be used 

## Requirements

Ensure you have git and stow installed:

```
sudo pacman -Sy
sudo pacman -S git stow --needed
```

These dotfiles contains configurations for `zsh`, `neovim`, `tmux`, `foot` and `clang`. Install these applications for using my dotfiles:

```
sudo pacman -S zsh neovim tmux foot clang --needed
```
## Cloning Repository

Clone this repository to your `$HOME` directory
```
cd ~
git clone --recurse-submodules https://github.com/phirrehan/dotfiles.git
```
## Setting up Symlinks

Use stow to create sym links from `$HOME/dotfiles` to `$HOME`, `$HOME/.local/bin` and `$HOME/.config/` to setup configurations and scripts.

```
cd dotfiles
stow .
```

## Change Shell to Zsh

Change your default shell to zsh by using:
```
chsh -s $(which zsh)
```

## Setting a Nerd Font

This font is useful for nvim and tmux configurations. If you do not need those, you can skip this step. Install a nerd font of your choice. I personally like to use `JetBrainsMono` Nerd font.

```
sudo pacman -S ttf-jetbrains-mono-nerd
```

## Setting Up Zsh

Use the following command to source .zshrc file

```
source ~/.zshrc
```

This will install zinit(plugin manager for zsh) which will further install various plugins. This may take time on the first source or new zsh session. Finally, after all installations the zsh configurations will be setup.

## Setting up Tmux

Install the Tmux Plugin Manager(TPM) for installing tmux plugins.

```
git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm
```

While inside a tmux environment, run the following command

```
tmux source ~/.config/tmux/tmux.conf
```

Press `prefix` + <kbd>I</kbd> (capital i, as in **I**nstall) to fetch the plugin

> By default the prefix in tmux is `ctrl` + <kbd>b</kbd>

> I have set up the prefix tmux.conf as `ctrl` + <kbd>space</kbd>

## Setting up Neovim

Neovim will lazy load everything when it is opened for the first time. It may take some time in the first launch. Note: nvim is set as alias for vim. If you want to use the base vim, remove the alias from ~/.config/zsh/aliasrc file.

## Scripts

All the scripts are located in ~/.local/bin which is added to PATH variable in .zprofile. Thus writing the full path of a script in this directory is not needed. For example, for executing ~/.local/bin/run the path can be omitted and be directly written as run.

## Termux Setup

### Clean Login

To stop the text from appearing in termux startup, create a .hushlogin file at home directory.

```
touch ~/.hushlogin
```

### Storage Setup

Setup phone storage in termux.

```
termux-setup-storage
```

This creates a ~/storage directory. This directory contains symlinks to phone's internal storage's important directories like downloads, dcim, movies, music, pictures, and lastly shared.

### Termux:API

Most of the useful scripts use a termux package called `Termux:API`. Install this using pkg for a funtional experience.

```
pkg update && pkg install termux-api
```

Take a look at the [official documentation](https://wiki.termux.com/wiki/Termux:API) of `Termux:API` for a list of things this package can do.

### Termux:Widget

To add a widget of termux in phone's launcher, install `Termux:Widget` from F-droid. It displays a list of scripts stored in ~/.shortcuts which can be run with the press of a button. Copy ~/dotfiles/.shortcuts/ over to home directory.

> Note: symlink to home does not work.

```
cp -r ~/dotfiles/.shortcuts/ ~/
```

### Termux:Tasker

Termux-tasker is yet another plugin which connects termux with a third-party tasker app. This can be the infamous tasker or some other applicatoin like macro droid. It can be very useful for automation.

### Package Manager

Using termux's package manager(apt, pkg) can be slow and monotonous to the eyes. For this case a wrapper is used instead which is called nala. Install nala with pkg and start using it.

```
pkg update && pkg install nala
```

As typing on phone can be tedious, it is recommended to make short aliases in .zshrc. I have made a few important aliases which can be found in ~/dotfiles/.config/zsh/aliases file. Be sure to take a look at them and not accidentally write a command.

After setting up termux, follow all the steps from the top to set up all the configurations. Use nala or pkg instead of pacman.

These were most of the general configurations I use. Hope you liked them and have a good day!
