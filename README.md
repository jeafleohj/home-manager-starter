# Home Manager

Home Manager configuration built with Nix flakes.

## Quick Setup

### 1. Install `curl`

#### Debian/Ubuntu

```sh
sudo apt install curl -y
```

#### Arch Linux

```sh
sudo pacman -S curl
```

### 2. Install Nix

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

### 3. Clone this repository

```sh
nix --extra-experimental-features 'nix-command flakes' \
  run nixpkgs#git -- clone https://github.com/jeafleohj/home-manager-starter.git ~/.config/home-manager
```

### 4. Run the bootstrap script

```sh
~/.config/home-manager/scripts/bootstrap.sh
```

The bootstrap script:

- enables `nix-command` and `flakes`;
- applies the Home Manager-managed `just` configuration;
- installs the AppArmor profile for Electron apps when supported by the system;
- applies the Home Manager configuration;
- registers the Nix-provided `zsh` shell in `/etc/shells` when needed;
- changes the user's login shell to the Nix-provided `zsh` when needed.

## Usage

### Bootstrap-managed workflow

After running the bootstrap script, Home Manager manages `~/.config/just/justfile`.

List available recipes:

```sh
just -g
```

Update flake inputs:

```sh
just -g home-manager-update
```

Apply the Home Manager configuration:

```sh
just -g home-manager-switch
```

## AppArmor Note for Ubuntu

On Ubuntu, some Electron apps installed from Nix may require an AppArmor profile that allows `userns`.

[`apparmor/nix-electron-apps`](./apparmor/nix-electron-apps) is copied automatically to `/etc/apparmor.d/nix-electron-apps` only when:

- `/etc/apparmor.d` exists;
- AppArmor is enabled or available on the system;
- the source file exists in this repository.

If AppArmor is not available, the bootstrap script continues without failing.
