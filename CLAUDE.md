# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **minimal NixOS flake** that provides a generic Wayfire desktop environment. The module focuses on:

- Installing Wayfire compositor and essential Wayland packages
- Configuring system services (PipeWire, NetworkManager, gnome-keyring, etc.)
- Setting environment variables for Wayland compatibility
- **NOT** managing user dotfiles or configurations

## Architecture Philosophy

### What This Module Does

✅ Provides a working Wayfire base system
✅ Includes all necessary packages and dependencies
✅ Configures system-level services
✅ Sets up display manager (SDDM)
✅ Configures XDG portals for screen sharing

### What This Module Does NOT Do

❌ Deploy dotfiles to `/etc/xdg/` or any other location
❌ Include opinionated configurations
❌ Manage user-specific customizations
❌ Provide pre-configured keybindings or themes

**Users are expected to manage their own dotfiles** in `~/.config/` or via a separate dotfiles repository.

## Project Structure

```
nix-wayfire-desktop/
├── flake.nix                    # Flake definition
├── modules/
│   └── wayfire-desktop.nix      # Main NixOS module (minimal, no dotfile deployment)
├── dotfiles/                    # DEPRECATED - for reference only, not deployed
├── resources/                   # DEPRECATED - for reference only
├── vm-test.nix                  # Test VM configuration
└── README.md                    # User documentation
```

## Development Commands

### Build and Format
- `nix develop` - Enter development shell with formatting tools
- `nix fmt` - Format all Nix files using nixfmt-rfc-style
- `nix flake check` - Validate flake and check formatting

### Testing
```bash
# Build and run test VM
nix build .#nixosConfigurations.vm-test.config.system.build.vm
./result/bin/run-nixos-vm
```

## Module Configuration

### Available Options

The module exposes these configuration options:

```nix
wayfire-desktop = {
  enable = true;

  # Theme options
  iconTheme = "Papirus";
  gtkTheme = "Adwaita";
  darkTheme = true;
  qtTheme = "qt5ct";

  # Display options
  fractionalScaling = 1.0;
  cursorTheme = "Vanilla-DMZ";
  cursorSize = 24;
};
```

### What the Module Configures

1. **Packages**: Installs Wayfire and all essential Wayland tools
2. **Services**:
   - Display manager (SDDM)
   - Audio (PipeWire)
   - Keyring (gnome-keyring)
   - Network (NetworkManager)
   - Power management
3. **Environment Variables**: Sets up Wayland-specific variables
4. **GTK/Qt Themes**: Applies theme settings system-wide
5. **XDG Portals**: Configures screen sharing support

## Important Notes for Development

### No Dotfile Management

This module **does not deploy dotfiles**. The `dotfiles/` directory in this repository is **deprecated** and kept only for reference. Users must:

1. Create their own `~/.config/wayfire/wayfire.ini`
2. Set up their own waybar, mako, swaylock configurations
3. Manage their own scripts and customizations

### Minimal Approach

When adding features to this module:

- ✅ Add packages that benefit all users (e.g., wlr-randr, wl-clipboard)
- ✅ Configure system services needed for functionality
- ✅ Set environment variables for compatibility
- ❌ Don't add opinionated configurations
- ❌ Don't deploy dotfiles or scripts
- ❌ Don't add customizations specific to one use case

### Testing Changes

1. Make changes to `modules/wayfire-desktop.nix`
2. Run `nix fmt` to format code
3. Run `nix flake check` to validate
4. Test in VM or on a test system
5. Update README.md if adding new options

## Example Usage

Users import this module in their own NixOS configuration:

```nix
{
  inputs = {
    wayfire-desktop.url = "github:yourusername/nix-wayfire-desktop";
  };

  outputs = { self, nixpkgs, wayfire-desktop, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        wayfire-desktop.nixosModules.default
        {
          wayfire-desktop.enable = true;
        }
      ];
    };
  };
}
```

Then they manage their own dotfiles separately, for example:

```bash
# User clones their dotfiles repo
git clone https://github.com/user/dotfiles ~/.dotfiles

# User symlinks configs
ln -s ~/.dotfiles/wayfire ~/.config/wayfire
ln -s ~/.dotfiles/waybar ~/.config/waybar
```

## Migration Notes

This project was previously a full desktop environment configuration with:
- Dotfiles deployed to `/etc/xdg/`
- Custom scripts and utilities
- Kartoza-specific branding and customizations

**These have been removed** to create a minimal, generic Wayfire module. The old dotfiles are preserved in the `dotfiles/` directory for users who want to reference or use them, but they are not deployed by the module.

## Related Resources

- [Wayfire Wiki](https://github.com/WayfireWM/wayfire/wiki)
- [Wayfire Configuration Reference](https://github.com/WayfireWM/wayfire/wiki/Configuration)
- [NixOS Wayland Guide](https://wiki.nixos.org/wiki/Wayland)
