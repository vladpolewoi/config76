#!/bin/bash

# Document viewers: PDF (zathura), EPUB/MOBI (foliate), DOCX/XLSX/PPTX (libreoffice)

install_pkg() {
  local pkg=$1
  if ! pacman -Qi "$pkg" &>/dev/null; then
    echo "📦 '$pkg' not found. Installing..."
    sudo pacman -S --needed --noconfirm "$pkg"
    echo "✅ '$pkg' installed."
  else
    echo "✅ '$pkg' is already installed."
  fi
}

install_pkg zathura
install_pkg zathura-pdf-mupdf
install_pkg foliate
install_pkg libreoffice-fresh

set_mime() {
  local app=$1
  shift
  for mime in "$@"; do
    xdg-mime default "$app" "$mime"
  done
}

echo "🔗 Setting default applications..."

set_mime org.pwmt.zathura.desktop \
  application/pdf

set_mime com.github.johnfactotum.Foliate.desktop \
  application/epub+zip \
  application/x-mobipocket-ebook \
  application/x-fictionbook+xml

set_mime libreoffice-writer.desktop \
  application/vnd.openxmlformats-officedocument.wordprocessingml.document \
  application/msword \
  application/vnd.oasis.opendocument.text \
  application/rtf

set_mime libreoffice-calc.desktop \
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet \
  application/vnd.ms-excel \
  application/vnd.oasis.opendocument.spreadsheet

set_mime libreoffice-impress.desktop \
  application/vnd.openxmlformats-officedocument.presentationml.presentation \
  application/vnd.ms-powerpoint \
  application/vnd.oasis.opendocument.presentation

echo "✅ document viewers configured."
