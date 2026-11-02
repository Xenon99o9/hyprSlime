#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  HYPRSLIME — Great Sage System Backend & Telemetry Controller (sage-ctl.sh)
#  Provides fast JSON telemetry and executes actions for the Quickshell HUD
# ══════════════════════════════════════════════════════════════════════════════

set -u

CONF_DIR="$HOME/.config/hypr/conf"
COLORS_CONF="$CONF_DIR/colors.conf"
COLORS_LUA="$CONF_DIR/colors.lua"
ANIM_CONF="$CONF_DIR/animations.conf"
ANIM_LUA="$CONF_DIR/animations.lua"
INPUT_CONF="$CONF_DIR/input.conf"
INPUT_LUA="$CONF_DIR/input.lua"
STATE_FILE="$HOME/.cache/hyprslime-state.json"

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
    local active_theme="great_sage"
    if [[ -f "$COLORS_LUA" ]]; then
        if grep -q "presets\.magicule" "$COLORS_LUA"; then active_theme="magicule"
        elif grep -q "presets\.beelzebub" "$COLORS_LUA"; then active_theme="beelzebub"
        fi
    fi

    local border_flow="false"
    if [[ -f "$ANIM_LUA" ]] && grep -q 'leaf = "borderangle".*enabled = true' "$ANIM_LUA"; then
        border_flow="true"
    fi

    local kb_layout="fr"
    if [[ -f "$INPUT_LUA" ]]; then
        kb_layout=$(awk -F'"' '/kb_layout/{print $2; exit}' "$INPUT_LUA")
    fi

    # 10. Power Profile
    local power_profile="balanced"
    if command -v powerprofilesctl >/dev/null 2>&1; then
        power_profile=$(powerprofilesctl get 2>/dev/null || echo "balanced")
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

    printf '{"cpu":%d,"ram":%d,"ramText":"%s","bat":%d,"batStatus":"%s","vol":%d,"muted":%s,"bright":%d,"wifiEnabled":%s,"wifiSsid":"%s","vpnActive":%s,"vpnName":"%s","vpns":%s,"btEnabled":%s,"btDevice":"%s","theme":"%s","borderFlow":%s,"kbLayout":"%s","powerProfile":"%s","media":"%s"}\n' \
        "${cpu_usage:-0}" "${ram_usage:-0}" "$(json_escape "$ram_text")" \
        "${bat_pct:-100}" "$(json_escape "$bat_status")" \
        "${vol_pct:-50}" "$vol_muted" "${bright_pct:-100}" \
        "$wifi_enabled" "$(json_escape "$wifi_ssid")" \
        "$vpn_active" "$(json_escape "$vpn_name")" "$vpn_list_json" \
        "$bt_enabled" "$(json_escape "$bt_device")" \
        "$active_theme" "$border_flow" "$(json_escape "$kb_layout")" \
        "$(json_escape "$power_profile")" "$(json_escape "$media_text")"
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
    set-volume)
        val="${2:-50}"
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "${val}%"
        ;;
    toggle-mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    set-brightness)
        val="${2:-100}"
        [[ "$val" -lt 5 ]] && val=5
        brightnessctl s "${val}%"
        ;;
    set-theme)
        theme="${2:-great_sage}"
        case "$theme" in
            magicule)
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
                [[ -f "$COLORS_CONF" ]] && {
                    sed -i 's/^\$active_border.*/$active_border    = $border_beelzebub/' "$COLORS_CONF"
                    sed -i 's/^\$slime_glow.*/$slime_glow       = $glow_beelzebub/' "$COLORS_CONF"
                }
                [[ -f "$COLORS_LUA" ]] && {
                    sed -i 's/^M\.active_border.*/M.active_border   = M.presets.beelzebub.border/' "$COLORS_LUA"
                    sed -i 's/^M\.slime_glow.*/M.slime_glow      = M.presets.beelzebub.glow/' "$COLORS_LUA"
                }
                ;;
            *)
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
        hyprctl reload >/dev/null 2>&1 || true
        ;;
    set-flow)
        mode="${2:-false}"
        if [[ "$mode" == "true" ]]; then
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
        [[ -f "$INPUT_CONF" ]] && sed -i "s/^[[:space:]]*kb_layout = .*/    kb_layout = $kb/" "$INPUT_CONF"
        [[ -f "$INPUT_LUA" ]] && sed -i "s/^[[:space:]]*kb_layout[[:space:]]*= .*/        kb_layout  = \"$kb\",/" "$INPUT_LUA"
        hyprctl reload >/dev/null 2>&1 || true
        ;;
    set-opacity)
        mode="${2:-holographic}"
        if [[ "$mode" == "solid" ]]; then
            hyprctl keyword decoration:active_opacity 1.0 >/dev/null 2>&1 || true
            hyprctl keyword decoration:inactive_opacity 1.0 >/dev/null 2>&1 || true
        else
            hyprctl keyword decoration:active_opacity 0.96 >/dev/null 2>&1 || true
            hyprctl keyword decoration:inactive_opacity 0.88 >/dev/null 2>&1 || true
        fi
        ;;
    set-power)
        prof="${2:-balanced}"
        command -v powerprofilesctl >/dev/null 2>&1 && powerprofilesctl set "$prof"
        ;;
esac
