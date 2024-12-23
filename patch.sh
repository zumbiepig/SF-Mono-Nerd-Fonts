#!/bin/zsh

set -euo pipefail

if ! [[ "$OSTYPE" == 'darwin'* ]]; then
  echo 'Please run this script on MacOS'
  exit 1
fi

if ! command -v fontforge &>/dev/null; then
  echo 'Please install fontforge by running \`brew install fontforge\`'
  exit 1
fi

TMPDIR="$(mktemp -d)"

curl -o "$TMPDIR/installer.dmg" https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg

hdiutil attach -mountpoint "$TMPDIR/installer" "$TMPDIR/installer.dmg"
pkgutil --expand-full "$TMPDIR/installer/SF Mono Fonts.pkg" "$TMPDIR/package"
hdiutil detach "$TMPDIR/installer"

cp -r "$TMPDIR/package/SFMonoFonts.pkg/Payload/Library/Fonts" "$TMPDIR/fonts"

curl -Lo "$TMPDIR/patcher.zip" 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FontPatcher.zip'
unzip -d "$TMPDIR/patcher" "$TMPDIR/patcher.zip"

for i in "$TMPDIR/fonts/"*; do
  fontforge -script "$TMPDIR/patcher/font-patcher" -out "$PWD" --complete "$i" &
done

wait
rm -rf "$TMPDIR"
