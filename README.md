# Kartoza Wayfire Desktop Configuration

A standalone NixOS flake for configuring Wayfire desktop environment with Kartoza theming and customizations.

## Overview

This flake provides a complete Wayfire desktop environment configuration that can be imported into any NixOS flake. It includes:

- Wayfire compositor with plugins
- Waybar status bar with modular configuration
- Wofi application launcher
- Mako notification daemon
- Fuzzel and other utilities
- Complete theming and styling

## Usage

Add this flake as an input to your NixOS configuration:

```nix
{
  inputs = {
    wayfire-desktop.url = "github:kartoza/nix-wayfire-desktop";
    # ... other inputs
  };
}
```

Then import the module in your NixOS configuration:

```nix
{
  imports = [
    wayfire-desktop.nixosModules.default
    # ... other modules
  ];
}
```

## Dependencies

This module expects the importing flake to provide:
- `config.kartoza.theme.iconTheme.name` for GTK icon theme configuration

## Structure

- `modules/wayfire-desktop.nix` - Main NixOS module
- `dotfiles/` - Configuration files for Wayfire and related applications
- `resources/` - Images and other static resources

## Development

### Local Development Setup

Enter development shell:
```bash
nix develop
```

Format code:
```bash
nix fmt
```

### Testing Changes on Existing NixOS Systems

If you're running a NixOS system that already imports this flake, you can test local changes before committing:

#### Method 1: Local Path Override (Recommended for Development)

In your main system flake, temporarily override the wayfire-desktop input to point to your local development copy:

```nix
{
  inputs = {
    wayfire-desktop.url = "path:/path/to/your/local/nix-wayfire-desktop";
    # Or use a relative path if your system flake is in a parent directory:
    # wayfire-desktop.url = "path:./nix-wayfire-desktop";
    # ... other inputs
  };
}
```

Then rebuild your system:
```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

#### Method 2: Update Flake Input After Remote Changes

If you've pushed changes to the remote repository:

```bash
# In your system flake directory, update only this flake
nix flake lock --update-input wayfire-desktop

# Then rebuild
sudo nixos-rebuild switch --flake .#your-hostname
```

#### Method 3: Branch Testing

Create a branch with your changes and test it:

```bash
# In this repository
git checkout -b feature/my-changes
git add . && git commit -m "Test changes"

# In your system flake, temporarily change the input
# wayfire-desktop.url = "github:kartoza/nix-wayfire-desktop/feature/my-changes";
```

#### Method 4: Quick Waybar Configuration Testing

For rapid waybar configuration testing without full system rebuilds:

```bash
cd /path/to/nix-wayfire-desktop/dotfiles/waybar

# Build the modular config
./build-config.sh

# Test waybar with your changes (creates temporary second instance)
waybar -c config -s style.css --log-level debug
```

This method is useful for CSS styling and layout changes, but won't reflect module-level changes.

### Deploying Changes

#### For Development/Testing Systems

1. Make changes in this repository
2. Use local path override method above
3. Test with `sudo nixos-rebuild switch`

#### For Production Deployment

1. Commit and push changes to a branch
2. Test the branch using Method 3 above
3. Create a pull request and merge to main
4. Update your system flake to use the new commit:
   ```bash
   nix flake lock --update-input wayfire-desktop
   ```
5. Deploy with `sudo nixos-rebuild switch`

### Configuration Deployment to User Home

After system rebuild, configuration files are available system-wide in `/etc`. To deploy them to user home directories:

```bash
deploy-wayfire-configs
```

This is useful when users want to customize configurations locally.