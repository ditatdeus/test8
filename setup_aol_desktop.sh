#!/bin/bash
# ==============================================================================
# AOL 7.0 Desktop Environment Installer – FINAL VERSION (No paplay dependency)
# Target: Linux Mint 22 / 22.1 (XFCE) or Ubuntu 24.04
# Date: November 2025
# ==============================================================================

set -e

USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
USER_NAME=${SUDO_USER:-$USER}

if [ "$EUID" -eq 0 ]; then
    echo "Do not run as root. Run as normal user."
    exit 1
fi

echo "==========================================================="
echo "   AOL 7.0 Desktop Environment Installer (Final – No paplay)"
echo "==========================================================="

# ----------------------------------------------------------------------
# 1. Dependencies (pulseaudio-utils removed)
# ----------------------------------------------------------------------
sudo apt update -q
sudo apt install -y openbox obconf tint2 jgmenu feh wmctrl volumeicon-alsa \
    firefox thunderbird pidgin pidgin-plugin-pack \
    git python3-tk python3-pil python3-pil.imagetk \
    imagemagick xdotool curl libcanberra-gtk-module \
    alsa-utils

# ----------------------------------------------------------------------
# 2. Directory structure
# ----------------------------------------------------------------------
mkdir -p "$USER_HOME/.config"/{openbox,tint2,jgmenu,gtk-3.0}
mkdir -p "$USER_HOME/.themes" "$USER_HOME/.icons/aol-custom"
mkdir -p "$USER_HOME/.local/bin" "$USER_HOME/.local/share/applications"
mkdir -p "$USER_HOME/.cache/aol"

# ----------------------------------------------------------------------
# 3. Chicago95 theme
# ----------------------------------------------------------------------
echo "[*] Installing Chicago95 theme..."
if [ ! -d "/tmp/Chicago95" ]; then
    git clone https://github.com/grassmunk/Chicago95.git /tmp/Chicago95
fi
cp -r /tmp/Chicago95/Theme/Chicago95 "$USER_HOME/.themes/"
cp -r /tmp/Chicago95/Icons/Chicago95 "$USER_HOME/.icons/"
cp -r /tmp/Chicago95/Icons/Chicago95-cursors "$USER_HOME/.icons/" 2>/dev/null || true

cat <<EOF > "$USER_HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Chicago95
gtk-icon-theme-name=Chicago95
gtk-cursor-theme-name=Chicago95-cursors
gtk-font-name=MS Sans Serif 8
gtk-button-images=1
gtk-menu-images=1
gtk-decoration-layout=menu:minimize,maximize,close
EOF

cat <<EOF > "$USER_HOME/.gtkrc-2.0"
gtk-theme-name = "Chicago95"
gtk-icon-theme-name = "Chicago95"
gtk-cursor-theme-name = "Chicago95-cursors"
gtk-font-name = "MS Sans Serif 8"
EOF

# ----------------------------------------------------------------------
# 4. AOL icons + welcome sound (optional)
# ----------------------------------------------------------------------
echo "[*] Downloading AOL assets (icons + sound)..."
curl -sL https://winworldpc.com/download/c39fc29c-18c2-11e7-8080-800020c7487f -o /tmp/aol70.zip 2>/dev/null || true

# Extract real welcome sound if possible
unzip -qj /tmp/aol70.zip "AOL 7.0/*.wav" -d "$USER_HOME/.cache/aol/" 2>/dev/null || true
[ -f "$USER_HOME/.cache/aol/welcome.wav" ] || true  # silent if missing

# Icons (real ones from AOL 7.0 if available, fallback to generated)
convert "/tmp/aol70.zip[AOL 7.0/art/mail.ico]" -resize 48x48 "$USER_HOME/.icons/aol-custom/mail.png" 2>/dev/null || \
    convert -size 48x48 xc:#ffcc00 -fill blue -draw "circle 24,24 10,10" "$USER_HOME/.icons/aol-custom/mail.png"
convert "/tmp/aol70.zip[AOL 7.0/art/buddy.ico]" -resize 48x48 "$USER_HOME/.icons/aol-custom/people.png" 2>/dev/null || \
    convert -size 48x48 xc:blue -fill white -draw "circle 24,24 20,20" "$USER_HOME/.icons/aol-custom/people.png"
convert -size 48x48 xc:#00cc00 -fill white -draw "rectangle 10,20 38,28" "$USER_HOME/.icons/aol-custom/channels.png"
convert -size 48x48 xc:none -fill red -draw "path 'M24,12 Q12,24 24,36 Q36,24 24,12 Z'" "$USER_HOME/.icons/aol-custom/favorites.png"

# ----------------------------------------------------------------------
# 5. Desktop entries
# ----------------------------------------------------------------------
cat <<EOF > "$USER_HOME/.local/share/applications/aol-mail.desktop"
[Desktop Entry]
Name=Read Mail
Exec=thunderbird
Icon=$USER_HOME/.icons/aol-custom/mail.png
Type=Application
EOF

cat <<EOF > "$USER_HOME/.local/share/applications/aol-people.desktop"
[Desktop Entry]
Name=People
Exec=pidgin
Icon=$USER_HOME/.icons/aol-custom/people.png
Type=Application
EOF

cat <<EOF > "$USER_HOME/.local/share/applications/aol-browser.desktop"
[Desktop Entry]
Name=Internet
Exec=firefox -P AOL --no-remote
Icon=firefox
Type=Application
EOF

# ----------------------------------------------------------------------
# 6. Tint2 (AOL toolbar)
# ----------------------------------------------------------------------
cat <<EOF > "$USER_HOME/.config/tint2/tint2rc"
rounded = 0
border_width = 2
border_sides = B
background_color = #d4d0c8 100
border_color = #808080 100

panel_items = LTSBC
panel_size = 100% 96
panel_margin = 0 0
panel_padding = 4 4 8
panel_background_id = 1
panel_layer = top
strut_policy = follow_size
disable_transparency = 1
wm_menu = 0
taskbar_mode = multi_desktop
taskbar_padding = 4 2 4
task_icon = 1
task_text = 0

launcher_padding = 10 0 20
launcher_background_id = 0
launcher_icon_size = 64
launcher_item_app = $USER_HOME/.local/share/applications/aol-mail.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-people.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-browser.desktop

time1_format = %l:%M %p
time1_font = MS Sans Serif Bold 10
clock_padding = 8 2

systray_padding = 8 2 8
systray_icon_size = 24

execp = new
execp_command = echo "Keyword or Web Address"
execp_font = MS Sans Serif 11
execp_font_color = #000000 100
execp_padding = 10 4
execp_background_id = 2
execp_lclick_command = firefox -P AOL --no-remote
execp_tooltip = Click to open Internet
EOF

# ----------------------------------------------------------------------
# 7. Openbox
# ----------------------------------------------------------------------
cp /etc/xdg/openbox/rc.xml "$USER_HOME/.config/openbox/rc.xml" 2>/dev/null || true
cat <<EOF > "$USER_HOME/.config/openbox/rc.xml"
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <theme>
    <name>Chicago95</name>
    <titleLayout>NLIMC</titleLayout>
  </theme>
  <desktops>
    <number>1</number>
    <names><name>AOL Desktop</name></names>
  </desktops>
  <dock>
    <position>Top</position>
    <autohide>no</autohide>
  </dock>
</openbox_config>
EOF

cat <<EOF > "$USER_HOME/.config/openbox/autostart"
feh --bg-fill /usr/share/backgrounds/linuxmint/default_background.jpg || xsetroot -solid "#008080" &
tint2 &
volumeicon &
(sleep 2 && "$USER_HOME/.local/bin/aol-welcome") &
EOF

# ----------------------------------------------------------------------
# 8. Welcome screen – NOW USES aplay (Option 1 applied)
# ----------------------------------------------------------------------
cat <<'EOF' > "$USER_HOME/.local/bin/aol-welcome"
#!/usr/bin/python3
import tkinter as tk, os, subprocess

def play_wav():
    f = os.path.expanduser("~/.cache/aol/welcome.wav")
    if os.path.exists(f):
        subprocess.Popen(["aplay", "-q", f])

root = tk.Tk()
root.title("Welcome to AOL 7.0")
root.geometry("760x520")
root.configure(bg="#d4d0c8")
root.after(300, play_wav)

head = tk.Frame(root, bg="white", height=70)
head.pack(fill="x", padx=8, pady=8)
tk.Label(head, text="America Online", font=("Times New Roman", 28, "bold italic"), bg="white").pack(side="left", padx=20)

main = tk.Frame(root, bg="#d4d0c8")
main.pack(fill="both", expand=True)

left = tk.Frame(main, bg="#d4d0c8")
left.pack(side="left", padx=20, pady=20, anchor="n")

btn = tk.Button(left, text="  YOU'VE GOT MAIL  ", font=("Arial Black", 16), bg="#ffcc00", fg="navy",
                command=lambda: os.system("thunderbird &"))
btn.pack(pady=20, ipadx=20, ipady=10)

right = tk.Frame(main, bg="white", relief="sunken", bd=2)
right.pack(side="right", fill="both", expand=True, padx=20, pady=20)
tk.Label(right, text="Welcome!", font=("Arial", 20, "bold"), bg="white").pack(anchor="w", pady=20, padx=20)
tk.Label(right, text="You've got the classic online experience.", bg="white", font=("Arial", 10)).pack(anchor="w", padx=20)

root.mainloop()
EOF
chmod +x "$USER_HOME/.local/bin/aol-welcome"

# ----------------------------------------------------------------------
# 9. Firefox profile
# ----------------------------------------------------------------------
FF_BASE="$USER_HOME/.mozilla/firefox"
mkdir -p "$FF_BASE"
if ! grep -q "AOL" "$FF_BASE/profiles.ini" 2>/dev/null; then
    PROF=$(firefox -CreateProfile "AOL $FF_BASE/aol.profile" | grep -o 'aol\.profile[^ ]*')
    cat > "$FF_BASE/profiles.ini" <<EOF
[Profile0]
Name=AOL
IsRelative=1
Path=$PROF
Default=1

[General]
StartWithLastProfile=1
EOF
else
    PROF=$(grep Path= "$FF_BASE/profiles.ini" | grep AOL | cut -d= -f2)
fi

FF_PROFILE="$FF_BASE/$PROF"
mkdir -p "$FF_PROFILE/chrome"
cat <<EOF > "$FF_PROFILE/user.js"
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.tabs.drawInTitlebar", false);
user_pref("browser.startup.homepage", "https://www.aol.com");
EOF

cat <<EOF > "$FF_PROFILE/chrome/userChrome.css"
#TabsToolbar { visibility: collapse !important; }
#navigator-toolbox { border-top: none !important; }
EOF

# ----------------------------------------------------------------------
# 10. Session + startup script
# ----------------------------------------------------------------------
sudo tee /usr/share/xsessions/aol7.desktop > /dev/null <<EOF
[Desktop Entry]
Name=AOL 7.0 Desktop
Comment=You've Got Mail!
Exec=$USER_HOME/.local/bin/start_aol.sh
TryExec=$USER_HOME/.local/bin/start_aol.sh
Type=Application
DesktopNames=AOL
EOF

cat <<EOF > "$USER_HOME/.local/bin/start_aol.sh"
#!/bin/bash
export GTK2_RC_FILES="$USER_HOME/.gtkrc-2.0"
exec openbox-session
EOF
chmod +x "$USER_HOME/.local/bin/start_aol.sh"

# ----------------------------------------------------------------------
# Done
# ----------------------------------------------------------------------
echo "==========================================================="
echo "   INSTALLATION COMPLETE – NO paplay REQUIRED"
echo "==========================================================="
echo "Log out → choose 'AOL 7.0 Desktop' from the session menu"
echo "Sound now uses aplay (works silently if no welcome.wav)"
echo "==========================================================="
