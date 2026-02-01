#!/bin/bash

echo "📦 Installing Nemo file manager..."

sudo pacman -S --needed --noconfirm nemo nemo-fileroller

# Install gvfs for MTP, NFS, SMB support
sudo pacman -S --needed --noconfirm gvfs-mtp gvfs-nfs gvfs-smb

echo "✅ 'nemo' and file system support installed."
