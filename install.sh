#!/usr/bin/env bash
set -Eeuo pipefail

readonly DOTFILES_DIR="${HOME}/.dotfiles"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly BACKUP_DIR="${HOME}/.local/state/dotfiles/backups/$(date +%Y%m%d-%H%M%S)"

dry_run=false
link_only=false
backup_created=false

usage() {
    printf 'Usage: %s [--dry-run|--link-only]\n' "${0##*/}"
}

case "${1:-}" in
    "") ;;
    --dry-run) dry_run=true ;;
    --link-only) link_only=true ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

log() {
    printf '==> %s\n' "$*"
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

run() {
    if [[ "${dry_run}" == true ]]; then
        printf '  '
        printf '%q ' "$@"
        printf '\n'
        return 0
    fi
    "$@"
}

load_packages() {
    local manifest=$1
    local -n result=$2

    mapfile -t result < <(grep -Ev '^[[:space:]]*(#|$)' "${manifest}")
}

backup_target() {
    local target=$1
    local relative=${target#"${HOME}/"}
    local destination="${BACKUP_DIR}/${relative}"

    if [[ "${dry_run}" == true ]]; then
        log "Would back up ${target} to ${destination}"
        return 0
    fi

    mkdir -p -- "$(dirname -- "${destination}")"
    mv -- "${target}" "${destination}"
    backup_created=true
}

link_path() {
    local source=$1
    local target=$2

    [[ -e "${source}" ]] || die "Missing dotfile source: ${source}"

    if [[ -L "${target}" ]] && [[ "$(readlink -f -- "${target}")" == "$(readlink -f -- "${source}")" ]]; then
        log "Already linked: ${target}"
        return 0
    fi

    if [[ -e "${target}" || -L "${target}" ]]; then
        backup_target "${target}"
    fi

    run mkdir -p -- "$(dirname -- "${target}")"
    run ln -s -- "${source}" "${target}"
}

ensure_git_checkout() {
    local repository=$1
    local destination=$2

    if [[ -d "${destination}/.git" ]]; then
        log "Already installed: ${destination}"
        return 0
    fi
    [[ ! -e "${destination}" ]] || die "Cannot clone over existing path: ${destination}"
    run git clone --depth 1 "${repository}" "${destination}"
}

enable_multilib() {
    if pacman-conf --repo-list | grep -qx multilib; then
        return 0
    fi

    log "Enabling the multilib repository"
    run sudo sed -i \
        '/^#\[multilib\]$/,/^$/ { s/^#\[multilib\]$/[multilib]/; s/^#Include =/Include =/; }' \
        /etc/pacman.conf
}

install_latest_paru() {
    local build_dir

    if pacman -Qq paru-git >/dev/null 2>&1 && paru --version >/dev/null 2>&1; then
        log "Rebuilding paru-git from the latest upstream revision"
        run paru -S --rebuild paru-git
        return 0
    fi

    log "Bootstrapping the latest paru-git package with makepkg"
    if [[ "${dry_run}" == true ]]; then
        printf '  git clone https://aur.archlinux.org/paru-git.git <temporary-directory>/paru-git\n'
        printf '  (cd <temporary-directory>/paru-git && makepkg -si)\n'
        return 0
    fi

    build_dir=$(mktemp -d)
    trap 'rm -rf -- "${build_dir:-}"' RETURN
    git clone https://aur.archlinux.org/paru-git.git "${build_dir}/paru-git"
    (
        cd -- "${build_dir}/paru-git"
        makepkg -si
    )
    rm -rf -- "${build_dir}"
    trap - RETURN
}

install_packages() {
    local -a pacman_packages aur_packages

    load_packages "${SCRIPT_DIR}/packages/pacman.txt" pacman_packages
    load_packages "${SCRIPT_DIR}/packages/aur.txt" aur_packages

    log "Installing ${#pacman_packages[@]} repository packages"
    run sudo pacman -Syu --needed "${pacman_packages[@]}"
    install_latest_paru
    log "Installing ${#aur_packages[@]} AUR packages"
    run paru -S --needed "${aur_packages[@]}"
}

deploy_dotfiles() {
    local directory

    log "Deploying public dotfiles"
    link_path "${SCRIPT_DIR}/.zshrc" "${HOME}/.zshrc"
    link_path "${SCRIPT_DIR}/.zprofile" "${HOME}/.zprofile"
    link_path "${SCRIPT_DIR}/.tmux.conf" "${HOME}/.tmux.conf"
    link_path "${SCRIPT_DIR}/.urlview" "${HOME}/.urlview"
    link_path "${SCRIPT_DIR}/git/gitconfig" "${HOME}/.gitconfig"
    link_path "${SCRIPT_DIR}/git/gitignore_global" "${HOME}/.gitignore_global"

    for directory in foot lazygit nvim rofi sway systemd voxtype waybar wofi; do
        link_path "${SCRIPT_DIR}/${directory}" "${HOME}/.config/${directory}"
    done

    link_path "${SCRIPT_DIR}/mimeapps.list" "${HOME}/.config/mimeapps.list"
    link_path "${SCRIPT_DIR}/Thunar/uca.xml" "${HOME}/.config/Thunar/uca.xml"
}

deploy_system_config() {
    local source="${SCRIPT_DIR}/etc/systemd/logind.conf.d/90-power-key.conf"
    local target="/etc/systemd/logind.conf.d/90-power-key.conf"

    log "Deploying system configuration"
    if cmp -s -- "${source}" "${target}"; then
        log "Already installed: ${target}"
        return 0
    fi

    run sudo install -Dm0644 -- "${source}" "${target}"
    run sudo systemctl reload systemd-logind.service
}

reload_tmux_config() {
    if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
        log "Reloading the running tmux server"
        run tmux source-file "${HOME}/.tmux.conf"
    fi
}

install_user_tools() {
    log "Installing shell and editor plugins"
    ensure_git_checkout https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh"
    ensure_git_checkout https://github.com/zsh-users/zsh-autosuggestions \
        "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    ensure_git_checkout https://github.com/zsh-users/zsh-syntax-highlighting \
        "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

    if [[ "${dry_run}" == true || -x /usr/share/tmux-plugin-manager/bin/install_plugins ]]; then
        run /usr/share/tmux-plugin-manager/bin/install_plugins
    else
        die "tmux-plugin-manager was installed without its installer"
    fi

    run nvim --headless '+Lazy! sync' +qa
}

main() {
    [[ "${EUID}" -ne 0 ]] || die "Run this installer as a regular user, not root"
    [[ "$(uname -m)" == x86_64 ]] || die "This package inventory targets Arch Linux x86_64"
    command -v pacman >/dev/null 2>&1 || die "pacman is required; this installer only supports Arch Linux"
    [[ "${SCRIPT_DIR}" == "${DOTFILES_DIR}" ]] || die "Clone this repository to ${DOTFILES_DIR}"

    if [[ "${link_only}" == false ]]; then
        log "Refreshing sudo credentials"
        run sudo -v
        enable_multilib
        install_packages
    fi
    deploy_dotfiles
    deploy_system_config
    reload_tmux_config
    if [[ "${link_only}" == false ]]; then
        install_user_tools
    fi

    if [[ "${backup_created}" == true ]]; then
        log "Previous files were backed up to ${BACKUP_DIR}"
    fi
    log "Public workstation setup complete"
}

main
