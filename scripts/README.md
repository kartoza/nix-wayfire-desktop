# Dotfiles Management Scripts

This directory contains utility scripts for managing dotfiles between the repository and your user configuration.

## Available Scripts

### 1. `deploy-dotfiles-to-user.sh`

Deploy dotfiles from the repository to your `~/.config/` directory.

**Usage:**
```bash
# Deploy all dotfiles (with confirmation)
./scripts/deploy-dotfiles-to-user.sh

# Deploy without confirmation
./scripts/deploy-dotfiles-to-user.sh --force

# Preview what would be deployed
./scripts/deploy-dotfiles-to-user.sh --dry-run

# Show help
./scripts/deploy-dotfiles-to-user.sh --help
```

**What it does:**
- Copies dotfiles from `dotfiles/` to `~/.config/`
- Creates timestamped backups of existing files
- Makes scripts executable automatically
- Deploys: wayfire, waybar, mako, swaylock, fuzzel, qt5ct, nwg-launchers

**After deployment:**
- Press `Super+Shift+R` to reload Wayfire
- Run `killall waybar && waybar &` to restart waybar

---

### 2. `sync-dotfiles-from-user.sh`

Sync your customized dotfiles from `~/.config/` back to the repository.

**Usage:**
```bash
# Sync all dotfiles
./scripts/sync-dotfiles-from-user.sh

# Preview what would be synced
./scripts/sync-dotfiles-from-user.sh --dry-run

# Show help
./scripts/sync-dotfiles-from-user.sh --help
```

**What it does:**
- Copies modified configs from `~/.config/` to `dotfiles/`
- Creates timestamped backups of existing repository files
- Uses rsync for efficient synchronization
- Preserves file permissions and structure

**After syncing:**
```bash
# Review changes
git status
git diff

# Commit your customizations
git add dotfiles/
git commit -m "Update dotfiles with my customizations"

# Optionally push to your fork
git push origin main
```

---

## Typical Workflow

### Initial Setup

1. **Deploy example dotfiles:**
   ```bash
   ./scripts/deploy-dotfiles-to-user.sh
   ```

2. **Customize your configs:**
   - Edit files in `~/.config/wayfire/`, `~/.config/waybar/`, etc.
   - Test your changes (Wayfire reloads automatically in most cases)

3. **Sync changes back to repo:**
   ```bash
   ./scripts/sync-dotfiles-from-user.sh
   ```

4. **Commit your changes:**
   ```bash
   git add dotfiles/
   git commit -m "Customize keybindings and colors"
   ```

### Updating from Repository

If the repository is updated with new dotfiles:

```bash
# Pull latest changes
git pull origin main

# Preview what would be deployed
./scripts/deploy-dotfiles-to-user.sh --dry-run

# Deploy updates (backs up your existing configs)
./scripts/deploy-dotfiles-to-user.sh
```

### Backing Up Your Dotfiles

Both scripts create automatic backups, but you can also manually backup:

```bash
# Manual backup
tar -czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/.config/wayfire ~/.config/waybar ~/.config/mako
```

## Files Managed

The scripts manage these configuration files:

| Application | Files Synced |
|-------------|--------------|
| **Wayfire** | `wayfire.ini`, `scripts/`, `workspace-names.conf` |
| **Waybar** | `config`, `style.css`, `config.d/`, `scripts/` |
| **Mako** | `config` (or `kartoza`), `sounds/` |
| **Swaylock** | `config` |
| **Fuzzel** | All files in `fuzzel/` |
| **Qt5ct** | All files in `qt5ct/` |
| **nwg-launchers** | `nwggrid/`, `nwgbar/` |

## Safety Features

Both scripts include safety features:

✅ **Automatic Backups** - Existing files are backed up before modification
✅ **Timestamped Backups** - Each backup is uniquely named with timestamp
✅ **Dry-Run Mode** - Preview changes without modifying files
✅ **Confirmation Prompts** - Asks for confirmation before deployment
✅ **Colored Output** - Clear visual feedback for success/warnings/errors

## Troubleshooting

### Scripts won't run

Make sure scripts are executable:
```bash
chmod +x scripts/*.sh
```

### Deployed configs don't work

Check file permissions:
```bash
ls -la ~/.config/wayfire/scripts/
chmod +x ~/.config/wayfire/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh
```

### Want to reset to repository defaults

```bash
# Remove your customizations
rm -rf ~/.config/wayfire ~/.config/waybar ~/.config/mako

# Deploy clean copies
./scripts/deploy-dotfiles-to-user.sh --force
```

### Backup files accumulating

Remove old backup files:
```bash
# In repository
find dotfiles/ -name "*.backup.*" -mtime +30 -delete

# In user config
find ~/.config/ -name "*.backup.*" -mtime +30 -delete
```

## Advanced Usage

### Selective Deployment

Edit the scripts to comment out sections you don't want to deploy:

```bash
# In deploy-dotfiles-to-user.sh, comment out sections:
# print_info "--- Waybar Configuration ---"
# deploy_file "waybar/config"
# deploy_file "waybar/style.css"
```

### Custom Locations

Modify the `USER_CONFIG` variable if your configs are elsewhere:

```bash
# At the top of the script
USER_CONFIG="$HOME/.config"  # Change this
```

### Integration with Git Hooks

You can automate syncing with git hooks:

```bash
# .git/hooks/pre-commit
#!/usr/bin/env bash
./scripts/sync-dotfiles-from-user.sh
git add dotfiles/
```

## See Also

- [dotfiles/README.md](../dotfiles/README.md) - Dotfiles documentation
- [README.md](../README.md) - Main project README
- [CLAUDE.md](../CLAUDE.md) - Development documentation
