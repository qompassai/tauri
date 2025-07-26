#!/bin/sh
# ~/.local/share/qompassai/tauri/quickstart.sh
# Qompass AI Tauri Quick Start - Interactive
# Copyright (C) 2025 Qompass AI

set -eu
IFS=' 	
'
LOCAL_PREFIX="$HOME/.local"
BIN_DIR="$LOCAL_PREFIX/bin"
CONFIG_DIR="$HOME/.config/qompassai/tauri"
DATA_DIR="$HOME/.local/share/qompassai/tauri"
RUST_QUICKSTART="$HOME/.local/share/qompassai/rust/quickstart.sh"

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$DATA_DIR"

# Update path in current session
case ":$PATH:" in
*":$BIN_DIR:"*) ;;
*) PATH="${BIN_DIR}:$PATH" ;;
esac
export PATH
symlink_or_note() {
	tool="$1"
	if ! command -v "$tool" >/dev/null 2>&1; then
		if [ -x "/usr/bin/$tool" ]; then
			ln -sf "/usr/bin/$tool" "$BIN_DIR/$tool"
			echo " → Added symlink for $tool to $BIN_DIR"
		else
			echo "$tool" >>"$DATA_DIR/missing-tools.tmp"
		fi
	fi
}
check_base_prerequisites() {
	TOOLS="git curl tar make node npm"
	rm -f "$DATA_DIR/missing-tools.tmp"
	for t in $TOOLS; do
		symlink_or_note "$t"
	done
	if [ -s "$DATA_DIR/missing-tools.tmp" ]; then
		echo "⚠ Missing tools: $(cat $DATA_DIR/missing-tools.tmp | xargs)"
		echo "Install them using your system package manager and re-run."
		rm -f "$DATA_DIR/missing-tools.tmp"
		exit 1
	fi
}
add_path_to_shell_rc() {
	rcfile=$1
	line="export PATH=\"$BIN_DIR:\$PATH\""
	if [ -f "$rcfile" ] && ! grep -qF "$line" "$rcfile"; then
		printf '\n# Added by Qompass AI Tauri quickstart\n%s\n' "$line" >>"$rcfile"
		echo " → Added PATH to $rcfile"
	fi
}
run_rust_quickstart() {
	if ! command -v rustup >/dev/null 2>&1 || ! command -v cargo >/dev/null 2>&1; then
		echo "⚠ Rust not found. Using Rust quickstart..."
		if [ -x "$RUST_QUICKSTART" ]; then
			sh "$RUST_QUICKSTART"
		else
			echo "❌ Rust quickstart not found at $RUST_QUICKSTART"
			echo "Install Rust manually from https://rustup.rs/"
			exit 1
		fi
	else
		echo "✅ Rust already installed"
	fi
}
check_node_npm() {
	echo "==> Checking Node.js & npm..."
	if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
		echo "✅ Node.js & npm are available"
	else
		echo "❌ Node.js or npm is not installed."
		echo "Visit https://nodejs.org/ to install the LTS release."
		exit 1
	fi
}
install_tauri_cli() {
	if ! command -v tauri >/dev/null 2>&1; then
		echo "==> Installing Tauri CLI via npm"
		npm install -g @tauri-apps/cli
		echo "✅ Tauri CLI installed"
	else
		echo "✅ Tauri CLI already installed"
	fi
}
main_menu() {
	printf '╭─────────────────────────────────────────────╮\n'
	printf '│          Qompass AI · Tauri Setup           │\n'
	printf '╰─────────────────────────────────────────────╯\n'
	printf '       © 2025 Qompass AI. All rights reserved\n\n'
	printf ' Choose what to do:\n'
	printf ' 1) Install Rust using Rust Quickstart\n'
	printf ' 2) Check for Node/npm\n'
	printf ' 3) Install Tauri CLI\n'
	printf ' a) Run all steps (Rust + Node/npm + Tauri)\n'
	printf ' q) Quit\n\n'
	printf 'Your choice [a]: '
	read -r choice
	case "$choice" in
	'' | 'a' | 'A')
		run_all_steps
		;;
	1)
		run_rust_quickstart
		;;
	2)
		check_node_npm
		;;
	3)
		install_tauri_cli
		;;
	q | Q)
		echo "Exiting."
		exit 0
		;;
	*)
		echo "❌ Invalid choice."
		main_menu
		;;
	esac
}
run_all_steps() {
	check_base_prerequisites
	run_rust_quickstart
	check_node_npm
	install_tauri_cli
	echo
	echo "🎉 Tauri quickstart complete!"
	echo "→ Recommended: Restart your terminal or run:"
	echo "   export PATH=\"$BIN_DIR:\$PATH\""
}
main() {
	check_base_prerequisites
	main_menu
}
main "$@"
