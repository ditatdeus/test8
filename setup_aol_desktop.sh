#!/bin/bash

# ==============================================================================
# AOL DESKTOP ENVIRONMENT INSTALLER (Complete Edition)
# Target: Linux Mint 22 / Ubuntu 24.04 Base
# Description: Transforms XFCE/Gnome base into an AOL 7.0 replica.
# Features: Chicago95 Theme, Giant AOL Toolbar, "You Have Mail" Welcome Screen.
# ==============================================================================

set -e

USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
USER_NAME=${SUDO_USER:-$USER}

# ------------------------------------------------------------------------------
# PRE-FLIGHT CHECKS
# ------------------------------------------------------------------------------
if [ "$EUID" -eq 0 ]; then 
    echo "STOP: Please run this script as your normal user (./install_aol.sh)."
    echo "Sudo password will be requested only when installing packages."
    exit 1
fi

echo "==========================================================="
echo "[*] Initializing AOL Desktop Environment Setup..."
echo "==========================================================="

# ------------------------------------------------------------------------------
# 1. INSTALL DEPENDENCIES
# ------------------------------------------------------------------------------
echo "[*] Installing system dependencies..."
sudo apt update -q
# Added imagemagick to generate the custom AOL icons programmatically
sudo apt install -y openbox tint2 jgmenu feh wmctrl firefox thunderbird pidgin \
    git python3-tk python3-pil python3-pil.imagetk build-essential \
    libgdk-pixbuf2.0-dev imagemagick libcanberra-gtk-module vorbis-tools \
    alsa-utils

# Create Directory Structure
echo "[*] Creating directory structure..."
mkdir -p "$USER_HOME/.config/openbox"
mkdir -p "$USER_HOME/.config/tint2"
mkdir -p "$USER_HOME/.config/jgmenu"
mkdir -p "$USER_HOME/.config/gtk-3.0"
mkdir -p "$USER_HOME/.themes"
mkdir -p "$USER_HOME/.icons/aol-custom"
mkdir -p "$USER_HOME/.local/bin"
mkdir -p "$USER_HOME/.local/share/applications"

# ------------------------------------------------------------------------------
# 2. THEME INSTALLATION (Chicago95)
# ------------------------------------------------------------------------------
echo "[*] Installing Chicago95 Theme (Windows 95 aesthetic)..."
if [ ! -d "/tmp/Chicago95" ]; then
    git clone https://github.com/grassmunk/Chicago95.git /tmp/Chicago95
fi

# Install GTK Theme and Icons
cp -r /tmp/Chicago95/Theme/Chicago95 "$USER_HOME/.themes/" 2>/dev/null || true
cp -r /tmp/Chicago95/Icons/* "$USER_HOME/.icons/" 2>/dev/null || true

# Force GTK Settings (Gray/Beveled Look)
cat <<EOF > "$USER_HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Chicago95
gtk-icon-theme-name=Chicago95
gtk-font-name=Sans 10
gtk-cursor-theme-name=Chicago95
gtk-decoration-layout=menu:minimize,maximize,close
EOF

# Legacy GTK2 settings
cat <<EOF > "$USER_HOME/.gtkrc-2.0"
gtk-theme-name="Chicago95"
gtk-icon-theme-name="Chicago95"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Chicago95"
EOF

# ------------------------------------------------------------------------------
# 3. GENERATE AOL ASSETS (ICONS)
# ------------------------------------------------------------------------------
echo "[*] Generating Custom AOL Icons..."

# Mail Icon (Yellow with Blue center)
convert -size 48x48 xc:yellow -fill blue -draw "circle 24,24 10,10" "$USER_HOME/.icons/aol-custom/mail.png"
# People Icon (Blue with White center)
convert -size 48x48 xc:blue -fill white -draw "circle 24,24 20,20" "$USER_HOME/.icons/aol-custom/people.png"
# Channels Icon (Green)
convert -size 48x48 xc:green -fill white -draw "rectangle 10,20 38,28" "$USER_HOME/.icons/aol-custom/channels.png"
# Favorites Icon (Red Heart-ish)
convert -size 48x48 xc:transparent -fill red -draw "circle 24,24 20,20" "$USER_HOME/.icons/aol-custom/favorites.png"

# Create Custom Desktop Entries for the Toolbar
cat <<EOF > "$USER_HOME/.local/share/applications/aol-mail.desktop"
[Desktop Entry]
Name=Read Mail
Exec=thunderbird
Icon=$USER_HOME/.icons/aol-custom/mail.png
Type=Application
EOF

cat <<EOF > "$USER_HOME/.local/share/applications/aol-people.desktop"
[Desktop Entry]
Name=People Connection
Exec=pidgin
Icon=$USER_HOME/.icons/aol-custom/people.png
Type=Application
EOF

cat <<EOF > "$USER_HOME/.local/share/applications/aol-channels.desktop"
[Desktop Entry]
Name=Channels
Exec=firefox -P AOL
Icon=$USER_HOME/.icons/aol-custom/channels.png
Type=Application
EOF

# ------------------------------------------------------------------------------
# 4. THE 'AOL TOOLBAR' (Tint2)
# ------------------------------------------------------------------------------
echo "[*] Configuring Tint2 (The Big Header Bar)..."

cat <<EOF > "$USER_HOME/.config/tint2/tint2rc"
# AOL 7.0 Style Header Bar

#-------------------------------------
# Backgrounds
#-------------------------------------
# BG 1: The Main Container (AOL Beige/Gray)
rounded = 0
border_width = 2
border_sides = B
background_color = #d4d0c8 100
border_color = #808080 100

# BG 2: The URL/Keyword Bar (White inset)
rounded = 2
border_width = 2
background_color = #ffffff 100
border_color = #808080 100

#-------------------------------------
# Panel
#-------------------------------------
# L=Launcher, E=Executor (Fake URL bar), S=Systray, C=Clock
panel_items = LESC
# MAKE IT TALL: AOL headers were thick
panel_size = 100% 74
panel_margin = 0 0
panel_padding = 5 5 5
panel_background_id = 1
wm_menu = 0
panel_dock = 0
panel_position = top center
panel_layer = top
strut_policy = follow_size
panel_window_name = aol_bar
disable_transparency = 1

#-------------------------------------
# Launcher (The Big Buttons)
#-------------------------------------
launcher_padding = 15 5 15
launcher_background_id = 0
launcher_icon_background_id = 0
launcher_size = 64
launcher_icon_size = 48
launcher_item_app = $USER_HOME/.local/share/applications/aol-mail.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-people.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-channels.desktop
launcher_tooltip = 1

#-------------------------------------
# Executor (Faking the URL/Keyword Bar)
#-------------------------------------
execp = new
execp_command = echo "Type Keyword or Web Address here and click Go"
execp_interval = 0
execp_has_icon = 0
execp_cache_icon = 0
execp_continuous = 0
execp_markup = 1
execp_font = Sans 12
execp_font_color = #555555 100
execp_padding = 10 15
execp_background_id = 2
execp_centered = 0
execp_lclick_command = firefox -P AOL
EOF

# JGMenu Config (Right click menu)
cat <<EOF > "$USER_HOME/.config/jgmenu/jgmenurc"
tint2_look = 1
color_menu_bg = #c0c0c0 100
color_norm_fg = #000000 100
color_sel_bg = #000080 100
color_sel_fg = #ffffff 100
font = Sans 10
EOF

# ------------------------------------------------------------------------------
# 5. THE 'AOL BROWSER' (Firefox Customization)
# ------------------------------------------------------------------------------
echo "[*] Configuring Firefox as 'AOL Internal Browser'..."

FF_PROFILE_DIR="$USER_HOME/.mozilla/firefox/aol_desktop.default"
mkdir -p "$FF_PROFILE_DIR/chrome"

# Register Profile
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
user_pref("browser.startup.homepage", "about:blank");
EOF

# CSS to hide tabs and nav bar (Since Tint2 acts as the nav bar)
cat <<EOF > "$FF_PROFILE_DIR/chrome/userChrome.css"
/* AOL Style: Hide Tabs and UI to make it look like an embedded window */
#TabsToolbar { visibility: collapse !important; }
#sidebar-header { display: none !important; }
#nav-bar { visibility: collapse !important; }
EOF

# ------------------------------------------------------------------------------
# 6. THE WELCOME SCREEN (Python/Tkinter)
# ------------------------------------------------------------------------------
echo "[*] Creating 'Welcome' Application..."

cat <<EOF > "$USER_HOME/.local/bin/aol-welcome"
#!/usr/bin/python3
import tkinter as tk
from tkinter import font
import os
import subprocess

def launch_browser(url=""):
    cmd = "firefox -P AOL"
    if url:
        cmd += f" {url} &"
    else:
        cmd += " &"
    os.system(cmd)

def launch_mail():
    os.system("thunderbird &")

def play_sound():
    try:
        # Attempt to play standard login sound
        subprocess.Popen(["paplay", "/usr/share/sounds/freedesktop/stereo/service-login.oga"])
    except:
        pass

root = tk.Tk()
root.title("Welcome")
root.geometry("720x500")
root.configure(bg="#d4d0c8")

# Play sound
root.after(500, play_sound)

# -- HEADER --
header = tk.Frame(root, bg="white", height=60, highlightthickness=1, highlightbackground="#808080")
header.pack(fill="x", padx=5, pady=5)
lbl_logo = tk.Label(header, text="AOL Service", bg="white", fg="black", font=("Times New Roman", 24, "bold italic"))
lbl_logo.pack(side="left", padx=20)

# -- MAIN CONTAINER --
main_frame = tk.Frame(root, bg="#d4d0c8")
main_frame.pack(fill="both", expand=True, padx=5, pady=5)

# -- LEFT COLUMN (Big Buttons) --
left_col = tk.Frame(main_frame, bg="#d4d0c8", width=250)
left_col.pack(side="left", fill="y", padx=5)

# Mail Button
btn_mail_frame = tk.Frame(left_col, bg="#d4d0c8", bd=2, relief="raised")
btn_mail_frame.pack(fill="x", pady=5)
lbl_mail_icon = tk.Label(btn_mail_frame, text="✉", font=("Arial", 40), bg="#d4d0c8", fg="#d4a010")
lbl_mail_icon.pack()
btn_mail = tk.Button(btn_mail_frame, text="YOU HAVE MAIL", command=launch_mail, font=("Arial", 11, "bold"), bg="#d4d0c8", relief="flat")
btn_mail.pack(fill="x")

# Pictures Button
btn_pix_frame = tk.Frame(left_col, bg="#d4d0c8", bd=2, relief="raised")
btn_pix_frame.pack(fill="x", pady=5)
lbl_pix_icon = tk.Label(btn_pix_frame, text="📷", font=("Arial", 30), bg="#d4d0c8", fg="purple")
lbl_pix_icon.pack()
btn_pix = tk.Button(btn_pix_frame, text="You Have Pictures", font=("Arial", 10), bg="#d4d0c8", relief="flat")
btn_pix.pack(fill="x")

# -- RIGHT COLUMN (Content) --
right_col = tk.Frame(main_frame, bg="#ffffff", bd=2, relief="sunken")
right_col.pack(side="right", fill="both", expand=True, padx=5)

lbl_top_news = tk.Label(right_col, text=" TOP NEWS STORY", bg="#003366", fg="white", font=("Arial", 10, "bold"), anchor="w")
lbl_top_news.pack(fill="x")

lbl_headline = tk.Label(right_col, text="System Upgrade Complete", bg="white", fg="black", font=("Arial", 16, "bold"), wraplength=350, justify="left")
lbl_headline.pack(anchor="w", padx=10, pady=15)

lbl_sub = tk.Label(right_col, text="Your Linux system has been successfully transformed into a Classic Online Experience.", bg="white", fg="black", font=("Arial", 10), wraplength=350, justify="left")
lbl_sub.pack(anchor="w", padx=10)

btn_read_more = tk.Button(right_col, text="Go to Web", command=lambda: launch_browser("https://google.com"), fg="blue", bg="white", relief="flat", cursor="hand2")
btn_read_more.pack(anchor="w", padx=10, pady=20)

root.mainloop()
EOF
chmod +x "$USER_HOME/.local/bin/aol-welcome"

# ------------------------------------------------------------------------------
# 7. OPENBOX CONFIGURATION
# ------------------------------------------------------------------------------
echo "[*] Configuring Openbox Window Manager..."

if [ ! -f "$USER_HOME/.config/openbox/rc.xml" ]; then
    cp /etc/xdg/openbox/rc.xml "$USER_HOME/.config/openbox/rc.xml" || true
fi

# Overwrite with AOL-specific window settings
cat <<EOF > "$USER_HOME/.config/openbox/rc.xml"
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">
  <theme>
    <name>Chicago95</name>
    <titleLayout>ILMC</titleLayout>
    <keepBorder>yes</keepBorder>
    <font place="ActiveWindow">
      <name>Sans</name><size>10</size><weight>Bold</weight>
    </font>
    <font place="InactiveWindow">
      <name>Sans</name><size>10</size><weight>Normal</weight>
    </font>
  </theme>
  <desktops>
    <number>1</number>
    <names><name>AOL Desktop</name></names>
  </desktops>
  <dock>
    <position>Top</position>
    <stacking>Above</stacking>
    <autoHide>no</autoHide>
  </dock>
  <mouse>
    <context name="Frame">
      <mousebind button="A-Right" action="Press">
        <action name="ShowMenu"><menu>root-menu</menu></action>
      </mousebind>
    </context>
    <context name="Root">
       <mousebind button="Right" action="Press">
         <action name="Execute"><command>jgmenu_run</command></action>
       </mousebind>
    </context>
  </mouse>
  <applications>
    <application title="Welcome">
      <position force="yes"><x>center</x><y>center</y></position>
      <decor>yes</decor>
    </application>
  </applications>
</openbox_config>
EOF

# ------------------------------------------------------------------------------
# 8. STARTUP SCRIPT & SESSION
# ------------------------------------------------------------------------------
echo "[*] Creating Session Startup Scripts..."

cat <<EOF > "$USER_HOME/.local/bin/start_aol_env.sh"
#!/bin/bash

# 1. Apply GTK Theme explicitly
export GTK2_RC_FILES="$USER_HOME/.gtkrc-2.0"

# 2. Set Background (MDI Grey #808080 - The classic Windows 'Application Workspace' color)
# This mimics the background of the AOL MDI window.
xsetroot -solid "#808080"

# 3. Start Tint2 (The AOL Toolbar)
tint2 &

# 4. Start Openbox (Window Manager)
# Launch the Welcome Screen immediately upon Openbox start
openbox --startup "$USER_HOME/.local/bin/aol-welcome"
EOF
chmod +x "$USER_HOME/.local/bin/start_aol_env.sh"

# Create Login Manager Entry
sudo bash -c "cat <<EOF > /usr/share/xsessions/aol-desktop.desktop
[Desktop Entry]
Name=AOL Desktop
Comment=Login to the AOL Desktop Environment
Exec=$USER_HOME/.local/bin/start_aol_env.sh
Type=Application
DesktopNames=AOL
EOF"

# ------------------------------------------------------------------------------
# 9. FINISH
# ------------------------------------------------------------------------------
echo "==========================================================="
echo "   AOL DESKTOP SETUP COMPLETE"
echo "==========================================================="
echo "To enter the AOL Environment:"
echo "1. Save your work and LOG OUT."
echo "2. At the login screen, click the Gear/Session icon."
echo "3. Select 'AOL Desktop'."
echo "4. Login."
echo ""
echo "To exit: Right-click the desktop background -> Log Out."
echo "==========================================================="
