# Wayfire Desktop Dotfiles (Example/Reference)

This directory contains **example dotfiles** for the Wayfire desktop environment. These configurations are **not automatically deployed** by the nix-wayfire-desktop module.

## Important Notice

⚠️ **These dotfiles are for reference only.** The nix-wayfire-desktop module does **not** deploy these configurations. You must manually copy or symlink them to your `~/.config/` directory if you want to use them.

## What's Included

This example configuration includes:

### Wayfire Configuration
- **wayfire/wayfire.ini** - Main Wayfire compositor configuration
  - Keybindings for common actions
  - Plugin configuration (cube, expo, animations, etc.)
  - Autostart applications
  - Input/output settings

- **wayfire/scripts/** - Utility scripts
  - Workspace management (switcher, names, overlay)
  - Screen recording and screenshots
  - Clipboard management
  - Emoji picker
  - And more...

### Waybar (Status Bar)
- **waybar/config** - Main waybar configuration (built from config.d/)
- **waybar/style.css** - CSS styling for waybar
- **waybar/config.d/** - Modular waybar configuration system
  - Base configurations
  - Widget modules (clock, battery, network, etc.)
  - Custom modules (keyboard layout, workspace display, etc.)
- **waybar/scripts/** - Status bar scripts
  - Power profile management
  - Temperature monitoring
  - Notification toggle
  - Keyboard layout display
  - And more...

### Other Applications
- **mako/** - Notification daemon configuration
- **swaylock/** - Screen locker configuration
- **fuzzel/** - Application launcher scripts
- **nwggrid/** - Application grid launcher styling
- **qt5ct/** - Qt5 application theming

## Installation

### Option 1: Direct Copy

Copy the dotfiles to your home directory:

```bash
# Copy all dotfiles
cp -r dotfiles/wayfire ~/.config/
cp -r dotfiles/waybar ~/.config/
cp -r dotfiles/mako ~/.config/
cp -r dotfiles/swaylock ~/.config/
cp -r dotfiles/fuzzel ~/.config/
cp -r dotfiles/nwggrid ~/.config/nwg-launchers/
cp -r dotfiles/qt5ct ~/.config/
```

### Option 2: Symlinks

Create symlinks to keep your dotfiles in sync with this repository:

```bash
# Symlink dotfiles (useful for development)
ln -sf ~/path/to/nix-wayfire-desktop/dotfiles/wayfire ~/.config/wayfire
ln -sf ~/path/to/nix-wayfire-desktop/dotfiles/waybar ~/.config/waybar
ln -sf ~/path/to/nix-wayfire-desktop/dotfiles/mako ~/.config/mako
# etc...
```

### Option 3: Fork and Customize

1. Fork this repository or extract the dotfiles directory
2. Customize the configurations to your liking
3. Manage your dotfiles in a separate repository
4. Deploy using your preferred dotfiles management tool (GNU Stow, yadm, etc.)

## Configuration Structure

### Waybar Modular System

The waybar configuration uses a modular approach:

```
waybar/
├── config              # Final built config (generated from config.d/)
├── style.css           # Global waybar styling
├── config.d/           # Modular config fragments
│   ├── 00-base-wayfire.json       # Base configuration
│   ├── 10-modules-left.json       # Left modules
│   ├── 10-modules-center.json     # Center modules
│   ├── 10-modules-right.json      # Right modules
│   ├── 90-*.json                  # Individual widget configs
│   └── ...
├── scripts/            # Status scripts
└── build-config.sh     # Script to rebuild config from fragments
```

To rebuild the waybar config after modifying fragments:

```bash
cd ~/.config/waybar
./build-config.sh
killall waybar
waybar &
```

### Wayfire Scripts

Scripts assume they're in `~/.config/wayfire/scripts/` and can reference other configs in `~/.config/`. Make sure scripts are executable:

```bash
chmod +x ~/.config/wayfire/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh
```

## Customization

### Essential Customizations

Before using these dotfiles, you should customize:

1. **Wallpaper Path** - Edit `wayfire/wayfire.ini`:
   ```ini
   [autostart]
   wallpaper = swww init && swww img ~/Pictures/your-wallpaper.png
   ```

2. **Terminal Emulator** - Edit `wayfire/wayfire.ini`:
   ```ini
   [command]
   command_terminal = kitty  # or: alacritty, foot, etc.
   ```

3. **Browser** - Edit `wayfire/wayfire.ini`:
   ```ini
   [command]
   command_browser = ~/.config/wayfire/scripts/get-default-browser.sh
   ```

4. **Keyboard Layout** - Edit `wayfire/wayfire.ini`:
   ```ini
   [input]
   xkb_layout = us  # or: us,pt, etc.
   ```

5. **Workspace Names** - Edit `wayfire/workspace-names.conf`:
   ```
   0=Browser
   1=Terminal
   2=Code
   # etc...
   ```

### Theme Customization

The example configs use a custom theme with:
- Orange accent color (#DF9E2F)
- Dark backgrounds
- Custom waybar styling

You can customize colors in:
- `waybar/style.css` - Waybar colors and fonts
- `mako/kartoza` - Notification colors
- `wayfire/wayfire.ini` - Window decoration colors

## Dependencies

These dotfiles assume you have the following packages installed (which the nix-wayfire-desktop module provides):

- wayfire (compositor)
- waybar (status bar)
- mako (notifications)
- swaylock (screen locker)
- swww (wallpaper)
- fuzzel (launcher)
- kitty (terminal - or your preferred terminal)
- Various utilities (grim, slurp, wl-clipboard, etc.)

## Keybindings Quick Reference

See `wayfire/keybinds-cheat-sheet.md` for a complete list. Common bindings:

- **Super + Enter** - Terminal
- **Super + Space** - Launcher
- **Super + Q** - Close window
- **Super + B** - Browser
- **Super + E** - File manager
- **Super + I** - Wayfire settings (WCM)
- **Super + D** - Workspace switcher
- **Super + P** - Clipboard manager
- **Ctrl + Alt + L** - Lock screen
- **Ctrl + 4** - Screenshot area
- **Ctrl + 5** - Screenshot full

## Troubleshooting

### Scripts don't work

Make sure scripts are executable and paths are correct:

```bash
chmod +x ~/.config/wayfire/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh
```

### Waybar doesn't start

Check waybar log:

```bash
waybar --log-level debug
```

Make sure the config is valid JSON:

```bash
cd ~/.config/waybar
jq . config
```

### Missing keybindings

Check that your wayfire config is being loaded:

```bash
wayfire --version
cat ~/.config/wayfire/wayfire.ini | grep command_terminal
```

## Contributing

If you find issues or improvements for these example dotfiles, feel free to open an issue or pull request in the main repository.

## License

These example dotfiles are provided as-is for reference and can be freely modified and distributed.
