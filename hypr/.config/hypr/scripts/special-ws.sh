#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  HYPRSLIME — Caelestia-Style Special Workspaces Manager (special-ws.sh)
# ══════════════════════════════════════════════════════════════════════════════

set -u

CONF_DIR="$HOME/.config/hypr/conf"
JSON_FILE="$CONF_DIR/special_workspaces.json"
LUA_FILE="$CONF_DIR/special.lua"
CONF_FILE="$CONF_DIR/special.conf"
SCRIPT_PATH="$HOME/.config/hypr/scripts/special-ws.sh"

# Ensure HYPRLAND_INSTANCE_SIGNATURE is set so hyprctl always works
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" && -d "/run/user/$(id -u)/hypr" ]]; then
    sig=$(ls -t "/run/user/$(id -u)/hypr" 2>/dev/null | head -n 1 || true)
    [[ -n "$sig" ]] && export HYPRLAND_INSTANCE_SIGNATURE="$sig"
fi

regenerate_configs() {
    python3 - "$JSON_FILE" "$LUA_FILE" "$CONF_FILE" << 'EOF'
import json, sys

json_path, lua_path, conf_path = sys.argv[1:4]
with open(json_path, "r", encoding="utf-8") as f:
    items = json.load(f)

lua_lines = [
    "-- ══════════════════════════════════════════════════════════════════════════════",
    "--  HYPRSLIME — Dynamic Caelestia Special Workspaces (conf/special.lua)",
    "-- ══════════════════════════════════════════════════════════════════════════════",
    "",
    'local home = os.getenv("HOME")',
    'local script = home .. "/.config/hypr/scripts/special-ws.sh"',
    ""
]

conf_lines = [
    "# ══════════════════════════════════════════════════════════════════════════════",
    "#  HYPRSLIME — Dynamic Caelestia Special Workspaces (conf/special.conf)",
    "# ══════════════════════════════════════════════════════════════════════════════",
    ""
]

for item in items:
    ws_id = item.get("id", "").strip()
    bind = item.get("bind", "").strip()
    wclass = item.get("class", "").strip()
    if not ws_id or not bind:
        continue
    lua_lines.append(f'hl.bind("{bind}", hl.dsp.exec_cmd(script .. " toggle \'{ws_id}\'"))')
    if wclass:
        lua_lines.append(f'hl.window_rule({{ name = "special-{ws_id}", match = {{ class = "{wclass}" }}, workspace = "special:{ws_id}" }})')

    parts = [p.strip() for p in bind.split("+") if p.strip()]
    if len(parts) >= 2:
        mods = " ".join(parts[:-1])
        key = parts[-1]
    else:
        mods = ""
        key = bind
    conf_lines.append(f"bind = {mods}, {key}, exec, ~/.config/hypr/scripts/special-ws.sh toggle '{ws_id}'")
    if wclass:
        conf_lines.append(f"windowrulev2 = workspace special:{ws_id}, class:{wclass}")

with open(lua_path, "w", encoding="utf-8") as f:
    f.write("\n".join(lua_lines) + "\n")

with open(conf_path, "w", encoding="utf-8") as f:
    f.write("\n".join(conf_lines) + "\n")
EOF
    hyprctl reload >/dev/null 2>&1 || true
}

case "${1:-list}" in
    list)
        python3 - "$JSON_FILE" << 'EOF'
import json, subprocess, sys

json_path = sys.argv[1]
try:
    with open(json_path, "r", encoding="utf-8") as f:
        items = json.load(f)
except Exception:
    items = []

running_ws = set()
try:
    out = subprocess.check_output(["hyprctl", "clients", "-j"], stderr=subprocess.DEVNULL, text=True)
    for c in json.loads(out):
        ws_name = c.get("workspace", {}).get("name", "")
        if ws_name.startswith("special:"):
            running_ws.add(ws_name.split("special:", 1)[1])
except Exception:
    pass

for item in items:
    item["running"] = item.get("id") in running_ws

print(json.dumps(items))
EOF
        ;;

    toggle)
        ws_id="${2:-}"
        [[ -z "$ws_id" ]] && exit 0
        read -r cmd wclass < <(python3 - "$JSON_FILE" "$ws_id" << 'EOF'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    for item in json.load(f):
        if item.get("id") == sys.argv[2]:
            print(f"{item.get('cmd', '')}\t{item.get('class', '')}")
            break
EOF
)
        has_client=$(hyprctl clients -j 2>/dev/null | python3 -c "
import json, re, sys
ws_id = '$ws_id'
wclass = '$wclass'
try:
    clients = json.load(sys.stdin)
    found = False
    for c in clients:
        if c.get('workspace', {}).get('name') == 'special:' + ws_id:
            found = True
            break
        if wclass and re.search(wclass, c.get('class', '')):
            found = True
            break
    print('1' if found else '0')
except Exception:
    print('0')
")
        # Always toggle the special workspace immediately so the user sees it
        hyprctl dispatch togglespecialworkspace "$ws_id" >/dev/null 2>&1 || true

        # If no window is inside special:<ws_id>, spawn the app into it
        if [[ "$has_client" == "0" && -n "$cmd" ]]; then
            hyprctl dispatch exec "[workspace special:$ws_id] $cmd" >/dev/null 2>&1 || true
        fi
        ;;

    update)
        ws_id="${2:-}"
        new_bind="${3:-}"
        new_cmd="${4:-}"
        python3 - "$JSON_FILE" "$ws_id" "$new_bind" "$new_cmd" << 'EOF'
import json, sys
json_path, ws_id, new_bind, new_cmd = sys.argv[1:5]
with open(json_path, "r", encoding="utf-8") as f:
    items = json.load(f)
for item in items:
    if item.get("id") == ws_id:
        if new_bind.strip():
            item["bind"] = new_bind.strip()
        if new_cmd.strip():
            item["cmd"] = new_cmd.strip()
with open(json_path, "w", encoding="utf-8") as f:
    json.dump(items, f, indent=2, ensure_ascii=False)
EOF
        regenerate_configs
        ;;

    add)
        label="${2:-CUSTOM}"
        short="${3:-APP}"
        bind="${4:-SUPER + N}"
        cmd="${5:-kitty}"
        python3 - "$JSON_FILE" "$label" "$short" "$bind" "$cmd" << 'EOF'
import json, re, sys
json_path, label, short, bind, cmd = sys.argv[1:6]
with open(json_path, "r", encoding="utf-8") as f:
    items = json.load(f)
ws_id = re.sub(r'[^a-z0-9]+', '', label.lower()) or "custom"
existing_ids = {i.get("id") for i in items}
base_id = ws_id
cnt = 2
while ws_id in existing_ids:
    ws_id = f"{base_id}{cnt}"
    cnt += 1
items.append({
    "id": ws_id,
    "label": label.strip().upper() or ws_id.upper(),
    "short": (short.strip().upper() or label.strip()[:3].upper()),
    "bind": bind.strip() or "SUPER + N",
    "cmd": cmd.strip() or "kitty",
    "class": ""
})
with open(json_path, "w", encoding="utf-8") as f:
    json.dump(items, f, indent=2, ensure_ascii=False)
EOF
        regenerate_configs
        ;;

    delete)
        ws_id="${2:-}"
        python3 - "$JSON_FILE" "$ws_id" << 'EOF'
import json, sys
json_path, ws_id = sys.argv[1:3]
with open(json_path, "r", encoding="utf-8") as f:
    items = [i for i in json.load(f) if i.get("id") != ws_id]
with open(json_path, "w", encoding="utf-8") as f:
    json.dump(items, f, indent=2, ensure_ascii=False)
EOF
        regenerate_configs
        ;;

    regen)
        regenerate_configs
        ;;
esac
