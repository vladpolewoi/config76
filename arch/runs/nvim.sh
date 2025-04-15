#!/bin/bash

set -e

echo "=-=-=-=- Installing Neovim v0.10.1 from source -=-=-=-="

sudo pacman -S --needed --noconfirm lua51 cmake base-devel ninja

echo "=-=-=-=- Clonning Neovim source -=-=-=-="

git clone https://github.com/neovim/neovim.git ~/neovim
cd ~/neovim
git checkout v0.10.1

echo "=-=-=-=- Building Neovim -=-=-=-="

make CMAKE_BUILD_TYPE=Release

echo "=-=-=-=- Installing Neovim -=-=-=-="

sudo make install

echo "=-=-=-=- Cleaning up -=-=-=-="

cd ~
rm -rf ~/neovim

echo "=-=-=-=- Neovim v0.10.1 installation complete -=-=-=-="
