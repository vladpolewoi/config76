#!/bin/bash

set -e

echo "=-=-=-=- Installing Neovim v0.11.5 from source -=-=-=-="

sudo pacman -S --needed --noconfirm lua51 cmake base-devel ninja ripgrep fzf jq

echo "=-=-=-=- Clonning Neovim source -=-=-=-="

git clone https://github.com/neovim/neovim.git ~/neovim
cd ~/neovim
git checkout v0.11.5

echo "=-=-=-=- Cleaning build cache and deps -=-=-=-="

rm -rf build .deps

echo "=-=-=-=- Building Neovim -=-=-=-="

make CMAKE_BUILD_TYPE=Release

echo "=-=-=-=- Installing Neovim -=-=-=-="

sudo make install

echo "=-=-=-=- Cleaning up -=-=-=-="

cd ~
rm -rf ~/neovim

echo "=-=-=-=- Neovim v0.11.5 installation complete -=-=-=-="
