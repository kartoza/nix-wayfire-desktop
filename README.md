# Wayfire Desktop Environment for NixOS

A minimal, standalone NixOS flake that provides a complete Wayfire desktop environment. This module focuses on delivering a working Wayfire compositor with all essential packages and services, while allowing users to manage their own dotfiles and configurations.

## Overview

This flake provides:

- **Wayfire compositor** with plugins (WCM, wf-shell, wayfire-plugins-extra)
- **Essential Wayland packages** for a functional desktop
- **Display manager** (SDDM) with Wayland support
- **Audio stack** (PipeWire with all backends)
- **System services** (NetworkManager, polkit, gnome-keyring, GPG)
- **Portal integration** for screen sharing (xdg-desktop-portal-wlr)
- **Theme support** (GTK, Qt, icons, cursors)
- **Wayland utilities** (wl-clipboard, wlr-randr, wlrctl, etc.)

## Philosophy

This module takes a **minimal approach**:

- ✅ Provides Wayfire and all required system packages
- ✅ Configures essential system services
- ✅ Sets up environment variables for Wayland compatibility
- ❌ Does **not** deploy dotfiles to `/etc/xdg/`
- ❌ Does **not** include opinionated configurations
- ❌ Does **not** manage user-specific customizations

**Users are expected to manage their own dotfiles** in `~/.config/`. This gives you complete control over your desktop configuration.

## Installation

### Step 1: Add Flake Input

Add this flake to your NixOS configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    wayfire-desktop.url = "github:yourusername/nix-wayfire-desktop";
  };
}
```

### Step 2: Import and Enable Module

```nix
{ inputs, ... }:
{
  imports = [
    inputs.wayfire-desktop.nixosModules.default
  ];

  wayfire-desktop.enable = true;
}
```

### Step 3: Rebuild System

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

## Configuration Options

The module provides basic theming options:

```nix
{
  wayfire-desktop = {
    enable = true;

    # Theme configuration
    iconTheme = "Papirus";           # Icon theme (default: Papirus)
    gtkTheme = "Adwaita";            # GTK theme (default: Adwaita)
    darkTheme = true;                # Use dark theme (default: true)
    qtTheme = "qt5ct";               # Qt platform theme (default: qt5ct)

    # Display configuration
    fractionalScaling = 1.0;         # Global scaling factor (default: 1.0)
    cursorTheme = "Vanilla-DMZ";     # Cursor theme (default: Vanilla-DMZ)
    cursorSize = 24;                 # Cursor size in pixels (default: 24)
  };
}
```

## Managing Your Configuration

### Initial Setup

After enabling the module, Wayfire will start but will use default configurations. To customize your desktop, you need to create your own dotfiles:

```bash
# Create basic Wayfire configuration
mkdir -p ~/.config/wayfire
cat > ~/.config/wayfire/wayfire.ini << 'EOF'
[core]
plugins = \
  alpha \
  animate \
  autostart \
  command \
  cube \
  decoration \
  expo \
  fast-switcher \
  fisheye \
  grid \
  idle \
  invert \
  move \
  oswitch \
  place \
  resize \
  switcher \
  vswitch \
  window-rules \
  wm-actions \
  wobbly \
  wrot \
  zoom

preferred_decoration_mode = server

[autostart]
panel = waybar
notifications = mako
wallpaper = swww init && swww img ~/Pictures/wallpaper.png

[input]
xkb_layout = us
xkb_variant =

[output:*]
mode = auto
position = auto
scale = 1.0

# Add more configuration as needed...
EOF
```

### Using the Example Dotfiles from This Repository

This repository includes example dotfiles that you can deploy:

```bash
# Deploy example dotfiles from this repository
cd /path/to/nix-wayfire-desktop
./scripts/deploy-dotfiles-to-user.sh

# Or preview what would be deployed
./scripts/deploy-dotfiles-to-user.sh --dry-run
```

### Using Your Own Dotfiles Repository

The recommended approach is to manage your dotfiles in a separate repository:

```bash
# Clone your dotfiles repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# Link configurations to ~/.config
ln -sf ~/dotfiles/wayfire ~/.config/wayfire
ln -sf ~/dotfiles/waybar ~/.config/waybar
ln -sf ~/dotfiles/mako ~/.config/mako
ln -sf ~/dotfiles/swaylock ~/.config/swaylock
# ... and so on
```

### Syncing Your Changes Back

If you've customized the dotfiles and want to save them back to this repository:

```bash
# Sync changes from ~/.config back to the repository
cd /path/to/nix-wayfire-desktop
./scripts/sync-dotfiles-from-user.sh

# Or preview what would be synced
./scripts/sync-dotfiles-from-user.sh --dry-run

# Then commit your changes
git add dotfiles/
git commit -m "Update dotfiles with my customizations"
```

### Example Dotfiles Structure

A typical dotfiles repository for Wayfire might look like:

```
dotfiles/
├── wayfire/
│   ├── wayfire.ini           # Main Wayfire configuration
│   └── scripts/              # Custom scripts
├── waybar/
│   ├── config                # Waybar configuration
│   ├── style.css             # Waybar styling
│   └── scripts/              # Status scripts
├── mako/
│   └── config                # Notification daemon config
├── swaylock/
│   └── config                # Screen locker config
└── fuzzel/
    └── fuzzel.ini            # Application launcher config
```

## Included Packages

The module provides these essential packages:

### Core Wayland
- wayfire, waybar, mako, swaylock-effects, swayidle, swww
- wl-clipboard, wlr-randr, wlrctl, wf-recorder
- fuzzel, wofi (application launchers)
- grim, slurp, sway-contrib.grimshot (screenshots)

### System Tools
- NetworkManager, blueman, brightnessctl
- polkit_gnome, gnome-keyring, seahorse
- nautilus (file manager), junction (browser chooser)
- pipewire (audio), power-profiles-daemon

### Development & Utilities
- jq (JSON processor)
- xdg-desktop-portal-gtk, xdg-desktop-portal-wlr
- imagemagick, libnotify

See `modules/wayfire-desktop.nix` for the complete package list.

## Services Configured

- **Display Manager**: SDDM with Wayland support
- **Audio**: PipeWire with ALSA, PulseAudio, JACK backends
- **Keyring**: gnome-keyring for SSH and GPG key management
- **Power Management**: power-profiles-daemon
- **Network**: NetworkManager
- **Storage**: udisks2, gvfs (automounting)

## Environment Variables

The module sets these environment variables for Wayland compatibility:

```bash
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=wayfire
QT_QPA_PLATFORM=wayland
MOZ_ENABLE_WAYLAND=1
GDK_BACKEND=wayland,x11
SDL_VIDEODRIVER=wayland
```

## Customization with WCM

Wayfire includes the **Wayfire Config Manager (WCM)** for GUI-based configuration:

```bash
# Open the configuration manager
wcm -c ~/.config/wayfire/wayfire.ini
```

WCM provides a graphical interface for:
- Adjusting animations and effects
- Configuring keybindings
- Setting up window rules
- Managing workspace behavior

Changes made in WCM are saved directly to your `~/.config/wayfire/wayfire.ini` file.

## Development

### Local Development

```bash
# Enter development shell
nix develop

# Format code
nix fmt

# Check flake
nix flake check
```

### Testing

A test VM configuration is provided:

```bash
nix build .#nixosConfigurations.vm-test.config.system.build.vm
./result/bin/run-nixos-vm
```

## Troubleshooting

### Wayfire doesn't start

Check that your `~/.config/wayfire/wayfire.ini` exists and is valid:

```bash
wayfire --config ~/.config/wayfire/wayfire.ini
```

### Display issues

Verify your output configuration:

```bash
wlr-randr  # List displays and their modes
```

### Missing keybindings

Ensure you have configured keybindings in your `wayfire.ini`:

```ini
[command]
binding_terminal = <super> KEY_ENTER
command_terminal = kitty

binding_launcher = <super> KEY_SPACE
command_launcher = fuzzel
```

## Related Projects

If you want pre-configured dotfiles, consider:
- Creating your own dotfiles repository based on your preferences
- Using [Wayfire's example configurations](https://github.com/WayfireWM/wayfire/wiki/Configuration)
- Exploring community dotfiles on GitHub

## Contributing

Contributions are welcome! This module aims to stay minimal and focused on providing a working Wayfire base. Please open issues or pull requests for:

- Bug fixes
- Package additions that benefit all users
- Service configuration improvements
- Documentation enhancements

## License

This project is available under the MIT License.
