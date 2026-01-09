{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.wayfire-desktop;

  # Use the icon theme from the module configuration
  iconThemeName = cfg.iconTheme;

in
{
  options = {
    wayfire-desktop = {
      enable = mkEnableOption "Wayfire Desktop Environment";

      iconTheme = mkOption {
        type = types.str;
        default = "Papirus";
        description = "Icon theme to use for the desktop";
      };

      gtkTheme = mkOption {
        type = types.str;
        default = "Adwaita";
        description = "GTK theme to use for GTK applications";
      };

      fractionalScaling = mkOption {
        type = types.float;
        default = 1.0;
        description = "Fractional scaling factor for displays (1.0 = 100%, 1.25 = 125%, 1.5 = 150%, etc.)";
      };

      qtTheme = mkOption {
        type = types.str;
        default = "qt5ct";
        description = "Qt platform theme to use for Qt applications (qt5ct, gnome, gtk2, kde, fusion)";
      };

      darkTheme = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to use dark theme for GTK applications (defaults to true)";
      };

      cursorTheme = mkOption {
        type = types.str;
        default = "Vanilla-DMZ";
        description = "Cursor theme to use (Vanilla-DMZ, Adwaita, etc.)";
      };

      cursorSize = mkOption {
        type = types.int;
        default = 24;
        description = "Cursor size in pixels";
      };
    };
  };

  config = mkIf cfg.enable {

    # Enable X server support (required for XWayland compatibility)
    services.xserver.enable = true;

    programs.wayfire = {
      enable = true;
      plugins = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        wayfire-plugins-extra
      ];
    };

    # Enable NetworkManager service for network and VPN management
    networking.networkmanager.enable = true;

    # Enable polkit for permission management (required for nm-applet)
    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      # Default icon theme
      papirus-icon-theme
      # Essential fonts for waybar and wayfire
      font-awesome # For waybar icons (required for waybar symbols)
      noto-fonts # Good fallback font family
      noto-fonts-cjk-sans # CJK character support
      noto-fonts-color-emoji # Emoji support (renamed from noto-fonts-emoji)
      liberation_ttf # Good sans-serif fonts
      dejavu_fonts # DejaVu fonts (good fallback)
      source-sans # Adobe Source Sans Pro (modern, clean)
      ubuntu-classic # Ubuntu fonts (renamed from ubuntu_font_family)
      # Cursor themes
      vanilla-dmz # Default cursor theme
      adwaita-icon-theme # Includes Adwaita cursor theme
      # GPG integration packages
      gnupg
      pinentry-gnome3
      # Keyboard layout detection
      xkblayout-state
      # Add these for better app compatibility
      audio-recorder
      blueman # Bluetooth manager with system tray
      bluez-tools # Command line tools for Bluetooth
      brightnessctl # Brightness control for waybar
      clipse # Wayland clipboard manager
      dmenu
      # Qt theming and configuration tools
      libsForQt5.qt5ct # Qt5 configuration tool for better theming control
      libsForQt5.qtstyleplugins # Additional Qt style plugins
      evince
      fuzzel # Application launcher for Wayland
      gnome-disk-utility # GNOME Disks application
      gnome-secrets
      grim # Screenshot utility for Wayland
      gvfs # Virtual file system implementation for GIO
      junction # URL handler/browser chooser
      libnotify # Provides notify-send command for desktop notifications
      libreoffice
      libsecret # For secret-tool command
      libsForQt5.qt5.qtwayland
      lm_sensors # Temperature monitoring
      mako # Notification daemon for Wayland
      nautilus # File manager
      networkmanager
      networkmanagerapplet # System tray applet for NetworkManager
      nwg-launchers # Application launchers for Wayland
      pasystray # PulseAudio/PipeWire system tray applet
      nwg-look # GTK theme configuration tool
      polkit_gnome # Polkit authentication agent
      nwg-wrapper # Wrapper script to launch apps with proper env for Wayland
      pipewire # Multimedia framework for audio and video
      power-profiles-daemon # Power profile management
      qt5.qtwayland # Qt5 Wayland platform plugin
      qt6.qtwayland # Qt6 Wayland platform plugin
      seahorse # GUI for managing gnome-keyring
      slurp # Region selector for screenshots
      sushi # File previewer for Nautilus (spacebar preview)
      sway-contrib.grimshot # Screenshot tool for Wayland
      swayidle # Idle management for Wayland
      swaylock-effects # Screen locker with effects for Wayland
      swayr # Visual window switcher with overlay
      swww # Wallpaper setter (works with Wayfire too)
      util-linux # Provides rfkill tool to enable/disable wireless devices
      waybar # Bar panel for Wayland
      wayfire # Wayfire compositor with lots of nice eye candy
      wayfirePlugins.wayfire-plugins-extra
      wayfirePlugins.wcm # Wayfire Config Manager
      wayfirePlugins.wf-shell
      wf-recorder # Wayland screen recorder
      wireplumber
      wl-clipboard
      wlr-randr # Display configuration for wlr compositors
      wlrctl # Wayfire window management and inspection tool
      wshowkeys # On-screen key display for Wayland (setuid wrapper configured below)
      wtype # Wayland typing utility
      wev # Wayland event viewer for debugging
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr # For screen sharing in Wayfire
      zenity # GUI dialogs for keyring unlock
      # Wallpaper and screen management
      swww # Efficient animated wallpaper daemon for wayland
      swayidle # Idle management daemon for Wayland
      swaylock # Screen locker for Wayland
      # Cursor theme
      vanilla-dmz # Default cursor theme
      # Image processing for wallpapers
      imagemagick # For creating default wallpaper
      jq # Useful JSON processor
    ];

    environment.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      # Wayfire sets this to "wayfire"
      XDG_CURRENT_DESKTOP = "wayfire";
      XDG_SESSION_DESKTOP = "wayfire";
      # Cursor theme and size are managed by home-manager (see home/default.nix)
      # Enable gnome-keyring SSH agent
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
      # Configure GPG agent socket
      GPG_TTY = "$(tty)";
      GNUPGHOME = "$HOME/.gnupg";
      # Browser configuration
      DEFAULT_BROWSER = "${pkgs.junction}/bin/re.sonny.Junction";
      BROWSER = "re.sonny.Junction";
    };

    environment.variables = {
      # XDG environment for config discovery
      XDG_CONFIG_DIRS = "/etc/xdg";
      XDG_DATA_DIRS = mkDefault "/usr/local/share:/usr/share";
      # Cursor theme
      XCURSOR_THEME = cfg.cursorTheme;
      XCURSOR_SIZE = toString cfg.cursorSize;

      # Environment variables for better Wayland app compatibility
      QT_QPA_PLATFORM = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      GDK_BACKEND = "wayland,x11"; # Fallback to X11 if needed
      ELECTRON_OZONE_PLATFORM_HINT = "wayland"; # Better for Electron apps
      # Force apps to use Wayland when available
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      # XWayland fallback
      QT_QPA_PLATFORMTHEME = cfg.qtTheme;

      # Qt scaling and sizing fixes to prevent dialog compression
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_ENABLE_HIGHDPI_SCALING = "1";
      QT_SCALE_FACTOR = toString cfg.fractionalScaling;
      QT_FONT_DPI = "96";
    };

    # GTK theme configuration for GNOME/GTK apps
    programs.dconf.enable = true;

    # Set GTK settings system-wide
    environment.etc."gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name=${iconThemeName}
      gtk-theme-name=${cfg.gtkTheme}
      gtk-application-prefer-dark-theme=${lib.boolToString cfg.darkTheme}
    '';

    environment.etc."gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name=${iconThemeName}
      gtk-theme-name=${cfg.gtkTheme}
      gtk-application-prefer-dark-theme=${lib.boolToString cfg.darkTheme}
    '';

    # Required for screen sharing
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    services.dbus = {
      enable = true;
    };

    # Enable automounting for removable media (USB drives, etc.)
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    # Enable power profile management
    services.power-profiles-daemon.enable = true;

    # Enable gnome-keyring service for SSH and GPG key caching
    services.gnome.gnome-keyring.enable = true;

    # Enable GPG agent to integrate with gnome-keyring
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    # Configure PAM for SDDM to unlock gnome-keyring on login
    security.pam.services.sddm = {
      enableGnomeKeyring = true;
      gnupg.enable = true;
    };

    # Configure PAM for swaylock to unlock gnome-keyring when unlocking screen
    # Also enable fingerprint authentication (fprintd) for unlocking
    security.pam.services.swaylock = {
      enableGnomeKeyring = true;
      fprintAuth = true;
      gnupg.enable = true;
    };

    # Configure PAM for login sessions
    security.pam.services.login = {
      enableGnomeKeyring = true;
      gnupg.enable = true;
    };

    # Configure PAM for sudo to maintain keyring access
    security.pam.services.sudo = {
      enableGnomeKeyring = true;
    };

    # Configure setuid wrapper for wshowkeys to capture keyboard events
    security.wrappers.wshowkeys = {
      owner = "root";
      group = "input";
      permissions = "u+s,g+x";
      source = "${pkgs.wshowkeys}/bin/wshowkeys";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr # For Wayfire screen sharing
      ];
      # Configure portal backends for Wayfire
      config = {
        wayfire = {
          default = lib.mkForce [
            "gtk"
            "wlr"
          ];
          "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "gtk" ];
          "org.freedesktop.impl.portal.AppChooser" = lib.mkForce [ "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = lib.mkForce [ "wlr" ];
        };
      };
      # Ensures the right backend is selected
      xdgOpenUsePortal = true;
      wlr.enable = true;
    };

    # Configure default applications for MIME types
    environment.etc."xdg/mimeapps.list".text = ''
      [Default Applications]
      application/pdf=org.gnome.Evince.desktop
      text/plain=org.gnome.TextEditor.desktop
      image/jpeg=org.gnome.eog.desktop
      image/png=org.gnome.eog.desktop
      inode/directory=org.gnome.Nautilus.desktop
      application/x-gnome-saved-search=org.gnome.Nautilus.desktop

      [Added Associations]
      application/pdf=org.gnome.Evince.desktop
      inode/directory=org.gnome.Nautilus.desktop
      application/x-gnome-saved-search=org.gnome.Nautilus.desktop
    '';

    # Import environment variables into systemd user session
    systemd.user.extraConfig = ''
      DefaultEnvironment="WAYLAND_DISPLAY=wayland-1"
      DefaultEnvironment="XDG_CURRENT_DESKTOP=wayfire"
      DefaultEnvironment="XDG_SESSION_DESKTOP=wayfire"
      DefaultEnvironment="XDG_SESSION_TYPE=wayland"
      DefaultEnvironment="SSH_AUTH_SOCK=%t/keyring/ssh"
      DefaultEnvironment="GPG_TTY=$(tty)"
    '';

    # Systemd user service to ensure GPG agent connects to keyring
    systemd.user.services.gpg-agent-connect = {
      description = "Connect GPG agent to keyring";
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye";
        Environment = "GPG_TTY=$(tty)";
      };
    };

    # Polkit authentication agent for privilege escalation dialogs
    systemd.user.services.polkit-gnome-authentication-agent = {
      description = "Polkit GNOME authentication agent";
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # Use SDDM display manager with Wayland support
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "breeze";
      settings = {
        Theme = {
          Current = "breeze";
          CursorTheme = cfg.cursorTheme;
          CursorSize = cfg.cursorSize;
        };
        General = {
          DisplayServer = "wayland";
        };
      };
    };

    # Create Wayfire session file for SDDM
    services.displayManager.sessionPackages = [
      (pkgs.writeTextFile rec {
        name = "wayfire-wayland-session";
        destination = "/share/wayland-sessions/wayfire.desktop";
        text = ''
          [Desktop Entry]
          Name=Wayfire
          Comment=Stacking Wayland compositor with smooth animations
          Exec=wayfire
          Type=Application
          DesktopNames=wayfire
        '';
        passthru.providedSessions = [ "wayfire" ];
      })
    ];

  }; # End of config = mkIf cfg.enable
}
