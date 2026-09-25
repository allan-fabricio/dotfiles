# Dotfiles for Fedora Setup

Post-installation script focused on productivity for **Fedora Linux** with **KDE Plasma**. 

## 📦 What's included?

The script updates the system and installs/configures the following tools:

*   **[Ghostty](https://ghostty.org/)**: Modern and fast terminal emulator (installed via COPR). Includes a config file with the Dracula theme, JetBrainsMono Nerd Font, and KDE integrations.
*   **[Zsh](https://www.zsh.org/)**: Powerful and customizable shell, set as the default shell at the end of the execution.
*   **[Atuin](https://atuin.sh/)**: Magical shell history with cross-machine syncing, search, and context.
*   **[Starship](https://starship.rs/)**: Ultra-fast and customizable cross-shell prompt.
*   **[Eza](https://github.com/eza-community/eza)**: Modern, colored alternative to the classic `ls` command.
*   **[Mise](https://mise.jdx.dev/)**: Version manager for languages and tools (Rust-based alternative to asdf).
*   **[Chezmoi](https://www.chezmoi.io/)**: Secure and flexible dotfiles manager.

## How to use

1. Clone this repository or download the `setup-fedora.sh` script.
2. Make the script executable:
   ```bash
   chmod +x setup-fedora.sh
