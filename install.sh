#!/bin/sh
# Installs Top Bar GitHub Notifier (TBGN) for the current user, starts it at
# login, and (re)starts it now. Re-run after pulling changes to upgrade.
# `./install.sh --uninstall` removes everything this script and the app add.
set -eu

bin="$HOME/.local/bin/tbgn"
data="${XDG_DATA_HOME:-$HOME/.local/share}"
entry="$data/applications/tbgn.desktop"
autostart="${XDG_CONFIG_HOME:-$HOME/.config}/autostart/tbgn.desktop"
icons="$data/icons/hicolor/scalable/status"

pkill -x tbgn 2>/dev/null || true

if [ "${1:-}" = "--uninstall" ]; then
    rm -f "$bin" "$entry" "$autostart" "$icons/tbgn-symbolic.svg" "$icons/tbgn-unread-symbolic.svg"
    echo "Uninstalled TBGN."
    exit 0
fi

cd "$(dirname "$0")"
cargo build --release

mkdir -p "$(dirname "$bin")" "$(dirname "$entry")" "$(dirname "$autostart")"
install -m 755 target/release/tbgn "$bin"

desktop="[Desktop Entry]
Type=Application
Name=TBGN
GenericName=Top Bar GitHub Notifier
Comment=GitHub inbox notifications in the top bar
Exec=$bin
Icon=tbgn-symbolic
Terminal=false
Categories=Network;
X-GNOME-Autostart-enabled=true"
printf '%s\n' "$desktop" > "$entry"
printf '%s\n' "$desktop" > "$autostart"

nohup "$bin" >/dev/null 2>&1 &
echo "Installed $bin and started it."
