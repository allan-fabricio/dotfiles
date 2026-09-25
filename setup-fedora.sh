#!/bin/bash
#
# setup-fedora.sh
# Script de pós-formatação para Fedora + KDE Plasma.
# Idempotente: pode ser rodado mais de uma vez sem duplicar trabalho.
#
# EDITE a linha abaixo antes de rodar, com a URL do seu repo de dotfiles:
DOTFILES_REPO="https://github.com/allan-fabricio/dotfiles.git"

set -uo pipefail

# ---------------------------------------------------------------------------
# Helpers de output
# ---------------------------------------------------------------------------
info() { echo -e "\e[34m[INFO]\e[0m $*"; }
ok()   { echo -e "\e[32m[OK]\e[0m   $*"; }
warn() { echo -e "\e[33m[AVISO]\e[0m $*"; }
err()  { echo -e "\e[31m[ERRO]\e[0m $*"; }

# ---------------------------------------------------------------------------
# 0. Atualização do sistema
# ---------------------------------------------------------------------------
info "Atualizando pacotes do sistema..."
sudo dnf upgrade -y

# ---------------------------------------------------------------------------
# 1. Ghostty (via COPR)
# ---------------------------------------------------------------------------
if command -v ghostty &>/dev/null; then
    warn "Ghostty já está instalado ($(ghostty --version | head -n1)). Pulando."
else
    info "Instalando Ghostty via COPR..."
    sudo dnf copr enable -y scottames/ghostty
    sudo dnf install -y ghostty
    ok "Ghostty instalado."
fi

GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/config"

if [ -f "$GHOSTTY_CONFIG_FILE" ]; then
    warn "Já existe um config do Ghostty em $GHOSTTY_CONFIG_FILE. Não vou sobrescrever."
else
    info "Criando config do Ghostty..."
    mkdir -p "$GHOSTTY_CONFIG_DIR"
    cat > "$GHOSTTY_CONFIG_FILE" << 'EOF'
# =========================
# Fonte
# =========================
font-family = "JetBrainsMono Nerd Font"
font-size = 13
adjust-cell-height = 5%
font-feature = -calt

# =========================
# Cursor
# =========================
cursor-style = bar
cursor-style-blink = false

# =========================
# Tema e aparência
# =========================
theme = Dracula
window-padding-x = 10
window-padding-y = 10
window-padding-balance = true
background-opacity = 0.95
background-blur = true

# =========================
# Janela / decoração (Linux/KDE)
# =========================
window-decoration = client
gtk-titlebar-style = tabs
window-save-state = default
window-show-tab-bar = auto

# =========================
# Comportamento da sessão
# =========================
confirm-close-surface = true
quit-after-last-window-closed = true
scrollback-limit = 50000
copy-on-select = true
clipboard-paste-protection = true

# =========================
# Shell integration
# =========================
shell-integration = detect
shell-integration-features = cursor,sudo,title
EOF
    ok "Config do Ghostty criado."
fi

# ---------------------------------------------------------------------------
# 2. Zsh
# ---------------------------------------------------------------------------
if rpm -q zsh &>/dev/null; then
    warn "Zsh já está instalado. Pulando."
else
    info "Instalando Zsh..."
    sudo dnf install -y zsh
    ok "Zsh instalado."
fi

# ---------------------------------------------------------------------------
# 3. Eza
# ---------------------------------------------------------------------------
if rpm -q eza &>/dev/null; then
    warn "Eza já está instalado. Pulando."
else
    info "Instalando Eza..."
    sudo dnf install -y eza
    ok "Eza instalado."
fi

# ---------------------------------------------------------------------------
# 4. Starship
# ---------------------------------------------------------------------------
if command -v starship &>/dev/null; then
    warn "Starship já está instalado ($(starship --version)). Pulando."
else
    info "Instalando Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    ok "Starship instalado."
fi

# ---------------------------------------------------------------------------
# 5. Mise
# ---------------------------------------------------------------------------
if command -v mise &>/dev/null; then
    warn "Mise já está instalado. Pulando."
else
    info "Instalando Mise..."
    curl https://mise.run | sh
    ok "Mise instalado."
fi

# ---------------------------------------------------------------------------
# 6. Atuin
# ---------------------------------------------------------------------------
if command -v atuin &>/dev/null; then
    warn "Atuin já está instalado. Pulando."
else
    info "Instalando Atuin..."
    curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh
    ok "Atuin instalado."
fi

# ---------------------------------------------------------------------------
# 7. Chezmoi + aplicação do repositório de dotfiles
# ---------------------------------------------------------------------------
if command -v chezmoi &>/dev/null; then
    warn "Chezmoi já está instalado. Pulando instalação."
else
    info "Instalando Chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)"
    ok "Chezmoi instalado."
fi

if [[ "$DOTFILES_REPO" == *SEU-USUARIO* ]]; then
    warn "DOTFILES_REPO ainda não foi configurado (edite o topo do script)."
    warn "Pulando 'chezmoi init --apply'. Rode manualmente depois:"
    warn "  chezmoi init --apply $DOTFILES_REPO"
else
    info "Aplicando dotfiles via Chezmoi ($DOTFILES_REPO)..."
    chezmoi init --apply "$DOTFILES_REPO"
    ok "Dotfiles aplicados."
fi

# ---------------------------------------------------------------------------
# 8. Trocar shell padrão para Zsh
# ---------------------------------------------------------------------------
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
ZSH_PATH="$(command -v zsh)"

if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    warn "Shell padrão já é o Zsh. Pulando."
else
    info "Trocando shell padrão para Zsh..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    ok "Shell padrão alterado. Vale efeito no próximo login."
fi

# ---------------------------------------------------------------------------
# Resumo final e passos manuais
# ---------------------------------------------------------------------------
echo ""
echo "======================================================================"
ok "Script concluído."
echo "======================================================================"
echo ""
warn "Passos MANUAIS que ainda faltam (não automatizados de propósito):"
echo ""
echo "  1) Definir Ghostty como terminal padrão do sistema:"
echo "     Configurações do Sistema > Aplicativos > Aplicativos Padrão >"
echo "     Emulador de Terminal > selecione Ghostty > Aplicar"
echo ""
echo "  2) Atalho Ctrl+Alt+T para o Ghostty:"
echo "     Configurações do Sistema > Teclado > Atalhos >"
echo "     Adicionar Novo Comando > digite 'ghostty' > defina Ctrl+Alt+T"
echo "     (e desative esse atalho no Konsole, pra não conflitar)"
echo ""
echo "  3) Registrar o Atuin (sincroniza histórico, se quiser usar):"
echo "     atuin register -u <usuario> -e <email>"
echo ""
echo "  4) Fazer logout/login (ou reiniciar) para o shell Zsh ser aplicado"
echo "     de verdade na sua sessão."
echo ""
