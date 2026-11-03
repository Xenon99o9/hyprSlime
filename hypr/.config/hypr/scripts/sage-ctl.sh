#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  HYPRSLIME — Great Sage System Backend & Telemetry Controller (sage-ctl.sh)
#  Provides fast JSON telemetry and executes actions for the Quickshell HUD
# ══════════════════════════════════════════════════════════════════════════════

set -u

# Ensure HYPRLAND_INSTANCE_SIGNATURE is set so hyprctl reload/dispatch always works
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" && -d "/run/user/$(id -u)/hypr" ]]; then
    sig=$(ls -t "/run/user/$(id -u)/hypr" 2>/dev/null | head -n 1 || true)
    [[ -n "$sig" ]] && export HYPRLAND_INSTANCE_SIGNATURE="$sig"
fi

CONF_DIR="$HOME/.config/hypr/conf"
COLORS_CONF="$CONF_DIR/colors.conf"
COLORS_LUA="$CONF_DIR/colors.lua"
ANIM_CONF="$CONF_DIR/animations.conf"
ANIM_LUA="$CONF_DIR/animations.lua"
INPUT_CONF="$CONF_DIR/input.conf"
INPUT_LUA="$CONF_DIR/input.lua"
STATE_FILE="$HOME/.cache/hyprslime-state.json"
WALL_CACHE="$HOME/.cache/hyprslime-wallpaper"
POWER_CACHE="$HOME/.cache/hyprslime-power"
THEME_CACHE="$HOME/.cache/hyprslime-theme"
DEFAULT_WALL="$HOME/.config/hypr/wallpapers/great-sage-void.png"

json_escape() {
    local s="${1:-}"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/ }"
    s="${s//$'\r'/}"
    printf '%s' "$s"
}

get_status_json() {
    # 1. CPU Usage
    local cpu_usage=0
    if [[ -r /proc/loadavg ]]; then
        local load ncpu
        read -r load _ < /proc/loadavg
        ncpu=$(nproc 2>/dev/null || echo 4)
        cpu_usage=$(awk -v l="$load" -v n="$ncpu" 'BEGIN { v = int((l / n) * 100); if (v > 100) v = 100; print v }')
    fi

    # 2. RAM Usage
    local ram_usage=0
    local ram_text=""
    if [[ -r /proc/meminfo ]]; then
        read -r ram_usage ram_text < <(awk '
            /^MemTotal:/ { total=$2 }
            /^MemAvailable:/ { avail=$2 }
            END {
                used = total - avail
                pct = (total > 0) ? int((used / total) * 100) : 0
                printf "%d %.1fG/%.0fG\n", pct, used/1048576, total/1048576
            }
        ' /proc/meminfo)
    fi

    # 3. Battery
    local bat_pct=100
    local bat_status="AC"
    for bat in /sys/class/power_supply/BAT*; do
        if [[ -d "$bat" ]]; then
            [[ -r "$bat/capacity" ]] && bat_pct=$(cat "$bat/capacity")
            [[ -r "$bat/status" ]] && bat_status=$(cat "$bat/status")
            break
        fi
    done

    # 4. Volume (wpctl)
    local vol_pct=50
    local vol_muted="false"
    if command -v wpctl >/dev/null 2>&1; then
        local wp_out
        wp_out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo "Volume: 0.50")
        vol_pct=$(awk '{ for(i=1;i<=NF;i++) if($i ~ /^[0-9.]+$/) print int($i * 100) }' <<< "$wp_out")
        [[ "$wp_out" == *"[MUTED]"* ]] && vol_muted="true"
    fi

    # 5. Brightness (brightnessctl)
    local bright_pct=100
    if command -v brightnessctl >/dev/null 2>&1; then
        local cur max
        cur=$(brightnessctl g 2>/dev/null || echo 100)
        max=$(brightnessctl m 2>/dev/null || echo 100)
        if [[ "$max" -gt 0 ]]; then
            bright_pct=$(( cur * 100 / max ))
        fi
    fi

    # 6. Wi-Fi Status & Active SSID (nmcli)
    local wifi_enabled="false"
    local wifi_ssid="Disconnected"
    if command -v nmcli >/dev/null 2>&1; then
        local radio
        radio=$(nmcli -t -f WIFI g 2>/dev/null || echo "disabled")
        [[ "$radio" == "enabled" ]] && wifi_enabled="true"
        local active_wifi
        active_wifi=$(nmcli -t -f TYPE,NAME connection show --active 2>/dev/null | awk -F: '$1=="802-11-wireless"{print $2; exit}')
        [[ -n "$active_wifi" ]] && wifi_ssid="$active_wifi"
    fi

    # 7. VPN Connections (NetworkManager VPN / WireGuard + Tailscale)
    local vpn_active="false"
    local vpn_name="None"
    local vpn_list_json="[]"
    if command -v nmcli >/dev/null 2>&1; then
        local items=()
        while IFS=: read -r cname ctype cactive; do
            [[ -z "$cname" ]] && continue
            if [[ "$ctype" == "vpn" || "$ctype" == "wireguard" || "$ctype" == "tun" ]]; then
                local is_act="false"
                if [[ "$cactive" == "yes" ]]; then
                    is_act="true"
                    vpn_active="true"
                    vpn_name="$cname"
                fi
                items+=("{\"name\":\"$(json_escape "$cname")\",\"type\":\"$ctype\",\"active\":$is_act}")
            fi
        done < <(nmcli -t -f NAME,TYPE,ACTIVE connection show 2>/dev/null)

        # Also check Tailscale if installed
        if command -v tailscale >/dev/null 2>&1; then
            local ts_status="false"
            if tailscale status >/dev/null 2>&1; then
                ts_status="true"
                vpn_active="true"
                [[ "$vpn_name" == "None" ]] && vpn_name="Tailscale"
            fi
            items+=("{\"name\":\"Tailscale\",\"type\":\"tailscale\",\"active\":$ts_status}")
        fi

        if [[ ${#items[@]} -gt 0 ]]; then
            local IFS=,
            vpn_list_json="[${items[*]}]"
        fi
    fi

    # Fallback check for active wg/tun/proton/tailscale kernel interfaces
    if [[ "$vpn_active" == "false" ]]; then
        for dev in /sys/class/net/wg* /sys/class/net/tun* /sys/class/net/tailscale* /sys/class/net/proton*; do
            if [[ -e "$dev" ]]; then
                vpn_active="true"
                vpn_name="$(basename "$dev")"
                break
            fi
        done
    fi

    # 8. Bluetooth Status
    local bt_enabled="false"
    local bt_device="Off"
    if command -v bluetoothctl >/dev/null 2>&1; then
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            bt_enabled="true"
            bt_device=$(bluetoothctl info 2>/dev/null | awk -F': ' '/Name:/{print $2; exit}')
            [[ -z "$bt_device" ]] && bt_device="On (Idle)"
        fi
    fi

    # 9. Active Theme, Border Flow & Keyboard Layout from config
    local active_theme=""
    if [[ -f "$THEME_CACHE" ]]; then
        active_theme=$(tr -d '[:space:]' < "$THEME_CACHE" 2>/dev/null)
    fi
    if [[ -z "$active_theme" && -f "$COLORS_LUA" ]]; then
        local found_theme
        found_theme=$(awk -F'presets\\.' '/^M\\.active_border/{print $2}' "$COLORS_LUA" | awk -F'.' '{print $1}')
        [[ -n "$found_theme" ]] && active_theme="$found_theme"
    fi
    if [[ -z "$active_theme" && -f "$COLORS_CONF" ]]; then
        local found_theme_conf
        found_theme_conf=$(awk -F'\\$border_' '/^\\$active_border/{print $2}' "$COLORS_CONF" | awk '{print $1}')
        [[ -n "$found_theme_conf" ]] && active_theme="$found_theme_conf"
    fi
    [[ -z "$active_theme" ]] && active_theme="great_sage"

    local border_flow="false"
    if [[ -f "$ANIM_LUA" ]] && grep -q 'leaf = "borderangle".*enabled = true' "$ANIM_LUA"; then
        border_flow="true"
    fi

    local kb_layout="fr"
    if [[ -f "$INPUT_LUA" ]]; then
        kb_layout=$(awk -F'"' '/kb_layout/{split($2, a, ","); gsub(/[[:space:]]/, "", a[1]); print a[1]; exit}' "$INPUT_LUA")
    fi

    # 10. Power Profile
    local power_profile="balanced"
    if [[ -r "$POWER_CACHE" ]]; then
        local cached_p
        cached_p=$(cat "$POWER_CACHE" 2>/dev/null || true)
        [[ -n "$cached_p" ]] && power_profile="$cached_p"
    elif command -v powerprofilesctl >/dev/null 2>&1; then
        local pp_out
        pp_out=$(powerprofilesctl get 2>/dev/null || true)
        [[ -n "$pp_out" ]] && power_profile="$pp_out"
    fi

    # 11. Media Player (playerctl)
    local media_text=""
    if command -v playerctl >/dev/null 2>&1; then
        local status artist title
        status=$(playerctl status 2>/dev/null || echo "")
        if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
            artist=$(playerctl metadata artist 2>/dev/null || echo "")
            title=$(playerctl metadata title 2>/dev/null || echo "")
            if [[ -n "$title" ]]; then
                media_text="${artist:+$artist - }$title"
            fi
        fi
    fi

    # 12. Current Wallpaper
    local current_wall="$DEFAULT_WALL"
    if [[ -r "$WALL_CACHE" ]]; then
        local cached
        cached=$(cat "$WALL_CACHE" 2>/dev/null || true)
        [[ -n "$cached" && -f "$cached" ]] && current_wall="$cached"
    fi

    printf '{"cpu":%d,"ram":%d,"ramText":"%s","bat":%d,"batStatus":"%s","vol":%d,"muted":%s,"bright":%d,"wifiEnabled":%s,"wifiSsid":"%s","vpnActive":%s,"vpnName":"%s","vpns":%s,"btEnabled":%s,"btDevice":"%s","theme":"%s","borderFlow":%s,"kbLayout":"%s","powerProfile":"%s","media":"%s","wallpaper":"%s"}\n' \
        "${cpu_usage:-0}" "${ram_usage:-0}" "$(json_escape "$ram_text")" \
        "${bat_pct:-100}" "$(json_escape "$bat_status")" \
        "${vol_pct:-50}" "$vol_muted" "${bright_pct:-100}" \
        "$wifi_enabled" "$(json_escape "$wifi_ssid")" \
        "$vpn_active" "$(json_escape "$vpn_name")" "$vpn_list_json" \
        "$bt_enabled" "$(json_escape "$bt_device")" \
        "$active_theme" "$border_flow" "$(json_escape "$kb_layout")" \
        "$(json_escape "$power_profile")" "$(json_escape "$media_text")" \
        "$(json_escape "$current_wall")"
}

list_wallpapers_json() {
    local dirs=(
        "$HOME/.config/hypr/wallpapers"
        "$HOME/Pictures/wallpapers"
        "$HOME/Pictures"
        "$HOME/Images/wallpapers"
        "$HOME/Images"
    )
    local items=()
    local seen=()
    for d in "${dirs[@]}"; do
        [[ -d "$d" ]] || continue
        while IFS= read -r -d '' img; do
            local real
            real=$(readlink -f "$img" 2>/dev/null || echo "$img")
            local dup=0
            for s in "${seen[@]:-}"; do
                [[ "$s" == "$real" ]] && { dup=1; break; }
            done
            [[ "$dup" -eq 1 ]] && continue
            seen+=("$real")
            local bname
            bname=$(basename "$img")
            local label="${bname%.*}"
            label="${label//-/ }"
            label="${label//_/ }"
            items+=("{\"name\":\"$(json_escape "$label")\",\"path\":\"$(json_escape "$img")\"}")
        done < <(find "$d" -maxdepth 1 -type f ! -name "rimuru-avatar.png" ! -name "great-sage-lockscreen.png" \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.gif" \) -print0 2>/dev/null | sort -z)
    done

    if [[ ${#items[@]} -gt 0 ]]; then
        local IFS=,
        echo "[${items[*]}]"
    else
        echo "[]"
    fi
}

apply_wallpaper() {
    local wall_path="${1:-$DEFAULT_WALL}"
    local trans="${2:-wave}"
    [[ -f "$wall_path" ]] || return 1
    mkdir -p "$(dirname "$WALL_CACHE")"
    echo "$wall_path" > "${WALL_CACHE}.tmp" && mv "${WALL_CACHE}.tmp" "$WALL_CACHE"

    local rt_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    local wl_sock="$rt_dir/${WAYLAND_DISPLAY:-wayland-1}"
    if [[ ! -S "$wl_sock" ]]; then
        return 0
    fi

    if command -v swww >/dev/null 2>&1; then
        if ! pgrep -x swww-daemon >/dev/null 2>&1 && ! pgrep -x awww-daemon >/dev/null 2>&1; then
            (swww-daemon --format xrgb >/dev/null 2>&1 &)
            sleep 0.2
        fi
        (swww img "$wall_path" --transition-type "$trans" --transition-fps 120 --transition-duration 1.2 >/dev/null 2>&1 &)
    elif command -v awww >/dev/null 2>&1; then
        if ! pgrep -x awww-daemon >/dev/null 2>&1 && ! pgrep -x swww-daemon >/dev/null 2>&1; then
            (awww-daemon --format xrgb >/dev/null 2>&1 &)
            sleep 0.2
        fi
        (awww img "$wall_path" --transition-type "$trans" --transition-fps 120 --transition-duration 1.2 >/dev/null 2>&1 &)
    fi
}

scan_wifi_json() {
    if ! command -v nmcli >/dev/null 2>&1; then
        echo "[]"
        return
    fi
    local items=()
    while IFS=: read -r in_use ssid signal security; do
        [[ -z "$ssid" ]] && continue
        local active="false"
        [[ "$in_use" == "*" ]] && active="true"
        items+=("{\"ssid\":\"$(json_escape "$ssid")\",\"signal\":${signal:-0},\"security\":\"$(json_escape "$security")\",\"active\":$active}")
    done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan auto 2>/dev/null | head -n 12)

    if [[ ${#items[@]} -gt 0 ]]; then
        local IFS=,
        echo "[${items[*]}]"
    else
        echo "[]"
    fi
}

case "${1:-status}" in
    status)
        get_status_json
        ;;
    app-list)
        python3 - << 'EOF'
import glob, json, os, re, subprocess

ICON_DIRS = [
    "/usr/share/icons/hicolor/256x256/apps",
    "/usr/share/icons/hicolor/128x128/apps",
    "/usr/share/icons/hicolor/64x64/apps",
    "/usr/share/icons/hicolor/48x48/apps",
    "/usr/share/icons/hicolor/scalable/apps",
    "/usr/share/pixmaps",
    "/usr/share/icons/Papirus/64x64/apps",
    "/usr/share/icons/Adwaita/scalable/apps",
]

ICON_ALIASES = {
    "discord": ["discord", "vesktop", "com.discordapp.Discord"],
    "vesktop": ["vesktop", "discord"],
    "spotify": ["spotify", "spotify-client", "com.spotify.Client"],
    "brave": ["brave-desktop", "brave", "brave-browser"],
    "brave-browser": ["brave-desktop", "brave"],
    "kitty": ["kitty"],
    "btop": ["btop"],
    "thunar": ["org.xfce.thunar", "thunar", "system-file-manager"],
    "code": ["visual-studio-code", "code", "com.visualstudio.code"],
    "antigravity": ["antigravity", "code", "visual-studio-code"],
    "steam": ["steam"],
    "telegram": ["telegram", "org.telegram.desktop"],
    "vlc": ["vlc"],
    "obs": ["com.obsproject.Studio", "obs"],
}

def resolve_icon(icon_name, app_name, exec_cmd):
    if not icon_name:
        icon_name = app_name.lower()
    icon_name = icon_name.strip()
    if os.path.isabs(icon_name) and os.path.isfile(icon_name):
        return icon_name

    base = os.path.splitext(icon_name)[0]
    cmd_bin = os.path.basename(exec_cmd.split()[0]).lower() if exec_cmd else ""
    candidates = [base, base.lower()]
    for k in (base.lower(), cmd_bin, app_name.lower()):
        if k in ICON_ALIASES:
            candidates.extend(ICON_ALIASES[k])
    if cmd_bin:
        candidates.append(cmd_bin)

    for c in candidates:
        if not c:
            continue
        for d in ICON_DIRS:
            for ext in (".png", ".svg", ".xpm"):
                p = os.path.join(d, c + ext)
                if os.path.isfile(p):
                    return p
    return ""

usage_path = os.path.expanduser("~/.cache/hyprslime-app-usage.json")
try:
    with open(usage_path, "r", encoding="utf-8") as f:
        usage_map = json.load(f)
except Exception:
    usage_map = {}

# Default priority scores for popular daily-driver apps so the list is immediately smart
DEFAULT_PRIORITY = {
    "brave": 30,
    "firefox": 28,
    "discord": 27,
    "vesktop": 27,
    "spotify": 26,
    "kitty": 25,
    "antigravity": 24,
    "code": 23,
    "thunar": 22,
    "steam": 20,
    "btop": 18,
    "pavucontrol": 16,
    "obs": 15,
    "vlc": 14,
    "nwg-displays": 12,
}

# Boost currently open/running apps
running_bins = set()
try:
    out = subprocess.check_output(["hyprctl", "clients", "-j"], text=True, stderr=subprocess.DEVNULL)
    for c in json.loads(out):
        cls = (c.get("class") or c.get("initialClass") or "").lower().strip()
        if cls:
            running_bins.add(cls)
except Exception:
    pass

apps = []
seen = set()
dirs = ["/usr/share/applications", os.path.expanduser("~/.local/share/applications")]
for d in dirs:
    for path in sorted(glob.glob(os.path.join(d, "*.desktop"))):
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                raw_content = f.read()
            content = raw_content.split("\n[Desktop Action")[0]
            if "NoDisplay=true" in content or "Hidden=true" in content:
                continue
            name_m = re.search(r"^Name=(.+)$", content, re.M)
            exec_m = re.search(r"^Exec=(.+)$", content, re.M)
            desc_m = re.search(r"^Comment=(.+)$", content, re.M)
            icon_m = re.search(r"^Icon=(.+)$", content, re.M)
            if not name_m or not exec_m:
                continue
            name = name_m.group(1).strip()
            if name.lower() in seen:
                continue
            seen.add(name.lower())
            cmd = re.sub(r"\s+%[fFuUdDnNickvm]", "", exec_m.group(1).strip())
            cmd = re.sub(r"\s+--url\s*--\s*$", "", cmd).strip()
            desc = desc_m.group(1).strip() if desc_m else "Application"
            raw_icon = icon_m.group(1).strip() if icon_m else ""
            icon_path = resolve_icon(raw_icon, name, cmd)

            cmd_bin = os.path.basename(cmd.split()[0]).lower() if cmd else ""
            user_launches = int(usage_map.get(name.lower(), 0)) + int(usage_map.get(cmd_bin, 0))
            base_score = 0
            for k, v in DEFAULT_PRIORITY.items():
                if k in name.lower() or k == cmd_bin:
                    base_score = max(base_score, v)
            if any(rb in name.lower() or rb == cmd_bin for rb in running_bins):
                base_score += 15
            total_score = user_launches * 25 + base_score

            apps.append({
                "name": name,
                "exec": cmd,
                "desc": desc,
                "icon": icon_path,
                "score": total_score,
                "frequent": total_score >= 20
            })
        except Exception:
            pass

apps.sort(key=lambda x: (-x["score"], x["name"].lower()))
print(json.dumps(apps[:120]))
EOF
        ;;
    app-launch)
        exec_cmd="${2:-}"
        app_name="${3:-}"
        python3 - "$exec_cmd" "$app_name" << 'EOF'
import json, os, subprocess, sys

exec_cmd, app_name = sys.argv[1], sys.argv[2]
usage_path = os.path.expanduser("~/.cache/hyprslime-app-usage.json")
try:
    with open(usage_path, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {}

key = (app_name or os.path.basename(exec_cmd.split()[0] if exec_cmd else "")).lower().strip()
if key:
    data[key] = int(data.get(key, 0)) + 1
    os.makedirs(os.path.dirname(usage_path), exist_ok=True)
    with open(usage_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

if exec_cmd:
    subprocess.Popen(["bash", "-c", f"nohup {exec_cmd} >/dev/null 2>&1 &"], start_new_session=True)
EOF
        ;;
    wallpaper-list)
        list_wallpapers_json
        ;;
    set-wallpaper)
        apply_wallpaper "${2:-$DEFAULT_WALL}" "${3:-wave}"
        ;;
    wifi-list)
        scan_wifi_json
        ;;
    wifi-toggle)
        if [[ "$(nmcli -t -f WIFI g)" == "enabled" ]]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    wifi-connect)
        ssid="${2:-}"
        if [[ -n "$ssid" ]]; then
            nmcli device wifi connect "$ssid" >/dev/null 2>&1 || nm-connection-editor &
        fi
        ;;
    vpn-toggle)
        name="${2:-}"
        type="${3:-vpn}"
        if [[ "$type" == "tailscale" ]]; then
            if tailscale status >/dev/null 2>&1; then
                pkexec tailscale down || tailscale down
            else
                pkexec tailscale up || tailscale up
            fi
        elif [[ -n "$name" ]]; then
            if nmcli -t -f NAME connection show --active | grep -Fxq "$name"; then
                nmcli connection down "$name"
            else
                nmcli connection up "$name"
            fi
        fi
        ;;
    bt-toggle)
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            bluetoothctl power off
        else
            rfkill unblock bluetooth 2>/dev/null || true
            bluetoothctl power on
        fi
        ;;
    set-volume|vol-set)
        val="${2:-50}"
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "${val}%"
        ;;
    toggle-mute|vol-mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    set-brightness|bright-set)
        val="${2:-100}"
        [[ "$val" -lt 5 ]] && val=5
        brightnessctl s "${val}%"
        ;;
    osd-vol)
        action="${2:-up}"
        case "$action" in
            up)   wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 >/dev/null 2>&1 || true
                  wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ >/dev/null 2>&1 || true ;;
            down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- >/dev/null 2>&1 || true ;;
            mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1 || true ;;
            mic)  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle >/dev/null 2>&1 || true ;;
        esac
        if [[ "$action" == "mic" ]]; then
            wp_out=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || echo "Volume: 1.00")
            vol_pct=$(awk '{ for(i=1;i<=NF;i++) if($i ~ /^[0-9.]+$/) print int($i * 100) }' <<< "$wp_out")
            vol_muted="false"
            [[ "$wp_out" == *"[MUTED]"* ]] && vol_muted="true"
            printf '{"mode":"mic","value":%d,"muted":%s}\n' "${vol_pct:-100}" "$vol_muted"
        else
            wp_out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo "Volume: 0.50")
            vol_pct=$(awk '{ for(i=1;i<=NF;i++) if($i ~ /^[0-9.]+$/) print int($i * 100) }' <<< "$wp_out")
            vol_muted="false"
            [[ "$wp_out" == *"[MUTED]"* ]] && vol_muted="true"
            printf '{"mode":"volume","value":%d,"muted":%s}\n' "${vol_pct:-50}" "$vol_muted"
        fi
        ;;
    osd-bright)
        action="${2:-up}"
        if command -v brightnessctl >/dev/null 2>&1; then
            if [[ "$action" == "up" ]]; then
                brightnessctl s 5%+ >/dev/null 2>&1 || true
            else
                cur=$(brightnessctl g 2>/dev/null || echo 100)
                max=$(brightnessctl m 2>/dev/null || echo 100)
                pct=$(( max > 0 ? cur * 100 / max : 100 ))
                if [[ "$pct" -le 10 ]]; then
                    brightnessctl s 5% >/dev/null 2>&1 || true
                else
                    brightnessctl s 5%- >/dev/null 2>&1 || true
                fi
            fi
            cur=$(brightnessctl g 2>/dev/null || echo 100)
            max=$(brightnessctl m 2>/dev/null || echo 100)
            bright_pct=$(( max > 0 ? cur * 100 / max : 100 ))
        else
            bright_pct=100
        fi
        printf '{"mode":"brightness","value":%d,"muted":false}\n' "${bright_pct:-100}"
        ;;
    set-theme)
        theme="${2:-great_sage}"
        custom_wall="${3:-}"
        mkdir -p "$(dirname "$THEME_CACHE")"
        echo "$theme" > "${THEME_CACHE}.tmp" && mv "${THEME_CACHE}.tmp" "$THEME_CACHE"
        wall=""
        case "$theme" in
            magicule)
                wall="$HOME/.config/hypr/wallpapers/rimuru-magicule.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_magicule/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_magicule/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.magicule.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.magicule.glow/' "$COLORS_LUA"
                }
                ;;
            beelzebub)
                wall="$HOME/.config/hypr/wallpapers/beelzebub-abyss.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_beelzebub/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_beelzebub/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.beelzebub.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.beelzebub.glow/' "$COLORS_LUA"
                }
                ;;
            hellflare)
                wall="$HOME/.config/hypr/wallpapers/crimson-hellflare.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_hellflare/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_hellflare/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.hellflare.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.hellflare.glow/' "$COLORS_LUA"
                }
                ;;
            diablo)
                wall="$HOME/.config/hypr/wallpapers/diablo-primordial.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_diablo/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_diablo/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.diablo.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.diablo.glow/' "$COLORS_LUA"
                }
                ;;
            testarossa)
                wall="$HOME/.config/hypr/wallpapers/testarossa-primordial.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_testarossa/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_testarossa/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.testarossa.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.testarossa.glow/' "$COLORS_LUA"
                }
                ;;
            carrera)
                wall="$HOME/.config/hypr/wallpapers/carrera-primordial.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_carrera/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_carrera/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.carrera.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.carrera.glow/' "$COLORS_LUA"
                }
                ;;
            ultima)
                wall="$HOME/.config/hypr/wallpapers/ultima-primordial.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_ultima/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_ultima/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.ultima.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.ultima.glow/' "$COLORS_LUA"
                }
                ;;
            mustang)
                wall="$HOME/.config/hypr/wallpapers/mustang-primordial.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_mustang/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_mustang/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.mustang.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.mustang.glow/' "$COLORS_LUA"
                }
                ;;
            great_sage|*)
                wall="$HOME/.config/hypr/wallpapers/rimuru-great-sage.png"
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_great_sage/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_great_sage/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.great_sage.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.great_sage.glow/' "$COLORS_LUA"
                }
                ;;
        esac
        target_wall=""
        if [[ -n "$custom_wall" && -f "$custom_wall" ]]; then
            target_wall="$custom_wall"
        elif [[ -n "$wall" && -f "$wall" ]]; then
            target_wall="$wall"
        fi
        if [[ -n "$target_wall" ]]; then
            apply_wallpaper "$target_wall" "wave"
        fi
        hyprctl reload >/dev/null 2>&1 || true
        ;;
    set-flow)
        mode="${2:-false}"
        if [[ "$mode" == "true" || "$mode" == "on" || "$mode" == "1" ]]; then
            [[ -f "$ANIM_CONF" ]] && sed -i 's/animation = borderangle.*/animation = borderangle, 1, 45, magiculeFlow, loop/' "$ANIM_CONF"
            [[ -f "$ANIM_LUA" ]] && sed -i 's/leaf = "borderangle",.*enabled = [a-z]*/leaf = "borderangle",      enabled = true/' "$ANIM_LUA"
        else
            [[ -f "$ANIM_CONF" ]] && sed -i 's/animation = borderangle.*/animation = borderangle, 0, 45, magiculeFlow, loop/' "$ANIM_CONF"
            [[ -f "$ANIM_LUA" ]] && sed -i 's/leaf = "borderangle",.*enabled = [a-z]*/leaf = "borderangle",      enabled = false/' "$ANIM_LUA"
        fi
        hyprctl reload >/dev/null 2>&1 || true
        ;;
    set-kb)
        kb="${2:-fr}"
        kb="${kb%%,*}"
        if [[ "$kb" == "us" ]]; then
            kb_pair="us,fr"
        elif [[ "$kb" == "fr" ]]; then
            kb_pair="fr,us"
        else
            kb_pair="${kb},fr,us"
        fi
        [[ -f "$INPUT_CONF" ]] && sed -i "s/^[[:space:]]*kb_layout = .*/    kb_layout = $kb_pair/" "$INPUT_CONF"
        [[ -f "$INPUT_LUA" ]] && sed -i "s/^[[:space:]]*kb_layout[[:space:]]*= .*/        kb_layout  = \"$kb_pair\",/" "$INPUT_LUA"
        hyprctl eval "hl.config({ input = { kb_layout = '$kb_pair', kb_options = 'grp:alt_shift_toggle' } })" >/dev/null 2>&1 || true
        hyprctl reload >/dev/null 2>&1 || true
        ;;
    monitor-list)
        python3 - << 'EOF'
import json, math, subprocess

try:
    out = subprocess.check_output(["hyprctl", "monitors", "all", "-j"], text=True, stderr=subprocess.DEVNULL)
    raw = json.loads(out)
except Exception:
    raw = []

res = []
for m in raw:
    pw = int(m.get("physicalWidth", 0) or 0)
    ph = int(m.get("physicalHeight", 0) or 0)
    inches = round(math.hypot(pw, ph) / 25.4, 1) if (pw > 0 and ph > 0) else 0.0
    modes = m.get("availableModes", []) or []
    w = int(m.get("width", 1920) or 1920)
    h = int(m.get("height", 1080) or 1080)
    rr = round(float(m.get("refreshRate", 60.0) or 60.0), 2)
    cur_mode = f"{w}x{h}@{rr:.2f}Hz"
    if not modes:
        modes = [cur_mode]
    res.append({
        "id": m.get("id", 0),
        "name": m.get("name", "eDP-1"),
        "desc": m.get("description", "") or m.get("model", "Display"),
        "make": m.get("make", ""),
        "model": m.get("model", ""),
        "width": w,
        "height": h,
        "refreshRate": rr,
        "currentMode": f"{w}x{h}@{rr:.0f}",
        "physW": pw,
        "physH": ph,
        "inches": inches,
        "x": int(m.get("x", 0) or 0),
        "y": int(m.get("y", 0) or 0),
        "scale": round(float(m.get("scale", 1.0) or 1.0), 2),
        "transform": int(m.get("transform", 0) or 0),
        "disabled": bool(m.get("disabled", False)),
        "mirrorOf": m.get("mirrorOf", "none") or "none",
        "focused": bool(m.get("focused", False)),
        "activeWsId": int(m.get("activeWorkspace", {}).get("id", 1) or 1),
        "modes": modes[:16]
    })

print(json.dumps(res))
EOF
        ;;
    monitor-apply)
        payload="${2:-[]}"
        python3 - "$payload" "$CONF_DIR/monitors.lua" "$CONF_DIR/monitors.conf" << 'EOF'
import json, re, subprocess, sys

payload_str, lua_path, conf_path = sys.argv[1], sys.argv[2], sys.argv[3]
monitors = json.loads(payload_str)

lua_lines = [
    "-- ══════════════════════════════════════════════════════════════════════════════",
    "--  HYPRSLIME — Display Configuration (conf/monitors.lua)",
    "--  Generated by Great Sage Graphical Display Manager",
    "-- ══════════════════════════════════════════════════════════════════════════════",
    "",
    "-- Universal fallback rule FIRST so specific monitor rules below take precedence",
    "hl.monitor({",
    '    output   = "",',
    '    mode     = "preferred",',
    '    position = "auto",',
    "    scale    = 1.0,",
    "})",
    ""
]

conf_lines = [
    "# ══════════════════════════════════════════════════════════════════════════════",
    "#  HYPRSLIME — Display Configuration (monitors.conf)",
    "#  Generated by Great Sage Graphical Display Manager",
    "# ══════════════════════════════════════════════════════════════════════════════",
    "",
    "# Universal fallback rule FIRST",
    "monitor = , preferred, auto, 1",
    ""
]

def mode_width(mode_str):
    mt = re.match(r"^(\d+)x(\d+)", str(mode_str))
    return int(mt.group(1)) if mt else 1920

eval_calls = []
kw_calls = []
occupied_origins = set()
next_auto_x = 0

for idx, m in enumerate(monitors):
    name = m.get("name", "")
    if not name:
        continue
    disabled = bool(m.get("disabled", False))
    if disabled:
        stmt = f'hl.monitor({{ output = "{name}", disabled = true }})'
        lua_lines.append(stmt)
        conf_lines.append(f"monitor = {name}, disable")
        eval_calls.append(stmt)
        kw_calls.append(f"{name}, disable")
        continue

    mode_raw = str(m.get("mode", "preferred")).replace("Hz", "")
    x = int(m.get("x", 0) or 0)
    y = int(m.get("y", 0) or 0)
    scale = float(m.get("scale", 1.0) or 1.0)
    transform = int(m.get("transform", 0) or 0)
    mirror = str(m.get("mirrorOf", "none") or "none")

    eff_w = int(round(mode_width(mode_raw) / max(0.5, scale)))
    if (not mirror or mirror == "none" or mirror == name):
        if (x, y) in occupied_origins:
            x = next_auto_x
            y = 0
        occupied_origins.add((x, y))
        next_auto_x = max(next_auto_x, x + eff_w)

    lua_block = [
        "hl.monitor({",
        f'    output    = "{name}",',
        f'    mode      = "{mode_raw}",',
        f'    position  = "{x}x{y}",',
        f'    scale     = {scale},',
        f'    transform = {transform},'
    ]
    if mirror and mirror != "none" and mirror != name:
        lua_block.append(f'    mirror    = "{mirror}",')
    lua_block.append("})")
    stmt = "\n".join(lua_block)
    lua_lines.append(stmt)
    eval_calls.append(stmt.replace("\n", " "))

    conf_str = f"{name}, {mode_raw}, {x}x{y}, {scale}"
    if transform > 0:
        conf_str += f", transform, {transform}"
    if mirror and mirror != "none" and mirror != name:
        conf_str += f", mirror, {mirror}"
    conf_lines.append("monitor = " + conf_str)
    kw_calls.append(conf_str)

with open(lua_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lua_lines) + "\n")

with open(conf_path, "w", encoding="utf-8") as f:
    f.write("\n".join(conf_lines) + "\n")

for stmt in eval_calls:
    subprocess.run(["hyprctl", "eval", stmt], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
for kw in kw_calls:
    subprocess.run(["hyprctl", "keyword", "monitor", kw], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
subprocess.run(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
EOF
        if [[ -r "$WALL_CACHE" ]]; then
            cached_w=$(cat "$WALL_CACHE" 2>/dev/null || true)
            [[ -n "$cached_w" && -f "$cached_w" ]] && swww img "$cached_w" --transition-type none >/dev/null 2>&1 &
        fi
        ;;
    monitor-preset)
        preset="${2:-auto}"
        python3 - "$preset" "$CONF_DIR/monitors.lua" "$CONF_DIR/monitors.conf" << 'EOF'
import json, re, subprocess, sys

preset, lua_path, conf_path = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    out = subprocess.check_output(["hyprctl", "monitors", "all", "-j"], text=True, stderr=subprocess.DEVNULL)
    raw = json.loads(out)
except Exception:
    raw = []

def best_mode(m):
    modes = m.get("availableModes", []) or []
    if modes:
        return modes[0].replace("Hz", "")
    w = int(m.get("width", 1920) or 1920)
    h = int(m.get("height", 1080) or 1080)
    rr = float(m.get("refreshRate", 60.0) or 60.0)
    return f"{w}x{h}@{rr:.2f}"

def parse_wh(mode_str, m):
    mt = re.match(r"^(\d+)x(\d+)", mode_str)
    if mt:
        return int(mt.group(1)), int(mt.group(2))
    return int(m.get("width", 1920) or 1920), int(m.get("height", 1080) or 1080)

payload = []
if raw:
    primary = raw[0]
    p_name = primary.get("name", "eDP-1")
    p_mode = best_mode(primary)
    p_w, p_h = parse_wh(p_mode, primary)
    p_scale = float(primary.get("scale", 1.0) or 1.0)
    p_eff_w = int(round(p_w / p_scale))
    p_eff_h = int(round(p_h / p_scale))
    cur_x = p_eff_w

    for idx, m in enumerate(raw):
        name = m.get("name", "")
        mode = best_mode(m)
        w, h = parse_wh(mode, m)
        scale = float(m.get("scale", 1.0) or 1.0)
        eff_w = int(round(w / scale))
        eff_h = int(round(h / scale))

        if idx == 0:
            disabled = (preset == "external-only" and len(raw) > 1)
            x, y = 0, 0
            mirror = "none"
        else:
            disabled = (preset == "laptop-only")
            mirror = "none"
            if preset == "mirror":
                x, y = 0, 0
                mirror = p_name
            elif preset == "extend-left":
                x, y = -eff_w, 0
            elif preset == "extend-above":
                x, y = 0, -eff_h
            elif preset == "extend-below":
                x, y = 0, p_eff_h
            else:
                x, y = cur_x, 0
                cur_x += eff_w

        payload.append({
            "name": name,
            "mode": mode,
            "x": x,
            "y": y,
            "scale": scale,
            "transform": 0,
            "disabled": disabled,
            "mirrorOf": mirror
        })

subprocess.run(["/home/xenon99o9/.config/hypr/scripts/sage-ctl.sh", "monitor-apply", json.dumps(payload)])
EOF
        ;;
    workspace-map-get)
        python3 - << 'EOF'
import json, os, re, subprocess

ws_conf = os.path.expanduser("~/.config/hypr/workspaces.conf")
mapping = {}

if os.path.isfile(ws_conf):
    try:
        with open(ws_conf, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("workspace"):
                    m = re.match(r"^workspace\s*=\s*(\d+)\s*,\s*monitor:([^\s,]+)", line)
                    if m:
                        mapping[m.group(1)] = m.group(2)
    except Exception:
        pass

try:
    raw_m = json.loads(subprocess.check_output(["hyprctl", "monitors", "all", "-j"], text=True, stderr=subprocess.DEVNULL))
    mon_names = [m.get("name") for m in raw_m if m.get("name") and not m.get("disabled")]
except Exception:
    mon_names = []
if not mon_names:
    mon_names = ["eDP-1"]

num_m = len(mon_names)
for ws in range(1, 11):
    ws_str = str(ws)
    if ws_str not in mapping or mapping[ws_str] not in mon_names:
        if num_m == 1:
            mapping[ws_str] = mon_names[0]
        elif num_m == 2:
            mapping[ws_str] = mon_names[0] if ws <= 5 else mon_names[1]
        else:
            idx = min(num_m - 1, (ws - 1) * num_m // 10)
            mapping[ws_str] = mon_names[idx]

print(json.dumps(mapping))
EOF
        ;;
    workspace-map-apply)
        payload="${2:-{}}"
        python3 - "$payload" << 'EOF'
import json, os, subprocess, sys

payload_str = sys.argv[1] if len(sys.argv) > 1 else "{}"
try:
    mapping = json.loads(payload_str)
except Exception:
    mapping = {}

conf_dir = os.path.expanduser("~/.config/hypr")
ws_conf = os.path.join(conf_dir, "workspaces.conf")
ws_lua = os.path.join(conf_dir, "workspaces.lua")
ws_conf_alt = os.path.join(conf_dir, "conf", "workspaces.conf")
ws_lua_alt = os.path.join(conf_dir, "conf", "workspaces.lua")

conf_lines = [
    "# ══════════════════════════════════════════════════════════════════════════════",
    "#  HYPRSLIME — Workspace to Monitor Mapping (workspaces.conf)",
    "# ══════════════════════════════════════════════════════════════════════════════",
    ""
]

lua_lines = [
    "-- ══════════════════════════════════════════════════════════════════════════════",
    "--  HYPRSLIME — Workspace to Monitor Mapping (workspaces.lua)",
    "-- ══════════════════════════════════════════════════════════════════════════════",
    ""
]

seen_mon_default = set()
for ws in range(1, 11):
    ws_str = str(ws)
    mon = mapping.get(ws_str, "eDP-1")
    is_def = False
    if mon not in seen_mon_default:
        is_def = True
        seen_mon_default.add(mon)
    
    def_str = ", default:true" if is_def else ""
    conf_lines.append(f"workspace = {ws}, monitor:{mon}{def_str}")
    
    lua_lines.append("hl.workspace_rule({")
    lua_lines.append(f'    workspace = "{ws}",')
    lua_lines.append(f'    monitor = "{mon}"' + (",\n    default = true" if is_def else ""))
    lua_lines.append("})")
    
    subprocess.run(["hyprctl", "keyword", "workspace", f"{ws},monitor:{mon}{def_str}"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

for path in [ws_conf, ws_conf_alt]:
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write("\n".join(conf_lines) + "\n")
    except Exception:
        pass

for path in [ws_lua, ws_lua_alt]:
    try:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write("\n".join(lua_lines) + "\n")
    except Exception:
        pass

subprocess.run(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print(json.dumps({"status": "ok", "applied": len(mapping)}))
EOF
        ;;
    kb-get)
        python3 - << 'EOF'
import json, os, re

kb_cache = os.path.expanduser("~/.config/hypr/conf/keyboards.json")
input_conf = os.path.expanduser("~/.config/hypr/conf/input.conf")

data = None
if os.path.isfile(kb_cache):
    try:
        with open(kb_cache, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        pass

if not data or not isinstance(data.get("active"), list) or len(data.get("active")) == 0:
    base_kb = "fr"
    if os.path.isfile(input_conf):
        try:
            with open(input_conf, "r", encoding="utf-8") as f:
                for line in f:
                    m = re.match(r"^\s*kb_layout\s*=\s*([^,\s]+)", line)
                    if m:
                        base_kb = m.group(1).strip()
                        break
        except Exception:
            pass
    data = {"current": base_kb, "active": [base_kb]}

print(json.dumps(data))
EOF
        ;;
    kb-set)
        curr="${2:-fr}"
        active_json="${3:-[]}"
        python3 - "$curr" "$active_json" << 'EOF'
import json, os, subprocess, sys

curr = sys.argv[1]
try:
    active_list = json.loads(sys.argv[2])
except Exception:
    active_list = [curr]

if not active_list:
    active_list = [curr]
if curr not in active_list:
    active_list.insert(0, curr)

# Build comma separated layout starting with curr
ordered = [curr] + [k for k in active_list if k != curr]
csv_layout = ",".join(ordered)

conf_dir = os.path.expanduser("~/.config/hypr/conf")
os.makedirs(conf_dir, exist_ok=True)

kb_cache = os.path.join(conf_dir, "keyboards.json")
with open(kb_cache, "w", encoding="utf-8") as f:
    json.dump({"current": curr, "active": active_list}, f, indent=2)

input_conf = os.path.join(conf_dir, "input.conf")
input_lua = os.path.join(conf_dir, "input.lua")

if os.path.isfile(input_conf):
    subprocess.run(["sed", "-i", f"s/^[[:space:]]*kb_layout = .*/    kb_layout = {csv_layout}/", input_conf])
if os.path.isfile(input_lua):
    subprocess.run(["sed", "-i", f's/^[[:space:]]*kb_layout[[:space:]]*= .*/        kb_layout  = "{csv_layout}",/', input_lua])

subprocess.run(["hyprctl", "keyword", "input:kb_layout", csv_layout], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
subprocess.run(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print(json.dumps({"current": curr, "active": active_list, "csv": csv_layout}))
EOF
        ;;
    running-apps)
        python3 - << 'EOF'
import glob, json, os, subprocess

ICON_DIRS = [
    "/usr/share/icons/hicolor/256x256/apps",
    "/usr/share/icons/hicolor/128x128/apps",
    "/usr/share/icons/hicolor/64x64/apps",
    "/usr/share/icons/hicolor/48x48/apps",
    "/usr/share/icons/hicolor/scalable/apps",
    "/usr/share/pixmaps",
]

ICON_ALIASES = {
    "discord": ["discord", "vesktop", "com.discordapp.Discord"],
    "vesktop": ["vesktop", "discord"],
    "spotify": ["spotify", "spotify-client", "com.spotify.Client"],
    "brave": ["brave-desktop", "brave", "brave-browser"],
    "brave-browser": ["brave-desktop", "brave"],
    "kitty": ["kitty"],
    "sysmon-btop": ["btop", "utilities-system-monitor"],
    "btop": ["btop"],
    "thunar": ["org.xfce.thunar", "thunar", "system-file-manager"],
    "code": ["visual-studio-code", "code", "com.visualstudio.code"],
    "antigravity-ide": ["code", "visual-studio-code", "applications-development"],
    "steam": ["steam"],
    "telegram": ["telegram", "org.telegram.desktop"],
    "org.telegram.desktop": ["telegram", "org.telegram.desktop"],
    "vlc": ["vlc"],
    "obs": ["com.obsproject.Studio", "obs"],
}

def find_icon(app_key):
    key = app_key.lower().strip()
    candidates = ICON_ALIASES.get(key, [key, key.split(".")[-1], key.split("-")[0]])
    for c in candidates:
        for d in ICON_DIRS:
            for ext in (".png", ".svg"):
                p = os.path.join(d, c + ext)
                if os.path.isfile(p):
                    return p
    # Fallback search in hicolor/pixmaps
    short = key.split(".")[-1].split("-")[0]
    if len(short) >= 3:
        for d in ICON_DIRS:
            matches = glob.glob(os.path.join(d, f"*{short}*"))
            for m in matches:
                if m.endswith((".png", ".svg")):
                    return m
    return ""

try:
    out = subprocess.check_output(["hyprctl", "clients", "-j"], text=True, stderr=subprocess.DEVNULL)
    clients = json.loads(out)
except Exception:
    clients = []

apps = []
seen = set()

# Known background/tray resident apps that stay alive when closed
BG_DAEMONS = [
    ("discord", "Discord", "chat"),
    ("vesktop", "Vesktop", "chat"),
    ("spotify", "Spotify", "music"),
    ("steam", "Steam", ""),
    ("telegram-desktop", "Telegram", ""),
    ("qbittorrent", "qBittorrent", ""),
    ("obs", "OBS Studio", ""),
    ("slack", "Slack", ""),
    ("signal-desktop", "Signal", ""),
    ("element-desktop", "Element", ""),
    ("easyeffects", "EasyEffects", ""),
    ("keepassxc", "KeePassXC", ""),
    ("nextcloud", "Nextcloud", ""),
    ("flameshot", "Flameshot", ""),
]
BG_KEYS = {k[0] for k in BG_DAEMONS}

# Map normal workspaces (1..10) to a Tensura/Slime emblem category based on open windows
def classify_app_emblem(key, title):
    combined = f"{key} {title.lower()}"
    if any(w in combined for w in ("antigravity", "code", "vscodium", "nvim", "neovim", "jetbrains", "zed", "cursor", "idea")):
        return "code"
    if any(w in combined for w in ("brave", "firefox", "chromium", "chrome", "zen", "librewolf", "vivaldi")):
        return "browser"
    if any(w in combined for w in ("discord", "vesktop", "telegram", "signal", "slack", "element")):
        return "chat"
    if any(w in combined for w in ("spotify", "vlc", "mpv", "obs", "pavucontrol", "audacity", "gimp", "blender")):
        return "media"
    if any(w in combined for w in ("steam", "lutris", "heroic", "minecraft", "prism", "gamescope")):
        return "game"
    if any(w in combined for w in ("thunar", "nautilus", "dolphin", "nemo", "pcmanfm", "files")):
        return "files"
    if any(w in combined for w in ("kitty", "alacritty", "wezterm", "foot", "konsole", "terminal", "btop")):
        return "terminal"
    return "slime"

CATEGORY_PRIORITY = {
    "code": 8,
    "game": 7,
    "browser": 6,
    "media": 5,
    "chat": 4,
    "files": 3,
    "terminal": 2,
    "slime": 1,
}

ws_icons = {}
for c in clients:
    cls = (c.get("class") or c.get("initialClass") or "").strip()
    if not cls:
        continue
    ws_obj = c.get("workspace", {}) or {}
    ws_id = str(ws_obj.get("id", ""))
    ws_name = str(ws_obj.get("name", ""))
    if ws_name.startswith("special:") or not ws_id.isdigit():
        continue
    cat = classify_app_emblem(cls.lower(), str(c.get("title") or ""))
    prev = ws_icons.get(ws_id, "")
    if not prev or CATEGORY_PRIORITY.get(cat, 0) > CATEGORY_PRIORITY.get(prev, 0):
        ws_icons[ws_id] = cat

# 1. Only include windows that are hidden in a special workspace OR belong to background/tray apps
for c in clients:
    cls = (c.get("class") or c.get("initialClass") or "").strip()
    if not cls:
        continue
    key = cls.lower()
    ws_name = (c.get("workspace", {}) or {}).get("name", "")
    is_special = ws_name.startswith("special:")
    if not is_special and key not in BG_KEYS:
        continue
    if key in seen:
        continue
    seen.add(key)
    spec_id = ""
    if is_special:
        spec_id = ws_name.split(":", 1)[1]
    elif key in ("discord", "vesktop"):
        spec_id = "chat"
    elif key == "spotify":
        spec_id = "music"
    elif key == "sysmon-btop":
        spec_id = "sysmon"

    apps.append({
        "id": key,
        "name": cls,
        "title": (c.get("title") or cls)[:40],
        "icon": find_icon(key),
        "address": c.get("address", ""),
        "workspace": ws_name,
        "specialId": spec_id,
        "isSpecial": is_special,
        "floating": bool(c.get("floating", False))
    })

# 2. Also detect background tray daemons running without any visible window (e.g. Discord closed to tray)
for proc_name, label, spec_id in BG_DAEMONS:
    if proc_name in seen:
        continue
    rc = subprocess.call(["pgrep", "-xi", proc_name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if rc == 0:
        seen.add(proc_name)
        apps.append({
            "id": proc_name,
            "name": label,
            "title": label + " (En arrière-plan)",
            "icon": find_icon(proc_name),
            "address": "",
            "workspace": f"special:{spec_id}" if spec_id else "",
            "specialId": spec_id,
            "isSpecial": False,
            "floating": False
        })

print(json.dumps({"bgApps": apps[:10], "wsIcons": ws_icons}))
EOF
        ;;
    focus-app)
        addr="${2:-}"
        spec="${3:-}"
        app_id="${4:-}"
        if [[ -n "$spec" ]]; then
            "$HOME/.config/hypr/scripts/special-ws.sh" toggle "$spec"
        elif [[ -n "$addr" ]]; then
            hyprctl dispatch "hl.dsp.focus({ window = 'address:$addr' })" >/dev/null 2>&1 || \
                hyprctl dispatch focuswindow "address:$addr" >/dev/null 2>&1 || true
        elif [[ -n "$app_id" ]]; then
            nohup "$app_id" >/dev/null 2>&1 &
        fi
        ;;
    set-opacity)
        mode="${2:-holographic}"
        if [[ "$mode" == "solid" ]]; then
            hyprctl eval "hl.config({ decoration = { active_opacity = 1.0, inactive_opacity = 1.0 } })" >/dev/null 2>&1 || \
            { hyprctl keyword decoration:active_opacity 1.0 >/dev/null 2>&1 || true; hyprctl keyword decoration:inactive_opacity 1.0 >/dev/null 2>&1 || true; }
        else
            hyprctl eval "hl.config({ decoration = { active_opacity = 0.96, inactive_opacity = 0.88 } })" >/dev/null 2>&1 || \
            { hyprctl keyword decoration:active_opacity 0.96 >/dev/null 2>&1 || true; hyprctl keyword decoration:inactive_opacity 0.88 >/dev/null 2>&1 || true; }
        fi
        ;;
    set-power)
        prof="${2:-balanced}"
        mkdir -p "$(dirname "$POWER_CACHE")"
        echo "$prof" > "$POWER_CACHE"
        command -v powerprofilesctl >/dev/null 2>&1 && powerprofilesctl set "$prof" >/dev/null 2>&1 || true
        ;;
    kill-bg-app)
        app_id="${2:-}"
        if [[ -n "$app_id" ]]; then
            pkill -i "$app_id" >/dev/null 2>&1 || true
        fi
        ;;
esac
