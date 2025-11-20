#!/bin/bash
# ==============================================================================
# AOL 7.0 Desktop Environment Installer – UPDATED NOV 2025
# Changes: Top menu bar + blue background + News/Finance/Terminal buttons
# ==============================================================================

set -e

USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
USER_NAME=${SUDO_USER:-$USER}

if [ "$EUID" -eq 0 ]; then
    echo "Do not run as root."
    exit 1
fi

echo "==========================================================="
echo "   AOL 7.0 Desktop – Blue Theme + Extra Buttons"
echo "==========================================================="

sudo apt update -q
sudo apt install -y openbox obconf tint2 jgmenu feh wmctrl volumeicon-alsa \
    firefox thunderbird pidgin pidgin-plugin-pack xfce4-terminal \
    git python3-tk python3-pil python3-pil.imagetk \
    imagemagick xdotool curl libcanberra-gtk-module alsa-utils

mkdir -p "$USER_HOME/.config"/{openbox,tint2,jgmenu,gtk-3.0}
mkdir -p "$USER_HOME/.themes" "$USER_HOME/.icons/aol-custom"
mkdir -p "$USER_HOME/.local/bin" "$USER_HOME/.local/share/applications"
mkdir -p "$USER_HOME/.cache/aol"

# Chicago95 theme
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
EOF
cat <<EOF > "$USER_HOME/.gtkrc-2.0"
gtk-theme-name = "Chicago95"
gtk-icon-theme-name = "Chicago95"
gtk-cursor-theme-name = "Chicago95-cursors"
gtk-font-name = "MS Sans Serif 8"
EOF

# Icons
convert -size 48x48 xc:#ffcc00 -fill blue -draw "circle 24,24 10,10" "$USER_HOME/.icons/aol-custom/mail.png"
convert -size 48x48 xc:blue -fill white -draw "circle 24,24 20,20" "$USER_HOME/.icons/aol-custom/people.png"
convert -size 48x48 xc:#006600 -fill white -draw "rectangle 8,18 40,30" "$USER_HOME/.icons/aol-custom/news.png"
convert -size 48x48 xc:#0022aa -fill yellow -draw "polygon 24,8 16,36 32,36" "$USER_HOME/.icons/aol-custom/finance.png"
convert -size 48x48 xc:black -fill white -draw "rectangle 8,10 40,38" -fill gray -draw "rectangle 12,14 36,20" "$USER_HOME/.icons/aol-custom/terminal.png"
convert -size 48x48 xc:none -fill red -draw "path 'M24,12 Q12,24 24,36 Q36,24 24,12 Z'" "$USER_HOME/.icons/aol-custom/favorites.png"

# Desktop entries
cat <<EOF > "$USER_HOME/.local/share/applications/aol-mail.desktop"
[Desktop Entry]
Name=Mail
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

cat <<EOF > "$USER_HOME/.local/share/applications/aol-news.desktop"
[Desktop Entry]
Name=News
Exec=firefox "https://web.archive.org/web/20010405070456/http://www.cnn.com/"
Icon=$USER_HOME/.icons/aol-custom/news.png
Type=Application
EOF

cat <<EOF > "$USER_HOME/.local/share/applications/aol-finance.desktop"
[Desktop Entry]
Name=Finance
Exec=firefox https://finance.yahoo.com
Icon=$USER_HOME/.icons/aol-custom/finance.png
Type=Application
EOF

cat <<EOF > "$USER_HOME/.local/share/applications/aol-terminal.desktop"
[Desktop Entry]
Name=Terminal
Exec=xfce4-terminal
Icon=$USER_HOME/.icons/aol-custom/terminal.png
Type=Application
EOF

cat <<EOF > "$USER_HOME/.local/share/applications/aol-browser.desktop"
[Desktop Entry]
Name=Internet
Exec=firefox -P AOL --no-remote
Icon=firefox
Type=Application
EOF

# Tint2 – now with menu button on the left
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
taskbar_mode = multi_desktop
taskbar_padding = 4 2 4
task_icon = 1
task_text = 0

# Big launcher buttons (including new ones)
launcher_padding = 10 0 15
launcher_icon_size = 64
launcher_item_app = $USER_HOME/.local/share/applications/aol-mail.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-people.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-news.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-finance.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-terminal.desktop
launcher_item_app = $USER_HOME/.local/share/applications/aol-browser.desktop

time1_format = %l:%M %p
time1_font = MS Sans Serif Bold 10
clock_padding = 8 2

systray_padding = 8 2 8
systray_icon_size = 24

execp = new
execp_command = echo "Keyword or Web Address"
execp_font = MS Sans Serif 11
execp_padding = 10 4
execp_background_id = 2
execp_lclick_command = firefox -P AOL --no-remote
EOF

# Blue background (AOL classic blue)
cat <<EOF > "$USER_HOME/.config/openbox/autostart"
# AOL blue background
convert -size 1920x1080 gradient:#003366-#0055d4 -gravity center -pointsize 72 -fill white -annotate +0+0 'AOL' "$USER_HOME/.cache/aol-bg.png" || true
feh --bg-fill "$USER_HOME/.cache/aol-bg.png" || xsetroot -solid "#0055d4"
tint2 &
volumeicon &
(sleep 2 && "$USER_HOME/.local/bin/aol-welcome") &
EOF

# Welcome screen (aplay version)
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
tk.Label(right, text="Classic online experience loaded.", bg="white", font=("Arial", 10)).pack(anchor="w", padx=20)
root.mainloop()
EOF
chmod +x "$USER_HOME/.local/bin/aol-welcome"

# Session
sudo tee /usr/share/xsessions/aol7.desktop > /dev/null <<EOF
[Desktop Entry]
Name=AOL 7.0 Desktop (Blue)
Comment=You've Got Mail!
Exec=$USER_HOME/.local/bin/start_aol.sh
TryExec=$USER_HOME/.local/bin/start_aol.sh
Type=Application
EOF

cat <<EOF > "$USER_HOME/.local/bin/start_aol.sh"
#!/bin/bash
export GTK2_RC_FILES="$USER_HOME/.gtkrc-2.0"
exec openbox-session
EOF
chmod +x "$USER_HOME/.local/bin/start_aol.sh"

echo "==========================================================="
echo "Done. Log out and select 'AOL 7.0 Desktop (Blue)'"
echo "You now have a blue background and News/Finance/Terminal buttons."
echo "==========================================================="
