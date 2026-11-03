#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
#  HYPRSLIME — Caelestia-Style Special Workspaces Manager (special-ws.sh)
#  Supports Hyprland 0.57.0 Lua Dispatcher (`hl.dsp.*`) and Legacy `.conf`
# ══════════════════════════════════════════════════════════════════════════════

set -u

CONF_DIR="$HOME/.config/hypr/conf"
JSON_FILE="$CONF_DIR/special_workspaces.json"
LUA_FILE="$CONF_DIR/special.lua"
CONF_FILE="$CONF_DIR/special.conf"

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

def extract_special_id(ws_obj):
    if not isinstance(ws_obj, dict):
        return ""
    wname = str(ws_obj.get("name", ""))
    wtype = str(ws_obj.get("type", ""))
    if wname.startswith("special:"):
        return wname.split("special:", 1)[1]
    if wtype == "special" and wname:
        return wname
    return ""

running_ws = set()
active_special = ""
try:
    out = subprocess.check_output(["hyprctl", "clients", "-j"], stderr=subprocess.DEVNULL, text=True)
    for c in json.loads(out):
        sid = extract_special_id(c.get("workspace", {}))
        if sid:
            running_ws.add(sid)
    mon_out = subprocess.check_output(["hyprctl", "monitors", "-j"], stderr=subprocess.DEVNULL, text=True)
    for m in json.loads(mon_out):
        sid = extract_special_id(m.get("specialWorkspace", {}))
        if sid:
            active_special = sid
            break
except Exception:
    pass

for item in items:
    wid = item.get("id", "")
    item["running"] = wid in running_ws
    item["visible"] = (wid == active_special)

print(json.dumps(items))
EOF
        ;;

    toggle)
        ws_id="${2:-}"
        [[ -z "$ws_id" ]] && exit 0
        python3 - "$JSON_FILE" "$ws_id" << 'EOF'
import json, re, subprocess, sys, time

json_path, ws_id = sys.argv[1], sys.argv[2]

cmd = ""
wclass = ""
with open(json_path, "r", encoding="utf-8") as f:
    for item in json.load(f):
        if item.get("id") == ws_id:
            cmd = item.get("cmd", "").strip()
            wclass = item.get("class", "").strip()
            break

def extract_special_id(ws_obj):
    if not isinstance(ws_obj, dict):
        return ""
    wname = str(ws_obj.get("name", ""))
    wtype = str(ws_obj.get("type", ""))
    if wname.startswith("special:"):
        return wname.split("special:", 1)[1]
    if wtype == "special" and wname:
        return wname
    return ""

def get_clients():
    try:
        out = subprocess.check_output(["hyprctl", "clients", "-j"], stderr=subprocess.DEVNULL, text=True)
        return json.loads(out)
    except Exception:
        return []

def is_special_visible(target_id):
    try:
        out = subprocess.check_output(["hyprctl", "monitors", "-j"], stderr=subprocess.DEVNULL, text=True)
        for m in json.loads(out):
            if extract_special_id(m.get("specialWorkspace", {})) == target_id:
                return True
    except Exception:
        pass
    return False

def toggle_special_ws(target_id):
    # Try Hyprland 0.57.0 Lua dispatcher first, fallback to legacy dispatcher
    res = subprocess.run(
        ["hyprctl", "dispatch", f'hl.dsp.workspace.toggle_special("{target_id}")'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    if res.returncode != 0 or "error:" in res.stdout:
        subprocess.run(
            ["hyprctl", "dispatch", "togglespecialworkspace", target_id],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )

def move_window_to_special(addr, target_id):
    if not addr:
        return
    res = subprocess.run(
        ["hyprctl", "dispatch", f'hl.dsp.window.move({{ workspace = "special:{target_id}", window = "address:{addr}" }})'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    if res.returncode != 0 or "error:" in res.stdout:
        subprocess.run(
            ["hyprctl", "dispatch", "movetoworkspacesilent", f"special:{target_id},address:{addr}"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )

clients = get_clients()
in_special = [c for c in clients if extract_special_id(c.get("workspace", {})) == ws_id]

if in_special:
    toggle_special_ws(ws_id)
    sys.exit(0)

# Check if a matching class window exists on another workspace
matching = []
if wclass:
    for c in clients:
        if re.search(wclass, c.get("class", "")):
            matching.append(c)

if matching:
    for c in matching:
        move_window_to_special(c.get("address", ""), ws_id)
    if not is_special_visible(ws_id):
        toggle_special_ws(ws_id)
    sys.exit(0)

# No window exists yet -> spawn the application in background and ensure special:<ws_id> opens
if cmd:
    known_addrs = {c.get("address") for c in clients}
    subprocess.Popen(["bash", "-c", f"nohup {cmd} >/dev/null 2>&1 &"], start_new_session=True)

    for _ in range(35):
        time.sleep(0.12)
        now_clients = get_clients()
        in_spec_now = [c for c in now_clients if extract_special_id(c.get("workspace", {})) == ws_id]
        if in_spec_now:
            if not is_special_visible(ws_id):
                toggle_special_ws(ws_id)
            break
        new_clients = [c for c in now_clients if c.get("address") not in known_addrs]
        if new_clients:
            for nc in new_clients:
                if not wclass or re.search(wclass, nc.get("class", "")):
                    move_window_to_special(nc.get("address", ""), ws_id)
            if not is_special_visible(ws_id):
                toggle_special_ws(ws_id)
            break
EOF
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

    switch-normal)
        target_ws="${2:-1}"
        python3 - "$target_ws" << 'EOF'
import json, subprocess, sys

target_ws = sys.argv[1]

def extract_special_id(ws_obj):
    if not isinstance(ws_obj, dict):
        return ""
    wname = str(ws_obj.get("name", ""))
    wtype = str(ws_obj.get("type", ""))
    if wname.startswith("special:"):
        return wname.split("special:", 1)[1]
    if wtype == "special" and wname:
        return wname
    return ""

try:
    mon_out = subprocess.check_output(["hyprctl", "monitors", "-j"], stderr=subprocess.DEVNULL, text=True)
    monitors = json.loads(mon_out)
    for m in monitors:
        if m.get("focused") or len(monitors) == 1:
            sid = extract_special_id(m.get("specialWorkspace", {}))
            if sid:
                res = subprocess.run(
                    ["hyprctl", "dispatch", f'hl.dsp.workspace.toggle_special("{sid}")'],
                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
                )
                if res.returncode != 0 or "error:" in res.stdout:
                    subprocess.run(
                        ["hyprctl", "dispatch", "togglespecialworkspace", sid],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                    )
except Exception:
    pass

res = subprocess.run(
    ["hyprctl", "dispatch", f"hl.dsp.focus({{ workspace = {target_ws} }})"],
    stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
)
if res.returncode != 0 or "error:" in res.stdout:
    subprocess.run(
        ["hyprctl", "dispatch", "workspace", str(target_ws)],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
EOF
        ;;
esac
