#!/bin/bash

# ==============================================================================
# AOL DESKTOP ENVIRONMENT INSTALLER (AOL DE)
# Target: Linux Mint 22 (Ubuntu 24.04 Base)
# Author: Senior Linux Desktop Engineer (Gemini)
# Description: Transforms XFCE base into an Openbox/Tint2 AOL 7.0 replica.
# ==============================================================================

set -e

USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
USER_NAME=${SUDO_USER:-$USER}

# Ensure script is not run as root directly, but has sudo access
if [ "$EUID" -eq 0 ]; then 
    echo "Please run this script as your normal user (not root). Sudo will be requested when needed."
    exit 1
fi

echo "[*] Initializing AOL Desktop Environment Setup..."

# ==============================================================================
# 1. SYSTEM PREP & DEPENDENCIES
# ==============================================================================
echo "[*] Installing dependencies..."
sudo apt update -q
sudo apt install -y openbox tint2 jgmenu feh wmctrl firefox thunderbird pidgin git python3-tk python3-pil python3-pil.imagetk build-essential libgdk-pixbuf2.0-dev

# Directories
mkdir -p "$USER_HOME/.config/openbox"
mkdir -p "$USER_HOME/.config/tint2"
mkdir -p "$USER_HOME/.config/jgmenu"
mkdir -p "$USER_HOME/.config/gtk-3.0"
mkdir -p "$USER_HOME/.themes"
mkdir -p "$USER_HOME/.icons"
mkdir -p "$USER_HOME/.local/bin"

# ==============================================================================
# 2. THEME INSTALLATION (Chicago95)
# ==============================================================================
echo "[*] Cloning and installing Chicago95 Theme..."
if [ ! -d "/tmp/Chicago95" ]; then
    git clone https://github.com/grassmunk/Chicago95.git /tmp/Chicago95
fi

# Install GTK Theme and Icons
cp -r /tmp/Chicago95/Theme/Chicago95 "$USER_HOME/.themes/"
cp -r /tmp/Chicago95/Icons/* "$USER_HOME/.icons/"

# Force GTK Settings for the Session (Make it look gray/beveled)
cat <<EOF > "$USER_HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Chicago95
gtk-icon-theme-name=Chicago95
gtk-font-name=Sans 10
gtk-cursor-theme-name=Chicago95
gtk-decoration-layout=menu:minimize,maximize,close
EOF

# Create .gtkrc-2.0 for legacy apps
cat <<EOF > "$USER_HOME/.gtkrc-2.0"
gtk-theme-name="Chicago95"
gtk-icon-theme-name="Chicago95"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Chicago95"
EOF

# ==============================================================================
# 3. THE 'AOL TOOLBAR' (Tint2 Configuration)
# ==============================================================================
echo "[*] Configuring Tint2 (AOL Toolbar)..."

# We need to locate the .desktop files to link them in tint2
# This configuration mimics the thick gray header bar of AOL 6.0
cat <<EOF > "$USER_HOME/.config/tint2/tint2rc"
# AOL Style Tint2 Config

#-------------------------------------
# Backgrounds
#-------------------------------------
# Background 1: The Main Bar (Silver/Gray)
rounded = 0
border_width = 2
border_sides = TBLR
border_content_tint_weight = 0
background_content_tint_weight = 0
background_color = #c0c0c0 100
border_color = #ffffff 60
background_color_hover = #c0c0c0 100
border_color_hover = #ffffff 60
background_color_pressed = #c0c0c0 100
border_color_pressed = #ffffff 60

# Background 2: Buttons/Taskbar items (Beveled look)
rounded = 0
border_width = 1
border_sides = TBLR
background_color = #c0c0c0 100
border_color = #808080 100
background_color_hover = #dcdcdc 100
border_color_hover = #ffffff 100
background_color_pressed = #a0a0a0 100
border_color_pressed = #000000 100

#-------------------------------------
# Panel
#-------------------------------------
panel_items = LTSBC
panel_size = 100% 54
panel_margin = 0 0
panel_padding = 4 4 4
panel_background_id = 1
wm_menu = 1
panel_dock = 0
panel_position = top center
panel_layer = normal
panel_monitor = all
panel_shrink = 0
autohide = 0
autohide_show_timeout = 0
autohide_hide_timeout = 0.5
autohide_height = 1
strut_policy = follow_size
panel_window_name = tint2
disable_transparency = 1
mouse_effects = 1
font_shadow = 0
mouse_hover_icon_asb = 100 0 10
mouse_pressed_icon_asb = 100 0 0
scale_relative_to_dpi = 0
scale_relative_to_screen_height = 0

#-------------------------------------
# Taskbar
#-------------------------------------
taskbar_mode = single_desktop
taskbar_hide_if_empty = 0
taskbar_padding = 2 2 4
taskbar_background_id = 0
taskbar_active_background_id = 2
taskbar_name = 1
taskbar_hide_inactive_tasks = 0
taskbar_hide_different_monitor = 0
taskbar_hide_different_desktop = 0
taskbar_always_show_all_desktop_tasks = 0
taskbar_name_padding = 6 4
taskbar_name_background_id = 0
taskbar_name_active_background_id = 0
taskbar_name_font = Sans Bold 9
taskbar_name_font_color = #000000 100
taskbar_name_active_font_color = #000000 100
taskbar_distribute_size = 0
taskbar_sort_order = none
task_align = left

#-------------------------------------
# Launcher
#-------------------------------------
launcher_padding = 8 4 8
launcher_background_id = 0
launcher_icon_background_id = 0
launcher_size = 32
launcher_icon_size = 32
launcher_item_app = /usr/share/applications/firefox.desktop
launcher_item_app = /usr/share/applications/thunderbird.desktop
launcher_item_app = /usr/share/applications/pidgin.desktop
launcher_tooltip = 1

#-------------------------------------
# Clock
#-------------------------------------
time1_format = %H:%M
time1_font = Sans Bold 10
time1_timezone = 
time1_color = #000000 100
time1_align_right = 1
clock_font_color = #000000 100
clock_padding = 4 4
clock_background_id = 2
clock_lclick_command = jgmenu_run

#-------------------------------------
# Systray
#-------------------------------------
systray_padding = 4 2 4
systray_background_id = 2
systray_sort = ascending
systray_icon_size = 22
systray_icon_asb = 100 0 0
systray_monitor = 1
systray_name_filter = 

#-------------------------------------
# Button (The AOL Start Menu)
#-------------------------------------
button = new
button_icon = /usr/share/icons/Mint-Y/places/64/start-here.png
button_text = AOL
button_lclick_command = jgmenu_run
button_font = Sans Bold 10
button_font_color = #000000 100
button_padding = 8 8
button_background_id = 2
button_centered = 0
button_max_icon_size = 24

EOF

# Configure JGMenu (The Dropdown) to look like Win95
cat <<EOF > "$USER_HOME/.config/jgmenu/jgmenurc"
tint2_look = 1
color_menu_bg = #c0c0c0 100
color_norm_fg = #000000 100
color_sel_bg = #000080 100
color_sel_fg = #ffffff 100
font = Sans 10
EOF

# ==============================================================================
# 4. THE 'AOL BROWSER' (Firefox Customization)
# ==============================================================================
echo "[*] Configuring Firefox as 'AOL Internal Browser'..."

# Create a specific profile directory manually to avoid needing GUI
FF_PROFILE_DIR="$USER_HOME/.mozilla/firefox/aol_desktop.default"
mkdir -p "$FF_PROFILE_DIR/chrome"

# Update profiles.ini to register it
if [ ! -f "$USER_HOME/.mozilla/firefox/profiles.ini" ]; then
    mkdir -p "$USER_HOME/.mozilla/firefox"
    cat <<EOF > "$USER_HOME/.mozilla/firefox/profiles.ini"
[Profile0]
Name=AOL
IsRelative=1
Path=aol_desktop.default
Default=1

[General]
StartWithLastProfile=1
Version=2
EOF
fi

# Enable userChrome.css support
cat <<EOF > "$FF_PROFILE_DIR/user.js"
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.tabs.drawInTitlebar", true);
EOF

# The CSS to remove standard browser elements and make it look like a content frame
cat <<EOF > "$FF_PROFILE_DIR/chrome/userChrome.css"
/* AOL Style: Hide Tabs and minimal URL bar */
#TabsToolbar { visibility: collapse !important; }
#sidebar-header { display: none !important; }

/* Make the nav bar look blocky and gray */
#nav-bar {
    background-color: #c0c0c0 !important;
    border-bottom: 1px solid #808080 !important;
    box-shadow: none !important;
}

#urlbar-container {
    border: 2px inset #dfdfdf !important;
}
EOF

# ==============================================================================
# 5. THE 'WELCOME SCREEN' (Python/Tkinter)
# ==============================================================================
echo "[*] Creating 'Welcome' Application..."

cat <<EOF > "$USER_HOME/.local/bin/aol-welcome"
#!/usr/bin/python3
import tkinter as tk
from tkinter import font
import os

def launch_browser():
    os.system("firefox -P AOL &")

def launch_mail():
    os.system("thunderbird &")

root = tk.Tk()
root.title("Welcome!")
root.geometry("600x400")
root.configure(bg="#ffffff")

# Banner
header = tk.Frame(root, bg="#003399", height=80)
header.pack(fill="x")
lbl_title = tk.Label(header, text="Welcome, User!", bg="#003399", fg="white", font=("Arial", 24, "bold"))
lbl_title.place(x=20, y=20)

# Main Content
content = tk.Frame(root, bg="#c0c0c0")
content.pack(fill="both", expand=True, padx=10, pady=10)

# Mail Notification
lbl_mail = tk.Label(content, text="YOU HAVE MAIL", bg="#c0c0c0", fg="#003399", font=("Arial", 16, "bold"))
lbl_mail.pack(pady=20)

btn_mail = tk.Button(content, text="Read Mail", command=launch_mail, relief="raised", borderwidth=3)
btn_mail.pack(pady=5)

# Fake News
separator = tk.Frame(content, height=2, bd=1, relief="sunken")
separator.pack(fill="x", padx=20, pady=20)

lbl_news = tk.Label(content, text="Today's Headlines:", bg="#c0c0c0", font=("Arial", 12, "bold"))
lbl_news.pack(anchor="w", padx=20)

news_items = [
    "DOT COM BUBBLE: Is it finally over?",
    "Napster faces new legal challenges",
    "Top 10 tips for your Palm Pilot"
]

for item in news_items:
    lbl = tk.Label(content, text="> " + item, bg="#c0c0c0", fg="blue", cursor="hand2", font=("Arial", 10, "underline"))
    lbl.pack(anchor="w", padx=30)
    lbl.bind("<Button-1>", lambda e: launch_browser())

root.mainloop()
EOF
chmod +x "$USER_HOME/.local/bin/aol-welcome"

# ==============================================================================
# 6. OPENBOX CONFIGURATION (rc.xml)
# ==============================================================================
echo "[*] Configuring Openbox..."

# Copy default configuration first if it doesn't exist
if [ ! -f "$USER_HOME/.config/openbox/rc.xml" ]; then
    cp /etc/xdg/openbox/rc.xml "$USER_HOME/.config/openbox/rc.xml" || true
fi

# NOTE: Properly parsing XML in bash is hard. We will overwrite the rc.xml 
# with a focused configuration that imports the Chicago95 theme and manages the Panel.
# If you have a complex existing openbox setup, back it up.

cat <<EOF > "$USER_HOME/.config/openbox/rc.xml"
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">
  <theme>
    <name>Chicago95</name>
    <titleLayout>ILMC</titleLayout>
    <keepBorder>yes</keepBorder>
    <animateIconify>yes</animateIconify>
    <font place="ActiveWindow">
      <name>Sans</name>
      <size>10</size>
      <weight>Bold</weight>
      <slant>Normal</slant>
    </font>
    <font place="InactiveWindow">
      <name>Sans</name>
      <size>10</size>
      <weight>Normal</weight>
      <slant>Normal</slant>
    </font>
  </theme>
  <desktops>
    <number>1</number>
    <firstdesk>1</firstdesk>
    <names>
      <name>AOL Desktop</name>
    </names>
  </desktops>
  <resize>
    <drawContents>yes</drawContents>
    <popupShow>Nonpixel</popupShow>
    <popupPosition>Center</popupPosition>
  </resize>
  <dock>
    <position>Top</position>
    <floatingX>0</floatingX>
    <floatingY>0</floatingY>
    <noStrut>no</noStrut>
    <stacking>Above</stacking>
    <direction>Horizontal</direction>
    <autoHide>no</autoHide>
    <hideDelay>300</hideDelay>
    <showDelay>300</showDelay>
    <moveButton>Middle</moveButton>
  </dock>
  <keyboard>
    <chainQuitKey>C-g</chainQuitKey>
    <keybind key="A-F4"><action name="Close"/></keybind>
    <keybind key="A-Tab"><action name="NextWindow"/></keybind>
    <keybind key="A-S-Tab"><action name="PreviousWindow"/></keybind>
    <keybind key="W-e"><action name="Execute"><command>thunar</command></action></keybind>
  </keyboard>
  <mouse>
    <dragThreshold>1</dragThreshold>
    <doubleClickTime>500</doubleClickTime>
    <screenEdgeWarpTime>400</screenEdgeWarpTime>
    <screenEdgeWarpMouse>false</screenEdgeWarpMouse>
    <context name="Frame">
      <mousebind button="A-Left" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
      </mousebind>
      <mousebind button="A-Left" action="Click">
        <action name="Unshade"/>
      </mousebind>
      <mousebind button="A-Left" action="Drag">
        <action name="Move"/>
      </mousebind>
      <mousebind button="A-Right" action="Press">
        <action name="Focus"/>
        <action name="Raise"/>
        <action name="ShowMenu"><menu>client-menu</menu></action>
      </mousebind>
    </context>
  </mouse>
  <applications>
    <application class="tint2">
      <decor>no</decor>
      <layer>above</layer>
    </application>
    <application title="Welcome!">
      <position force="yes">
        <x>center</x>
        <y>center</y>
      </position>
      <decor>yes</decor>
    </application>
  </applications>
</openbox_config>
EOF

# ==============================================================================
# 7. SESSION HIJACK (Startup Scripts)
# ==============================================================================
echo "[*] Creating Startup Script and Session file..."

# The script that runs when the session starts
cat <<EOF > "$USER_HOME/.local/bin/start_aol_env.sh"
#!/bin/bash

# 1. Apply GTK Theme explicitly
export GTK2_RC_FILES="$USER_HOME/.gtkrc-2.0"
/usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd &

# 2. Set Background (AOL Blue #5080b0)
feh --bg-fill --no-fehbg --image-bg "#5080b0" /usr/share/backgrounds/xfce/xfce-blue.jpg
# Actually, force solid color by using a small solid tile or just xsetroot if feh fails on color alone
xsetroot -solid "#5080b0"

# 3. Network Manager Applet
nm-applet &

# 4. Start Tint2 (The Panel)
tint2 &

# 5. Start Openbox
openbox --startup "$USER_HOME/.local/bin/aol-welcome"
EOF
chmod +x "$USER_HOME/.local/bin/start_aol_env.sh"

# The XSession entry (Requires Root)
sudo bash -c "cat <<EOF > /usr/share/xsessions/aol-desktop.desktop
[Desktop Entry]
Name=AOL Desktop
Comment=Login to the AOL Desktop Environment
Exec=$USER_HOME/.local/bin/start_aol_env.sh
Type=Application
DesktopNames=AOL
EOF"

# ==============================================================================
# 8. COMPLETION
# ==============================================================================

echo "==========================================================="
echo "  AOL DESKTOP SETUP COMPLETE"
echo "==========================================================="
echo "Next Steps:"
echo "1. Save any open work."
echo "2. Log out of your current session."
echo "3. At the Login Screen, click the Session icon (Gear/Logo)."
echo "4. Select 'AOL Desktop'."
echo "5. Log in."
echo ""
echo "To revert: Select 'Xfce Session' at the login screen."
echo "==========================================================="
