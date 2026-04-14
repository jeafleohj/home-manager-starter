#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
HOME_MANAGER_DIR="${HOME}/.config/home-manager"
APPARMOR_PROFILE_SOURCE="${REPO_ROOT}/apparmor/nix-electron-apps"
APPARMOR_PROFILE_TARGET="/etc/apparmor.d/nix-electron-apps"
NIX_ZSH_PATH="${HOME}/.nix-profile/bin/zsh"

current_login_shell() {
  getent passwd "${USER}" 2>/dev/null | cut -d: -f7
}

apparmor_is_available() {
  [ -d "/etc/apparmor.d" ] || return 1

  if [ -r "/sys/module/apparmor/parameters/enabled" ]; then
    grep -qx 'Y' /sys/module/apparmor/parameters/enabled
    return
  fi

  command -v apparmor_parser >/dev/null 2>&1
}

install_apparmor_profile() {
  if [ ! -f "${APPARMOR_PROFILE_SOURCE}" ]; then
    echo "AppArmor profile not found at ${APPARMOR_PROFILE_SOURCE}. Skipping."
    return
  fi

  if ! apparmor_is_available; then
    echo "AppArmor is not available on this system. Skipping profile installation."
    return
  fi

  echo "Installing AppArmor profile to ${APPARMOR_PROFILE_TARGET}."
  sudo install -m 644 "${APPARMOR_PROFILE_SOURCE}" "${APPARMOR_PROFILE_TARGET}"
  sudo apparmor_parser -r "${APPARMOR_PROFILE_TARGET}"
}

register_nix_zsh_shell() {
  if [ ! -x "${NIX_ZSH_PATH}" ]; then
    echo "Zsh not found at ${NIX_ZSH_PATH}. Skipping /etc/shells update."
    return
  fi

  if grep -Fxq "${NIX_ZSH_PATH}" /etc/shells; then
    echo "${NIX_ZSH_PATH} is already present in /etc/shells."
    return
  fi

  echo "Registering ${NIX_ZSH_PATH} in /etc/shells."
  printf '%s\n' "${NIX_ZSH_PATH}" | sudo tee -a /etc/shells >/dev/null
}

set_nix_zsh_as_login_shell() {
  local current_shell

  if [ ! -x "${NIX_ZSH_PATH}" ]; then
    echo "Zsh not found at ${NIX_ZSH_PATH}. Skipping login shell update."
    return
  fi

  if ! command -v chsh >/dev/null 2>&1; then
    echo "chsh is not available on this system. Skipping login shell update."
    return
  fi

  current_shell="$(current_login_shell)"

  if [ "${current_shell}" = "${NIX_ZSH_PATH}" ]; then
    echo "Login shell is already set to ${NIX_ZSH_PATH}."
    return
  fi

  echo "Changing login shell for ${USER} to ${NIX_ZSH_PATH}."
  chsh -s "${NIX_ZSH_PATH}"
}

apply_home_manager() {
  export NIX_CONFIG="experimental-features = nix-command flakes"
  nix run home-manager/master -- switch --flake "${HOME_MANAGER_DIR}" --impure
}

install_apparmor_profile
apply_home_manager
register_nix_zsh_shell
set_nix_zsh_as_login_shell
