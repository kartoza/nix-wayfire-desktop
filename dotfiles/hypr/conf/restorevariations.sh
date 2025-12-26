#!/bin/bash
clear
cat <<"EOF"
   ___          __
  / _ \___ ___ / /____  _______
 / , _/ -_|_-</ __/ _ \/ __/ -_)
/_/|_|\__/___/\__/\___/_/  \__/

EOF
echo "You can restore to the default ML4W variations."
echo "PLEASE NOTE: You can reactivate to a customized variation or selection in the settings script."
echo "Your customized variation will not be overwritten or deleted."

if gum confirm "Do you want to restore all variations to the default values?"; then
    echo

    echo "source = /etc/xdg/hypr/conf/keybindings/default.conf" >$(xdg-config-resolve hypr/conf/keybinding.conf)
    echo "Hyprland keybinding.conf restored!"

    echo "source = /etc/xdg/hypr/conf/environments/default.conf" >$(xdg-config-resolve hypr/conf/environment.conf)
    echo "Hyprland environment.conf restored!"

    echo "source = /etc/xdg/hypr/conf/windowrules/default.conf" >$(xdg-config-resolve hypr/conf/windowrule.conf)
    echo "Hyprland windowrule.conf restored!"

    echo "source = /etc/xdg/hypr/conf/animations/default.conf" >$(xdg-config-resolve hypr/conf/animation.conf)
    echo "Hyprland animation.conf restored!"

    echo "source = /etc/xdg/hypr/conf/decorations/default.conf" >$(xdg-config-resolve hypr/conf/decoration.conf)
    echo "Hyprland decoration.conf restored!"

    echo "source = /etc/xdg/hypr/conf/windows/default.conf" >$(xdg-config-resolve hypr/conf/window.conf)
    echo "Hyprland window.conf restored!"

    echo "source = /etc/xdg/hypr/conf/monitors/default.conf" >$(xdg-config-resolve hypr/conf/monitor.conf)
    echo "Hyprland monitor.conf restored!"

    echo
    echo ":: Restore done!"
else
    echo ":: Restore canceled!"
    exit
fi
