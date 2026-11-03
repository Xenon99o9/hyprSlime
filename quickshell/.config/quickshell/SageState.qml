pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // ─── Multi-Menu Visibility States (Caelestia + end-4 Architecture) ────────
    property bool dashboardOpen: false
    property int activeTab: 0 // 0: Dashboard, 1: Special WS, 2: Wallpapers & Themes, 3: Displays, 4: Network & VPN, 5: Keybinds

    property bool topDropdownOpen: false
    property int topDropdownTab: 0

    property bool launcherOpen: false
    property bool cornerMenuOpen: false
    property bool sideSlidersOpen: false

    // Custom Caelestia Background App / System Tray Popover State
    property bool trayMenuOpen: false
    property var activeTrayItem: null
    property var activeBgApp: null

    // Active Monitor Tracking (Menus ONLY open on the currently active monitor)
    property string activeMenuScreen: ""
    readonly property string focusedMonitorName: {
        if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) {
            return Hyprland.focusedMonitor.name;
        }
        if (Quickshell.screens.length > 0) {
            return Quickshell.screens[0].name;
        }
        return "";
    }

    function lockActiveScreen(preferredName) {
        if (preferredName && preferredName.length > 0) {
            activeMenuScreen = preferredName;
        } else if (focusedMonitorName.length > 0) {
            activeMenuScreen = focusedMonitorName;
        }
    }

    function isActiveScreen(screenObj) {
        if (!screenObj) return true;
        if (Quickshell.screens.length <= 1) return true;
        const target = activeMenuScreen.length > 0 ? activeMenuScreen : focusedMonitorName;
        return target.length === 0 || screenObj.name === target;
    }

    // Super-tap tracking so Super alone works reliably without misfiring on Super+Key
    property double lastSuperPressTime: 0
    property double lastLauncherToggleTime: 0
    property bool superComboUsed: false
    property bool launcherWasOpenOnPress: false

    property alias controlCenterOpen: root.dashboardOpen

    function superPress() {
        launcherWasOpenOnPress = root.launcherOpen;
        lastSuperPressTime = Date.now();
        superComboUsed = false;
    }

    function superCancel() {
        superComboUsed = true;
    }

    function superRelease() {
        const now = Date.now();
        if (superComboUsed) {
            superComboUsed = false;
            return;
        }
        if (lastSuperPressTime > 0 && (now - lastSuperPressTime > 800)) {
            return;
        }
        if (launcherWasOpenOnPress || root.launcherOpen) {
            root.launcherOpen = false;
            launcherWasOpenOnPress = false;
            lastLauncherToggleTime = now;
            return;
        }
        if (now - lastLauncherToggleTime < 220) {
            return;
        }
        lastLauncherToggleTime = now;
        toggleLauncher();
    }

    function openDashboardTab(tabIndex, screenName) {
        superComboUsed = true;
        lockActiveScreen(screenName);
        activeTab = tabIndex;
        dashboardOpen = true;
        topDropdownOpen = false;
        launcherOpen = false;
        cornerMenuOpen = false;
        trayMenuOpen = false;
        loadSpecialWorkspaces();
        loadWallpapers();
        if (tabIndex === 3) loadMonitors();
        if (tabIndex === 4) scanWifi();
    }

    function toggleDashboard(screenName) {
        superComboUsed = true;
        // If the bottom app launcher is open, pressing Super + M closes it as requested!
        if (launcherOpen) {
            lastLauncherToggleTime = Date.now();
            launcherOpen = false;
            return;
        }
        lockActiveScreen(screenName);
        dashboardOpen = !dashboardOpen;
        if (dashboardOpen) {
            topDropdownOpen = false;
            launcherOpen = false;
            cornerMenuOpen = false;
            trayMenuOpen = false;
            loadSpecialWorkspaces();
            loadWallpapers();
            loadMonitors();
        }
    }

    function toggleTopDropdown(screenName) {
        superComboUsed = true;
        lockActiveScreen(screenName);
        topDropdownOpen = !topDropdownOpen;
        if (topDropdownOpen) {
            dashboardOpen = false;
            launcherOpen = false;
            cornerMenuOpen = false;
            trayMenuOpen = false;
            refresh();
        }
    }

    function toggleLauncher(screenName) {
        lastLauncherToggleTime = Date.now();
        lockActiveScreen(screenName);
        launcherOpen = !launcherOpen;
        if (launcherOpen) {
            dashboardOpen = false;
            topDropdownOpen = false;
            cornerMenuOpen = false;
            trayMenuOpen = false;
            loadApps();
        }
    }

    function toggleSideSliders(screenName) {
        superComboUsed = true;
        lockActiveScreen(screenName);
        sideSlidersOpen = !sideSlidersOpen;
        if (sideSlidersOpen) {
            dashboardOpen = false;
            topDropdownOpen = false;
            launcherOpen = false;
            cornerMenuOpen = false;
            trayMenuOpen = false;
            refresh();
        }
    }

    function setVolumeValue(val) {
        val = Math.max(0, Math.min(150, Math.round(val)));
        volume = val;
        muted = false;
        lastVolumeChangeTime = Date.now();
        volumeSyncTimer.restart();
    }

    function setBrightnessValue(val) {
        val = Math.max(5, Math.min(100, Math.round(val)));
        brightness = val;
        lastBrightnessChangeTime = Date.now();
        brightnessSyncTimer.restart();
    }

    function toggleMute() {
        muted = !muted;
        lastVolumeChangeTime = Date.now();
        runCmd([ctlScript, "toggle-mute"]);
    }

    function toggleMicMute() {
        runCmd([ctlScript, "osd-vol", "mic"]);
    }

    function toggleCornerMenu(screenName) {
        superComboUsed = true;
        lockActiveScreen(screenName);
        cornerMenuOpen = !cornerMenuOpen;
        if (cornerMenuOpen) {
            dashboardOpen = false;
            topDropdownOpen = false;
            launcherOpen = false;
            trayMenuOpen = false;
            refresh();
        }
    }

    function openTrayPopup(screenName, trayItem, bgApp) {
        lockActiveScreen(screenName);
        if (trayMenuOpen && ((trayItem && activeTrayItem === trayItem) || (bgApp && activeBgApp && activeBgApp.id === bgApp.id))) {
            trayMenuOpen = false;
            return;
        }
        activeTrayItem = trayItem || null;
        activeBgApp = bgApp || null;
        trayMenuOpen = true;
        dashboardOpen = false;
        topDropdownOpen = false;
        launcherOpen = false;
        cornerMenuOpen = false;
    }

    // ─── Telemetry Properties ─────────────────────────────────────────────────
    property int cpuUsage: 0
    property int ramUsage: 0
    property string ramText: "0G/0G"
    property int gpuUsage: 0
    property int gpuTemp: 0
    property string gpuName: "GPU"
    property string gpuVramText: ""
    property int batPercent: 100
    property string batStatus: "AC"
    property int volume: 50
    property bool muted: false
    property int brightness: 100
    property bool initialStatusLoaded: false
    property double lastVolumeChangeTime: 0
    property double lastBrightnessChangeTime: 0

    // ─── On-Screen Display (OSD) Properties ───────────────────────────────────
    property bool osdVisible: false
    property string osdMode: "volume" // "volume", "brightness", "mic"
    property int osdValue: 50
    property bool osdMuted: false

    function showOsd(mode, val, isMuted) {
        osdMode = mode;
        osdValue = val;
        osdMuted = isMuted === true;
        osdVisible = true;
        osdHideTimer.restart();
    }

    function osdVolume(action) {
        lastVolumeChangeTime = Date.now();
        if (action === "up") {
            muted = false;
            volume = Math.min(150, volume + 5);
            showOsd("volume", volume, false);
            volumeSyncTimer.restart();
        } else if (action === "down") {
            volume = Math.max(0, volume - 5);
            showOsd("volume", volume, muted);
            volumeSyncTimer.restart();
        } else if (action === "mute") {
            toggleMute();
            showOsd("volume", volume, muted);
        } else if (action === "mic") {
            toggleMicMute();
            showOsd("mic", 100, !osdMuted);
        }
    }

    function osdBrightness(action) {
        lastBrightnessChangeTime = Date.now();
        if (action === "up") {
            brightness = Math.min(100, brightness + 5);
        } else {
            brightness = Math.max(5, brightness - 5);
        }
        showOsd("brightness", brightness, false);
        brightnessSyncTimer.restart();
    }

    property bool wifiEnabled: true
    property string wifiSsid: "Disconnected"
    property var wifiNetworks: []
    property bool wifiScanning: false

    property bool vpnActive: false
    property string vpnName: "None"
    property var vpnList: []

    property bool btEnabled: false
    property string btDevice: "Off"

    property string themeName: "great_sage"
    property double lastThemeChangeTime: 0
    property bool borderFlow: false
    property bool holographicOpacity: true
    property string kbLayout: "fr"
    property var activeKbLayouts: ["fr"]
    property var workspaceMap: ({})
    property string powerProfile: "balanced"
    property string mediaText: ""
    property string clockTime: "00:00:00"
    property string clockDate: ""
    property string clockFullDate: ""
    property string clockDayNumber: "01"
    property string clockMonthName: "JAN"
    property var calendarDays: []

    // ─── Assets & Wallpaper Engine Properties ─────────────────────────────────
    readonly property string rimuruAvatar: Quickshell.env("HOME") + "/.config/hypr/wallpapers/rimuru-avatar.png"
    property string currentWallpaper: Quickshell.env("HOME") + "/.config/hypr/wallpapers/rimuru-great-sage.png"
    property var wallpapers: []
    property string transitionType: "wave"

    // ─── Dynamic Special Workspaces, Monitors & Desktop Apps ──────────────────
    property var specialWorkspaces: []
    property var monitorList: []
    property int selectedMonitorIndex: 0
    property var monitorActiveWorkspaces: ({})

    function setMonitorActiveWorkspace(monName, wsId) {
        if (!monName || wsId <= 0) return;
        const copy = Object.assign({}, monitorActiveWorkspaces);
        copy[monName] = wsId;
        monitorActiveWorkspaces = copy;
    }

    property var monitorSpecialWorkspaces: ({})

    function setMonitorSpecialWorkspace(monName, specName) {
        if (!monName) return;
        const copy = Object.assign({}, monitorSpecialWorkspaces);
        copy[monName] = specName || "";
        monitorSpecialWorkspaces = copy;
    }

    property var appList: []
    property var runningApps: []
    property var workspaceIcons: ({})
    readonly property string specialScript: Quickshell.env("HOME") + "/.config/hypr/scripts/special-ws.sh"
    readonly property string ctlScript: Quickshell.env("HOME") + "/.config/hypr/scripts/sage-ctl.sh"

    // ─── Dynamic Great Sage Palette (Reactive to themeName) ───────────────────
    readonly property color bgVoid: "#f2060a12"
    readonly property color bgSurface: "#f509101d"
    readonly property color bgCard: "#e6101b2e"
    readonly property color bgCardHover: "#f0182945"
    readonly property color textPrimary: "#e8f4ff"
    readonly property color textMuted: "#7c99bf"

    readonly property color cyanMagicule: "#00e5ff"
    readonly property color azureRimuru: "#2979ff"
    readonly property color goldSage: "#ffd54f"
    readonly property color purpleBeelzebub: "#b388ff"
    readonly property color iceMagicule: "#84ffff"
    readonly property color crimsonAlert: "#ff5252"
    readonly property color emeraldOk: "#00e676"

    readonly property color diabloCrimson: "#e53935"
    readonly property color diabloGold: "#ffd54f"
    readonly property color testarossaWhite: "#ffffff"
    readonly property color testarossaRuby: "#ef4444"
    readonly property color carreraGold: "#fbbf24"
    readonly property color carreraViolet: "#a855f7"
    readonly property color ultimaViolet: "#c084fc"
    readonly property color ultimaCyan: "#10b981"
    readonly property color mustangOrange: "#f97316"
    readonly property color mustangAmber: "#ffd54f"

    readonly property color primaryAccent: {
        if (themeName === "diablo") return diabloCrimson;
        if (themeName === "testarossa") return testarossaWhite;
        if (themeName === "carrera") return carreraGold;
        if (themeName === "ultima") return ultimaViolet;
        if (themeName === "mustang") return mustangOrange;
        if (themeName === "beelzebub") return purpleBeelzebub;
        if (themeName === "hellflare") return crimsonAlert;
        if (themeName === "magicule") return cyanMagicule;
        return cyanMagicule;
    }

    readonly property color secondaryAccent: {
        if (themeName === "diablo") return diabloGold;
        if (themeName === "testarossa") return testarossaRuby;
        if (themeName === "carrera") return carreraViolet;
        if (themeName === "ultima") return ultimaCyan;
        if (themeName === "mustang") return mustangAmber;
        if (themeName === "beelzebub") return cyanMagicule;
        if (themeName === "hellflare") return goldSage;
        if (themeName === "magicule") return iceMagicule;
        return goldSage;
    }

    // ─── Helper Actions ───────────────────────────────────────────────────────
    function runCmd(args) {
        if (actionProc.running) {
            actionProc.running = false;
        }
        actionProc.command = args;
        actionProc.running = true;
        refreshDelayed.restart();
    }

    function launchApp(execCmd, appName) {
        launcherOpen = false;
        runCmd([ctlScript, "app-launch", execCmd, appName || ""]);
    }

    function switchNormalWorkspace(wsId) {
        if (specialToggleProc.running) {
            specialToggleProc.running = false;
        }
        specialToggleProc.command = [specialScript, "switch-normal", wsId.toString()];
        specialToggleProc.running = true;
    }

    // Special Workspaces Actions
    function loadSpecialWorkspaces() {
        if (!specialListProc.running) {
            specialListProc.running = true;
        }
    }

    function toggleSpecialWs(wsId) {
        if (specialToggleProc.running) {
            specialToggleProc.running = false;
        }
        specialToggleProc.command = [specialScript, "toggle", wsId];
        specialToggleProc.running = true;
    }

    function updateSpecialWs(wsId, newBind, newCmd) {
        specialModProc.command = [specialScript, "update", wsId, newBind, newCmd];
        specialModProc.running = true;
    }

    function addSpecialWs(label, shortCode, bind, cmd) {
        specialModProc.command = [specialScript, "add", label, shortCode, bind, cmd];
        specialModProc.running = true;
    }

    function deleteSpecialWs(wsId) {
        specialModProc.command = [specialScript, "delete", wsId];
        specialModProc.running = true;
    }

    // Theme Actions
    function setTheme(newTheme, wallPath) {
        if (!newTheme) return;
        themeName = newTheme;
        if (wallPath) {
            currentWallpaper = wallPath;
        }
        lastThemeChangeTime = Date.now();
        if (themeProc.running) {
            themeProc.running = false;
        }
        themeProc.command = [ctlScript, "set-theme", newTheme, wallPath || ""];
        themeProc.running = true;
    }

    // Wallpaper Actions
    function setWallpaper(path) {
        if (!path) return;
        currentWallpaper = path;
        lastThemeChangeTime = Date.now();
        if (wallProc.running) {
            wallProc.running = false;
        }
        wallProc.command = [ctlScript, "set-wallpaper", path, transitionType];
        wallProc.running = true;
    }

    function cycleWallpaper() {
        if (wallpapers.length === 0) return;
        let idx = 0;
        for (let i = 0; i < wallpapers.length; ++i) {
            if (wallpapers[i].path === currentWallpaper) {
                idx = (i + 1) % wallpapers.length;
                break;
            }
        }
        setWallpaper(wallpapers[idx].path);
    }

    function refresh() {
        if (!statusProc.running) {
            statusProc.running = true;
        }
        loadSpecialWorkspaces();
        loadRunningApps();
    }

    function loadRunningApps() {
        if (!runningAppsProc.running) {
            runningAppsProc.running = true;
        }
    }

    function focusRunningApp(appData) {
        if (!appData) return;
        runCmd([ctlScript, "focus-app", appData.address || "", appData.specialId || "", appData.id || ""]);
    }

    function cyclePowerProfile() {
        let next = "balanced";
        if (powerProfile === "power-saver") {
            next = "balanced";
        } else if (powerProfile === "balanced") {
            next = "performance";
        } else {
            next = "power-saver";
        }
        powerProfile = next;
        runCmd([ctlScript, "set-power", next]);
    }

    function loadWallpapers() {
        if (!wallListProc.running) {
            wallListProc.running = true;
        }
    }

    function loadApps() {
        if (!appListProc.running) {
            appListProc.running = true;
        }
    }

    function loadMonitors() {
        if (!monitorListProc.running) {
            monitorListProc.running = true;
        }
    }

    function applyMonitors(monitorsData) {
        if (monitorModProc.running) {
            monitorModProc.running = false;
        }
        monitorModProc.command = [ctlScript, "monitor-apply", JSON.stringify(monitorsData)];
        monitorModProc.running = true;
    }

    function applyMonitorPreset(presetName) {
        if (monitorModProc.running) {
            monitorModProc.running = false;
        }
        monitorModProc.command = [ctlScript, "monitor-preset", presetName];
        monitorModProc.running = true;
    }

    function loadWorkspaceMap() {
        if (!wsMapProc.running) {
            wsMapProc.running = true;
        }
    }

    function applyWorkspaceMapping(mapObj) {
        workspaceMap = mapObj;
        runCmd([ctlScript, "workspace-map-apply", JSON.stringify(mapObj)]);
    }

    function autoDistributeWorkspaces() {
        const mons = monitorList.filter(m => !m.disabled);
        let monNames = mons.map(m => m.name);
        if (monNames.length === 0) monNames = ["eDP-1"];
        const out = {};
        const numM = monNames.length;
        for (let ws = 1; ws <= 10; ++ws) {
            if (numM === 1) {
                out[ws.toString()] = monNames[0];
            } else if (numM === 2) {
                out[ws.toString()] = ws <= 5 ? monNames[0] : monNames[1];
            } else {
                const idx = Math.min(numM - 1, Math.floor((ws - 1) * numM / 10));
                out[ws.toString()] = monNames[idx];
            }
        }
        applyWorkspaceMapping(out);
    }

    function loadKbLayouts() {
        if (!kbListProc.running) {
            kbListProc.running = true;
        }
    }

    function addKbLayout(code) {
        const list = (activeKbLayouts || []).slice();
        if (list.indexOf(code) === -1) {
            list.push(code);
        }
        activeKbLayouts = list;
        kbLayout = code;
        runCmd([ctlScript, "kb-set", code, JSON.stringify(list)]);
    }

    function removeKbLayout(code) {
        let list = (activeKbLayouts || []).filter(k => k !== code);
        if (list.length === 0) list = ["fr"];
        activeKbLayouts = list;
        if (kbLayout === code) {
            kbLayout = list[0];
        }
        runCmd([ctlScript, "kb-set", kbLayout, JSON.stringify(list)]);
    }

    function selectKbLayout(code) {
        kbLayout = code;
        runCmd([ctlScript, "kb-set", code, JSON.stringify(activeKbLayouts)]);
    }

    function scanWifi() {
        if (!wifiScanProc.running) {
            wifiScanning = true;
            wifiScanProc.running = true;
        }
    }

    function buildCalendarGrid(now) {
        const year = now.getFullYear();
        const month = now.getMonth();
        const today = now.getDate();

        const firstDay = new Date(year, month, 1);
        // Monday-based index (0 = Mon .. 6 = Sun)
        const startDow = (firstDay.getDay() + 6) % 7;
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const daysInPrev = new Date(year, month, 0).getDate();

        const cells = [];
        for (let i = 0; i < 42; ++i) {
            const dNum = i - startDow + 1;
            if (dNum < 1) {
                cells.push({ label: (daysInPrev + dNum).toString(), inMonth: false, isToday: false });
            } else if (dNum > daysInMonth) {
                cells.push({ label: (dNum - daysInMonth).toString(), inMonth: false, isToday: false });
            } else {
                cells.push({ label: dNum.toString(), inMonth: true, isToday: (dNum === today) });
            }
        }
        calendarDays = cells;
    }

    function updateClock() {
        const now = new Date();
        clockTime = Qt.formatTime(now, "HH:mm:ss");
        clockDate = Qt.formatDate(now, "ddd dd MMM");
        clockFullDate = Qt.formatDate(now, "dddd dd MMMM yyyy");
        const newDay = Qt.formatDate(now, "dd");
        if (newDay !== clockDayNumber || calendarDays.length === 0) {
            clockDayNumber = newDay;
            clockMonthName = Qt.formatDate(now, "MMMM yyyy").toUpperCase();
            buildCalendarGrid(now);
        }
    }

    Component.onCompleted: {
        updateClock();
        refresh();
        loadWallpapers();
        loadSpecialWorkspaces();
        loadMonitors();
        loadWorkspaceMap();
        loadKbLayouts();
        loadApps();
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "monitoradded" || event.name === "monitorremoved" || event.name === "configreloaded") {
                root.loadMonitors();
            } else if (event.name === "activespecial" || event.name === "workspace" || event.name === "workspacev2") {
                root.loadSpecialWorkspaces();
                root.loadRunningApps();
                if (event.name === "workspace" || event.name === "workspacev2") {
                    const wsId = parseInt(event.data);
                    if (wsId > 0 && Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) {
                        root.setMonitorActiveWorkspace(Hyprland.focusedMonitor.name, wsId);
                    }
                } else if (event.name === "activespecial") {
                    const specParts = (event.data || "").split(",");
                    if (specParts.length >= 2) {
                        const sName = specParts[0].trim();
                        const mName = specParts[1].trim();
                        root.setMonitorSpecialWorkspace(mName, sName);
                    } else {
                        root.loadMonitors();
                    }
                }
            } else if (event.name === "openwindow" || event.name === "closewindow" || event.name === "movewindow") {
                root.loadSpecialWorkspaces();
                root.loadRunningApps();
            } else if (event.name === "focusedmon" || event.name === "focusedmonv2") {
                if (!root.dashboardOpen && !root.topDropdownOpen && !root.launcherOpen && !root.cornerMenuOpen && !root.trayMenuOpen) {
                    root.lockActiveScreen("");
                }
                const parts = (event.data || "").split(",");
                if (parts.length >= 2) {
                    const mName = parts[0].trim();
                    const wId = parseInt(parts[1].trim());
                    if (mName && wId > 0) {
                        root.setMonitorActiveWorkspace(mName, wId);
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateClock()
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        id: refreshDelayed
        interval: 400
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: osdHideTimer
        interval: 1900
        repeat: false
        onTriggered: root.osdVisible = false
    }

    Timer {
        id: volumeSyncTimer
        interval: 35
        repeat: false
        onTriggered: {
            if (volSyncProc.running) volSyncProc.running = false;
            volSyncProc.command = [root.ctlScript, "set-volume", root.volume.toString()];
            volSyncProc.running = true;
        }
    }

    Timer {
        id: brightnessSyncTimer
        interval: 35
        repeat: false
        onTriggered: {
            if (brightSyncProc.running) brightSyncProc.running = false;
            brightSyncProc.command = [root.ctlScript, "set-brightness", root.brightness.toString()];
            brightSyncProc.running = true;
        }
    }

    Process {
        id: volSyncProc
        command: ["true"]
    }

    Process {
        id: brightSyncProc
        command: ["true"]
    }

    Process {
        id: osdProc
        command: ["true"]
        stdout: StdioCollector {
            id: osdCollector
            onStreamFinished: {
                try {
                    const data = JSON.parse(osdCollector.text.trim());
                    const now = Date.now();
                    if (data.mode === "volume") {
                        if (now - root.lastVolumeChangeTime > 1200) {
                            root.volume = data.value;
                            root.muted = data.muted === true;
                        }
                    } else if (data.mode === "brightness") {
                        if (now - root.lastBrightnessChangeTime > 1200) {
                            root.brightness = data.value;
                        }
                    } else if (data.mode === "mic") {
                        root.showOsd("mic", data.value, data.muted === true);
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: actionProc
        command: ["true"]
    }

    Process {
        id: themeProc
        command: ["true"]
        onExited: root.refresh()
    }

    Process {
        id: wallProc
        command: ["true"]
        onExited: root.refresh()
    }

    Process {
        id: specialToggleProc
        command: ["true"]
        onExited: root.loadSpecialWorkspaces()
    }

    Process {
        id: specialModProc
        command: ["true"]
        onExited: root.loadSpecialWorkspaces()
    }

    Process {
        id: specialListProc
        command: [root.specialScript, "list"]
        stdout: StdioCollector {
            id: specialCollector
            onStreamFinished: {
                try {
                    root.specialWorkspaces = JSON.parse(specialCollector.text.trim());
                } catch (e) {}
            }
        }
    }

    Process {
        id: appListProc
        command: [root.ctlScript, "app-list"]
        stdout: StdioCollector {
            id: appCollector
            onStreamFinished: {
                try {
                    root.appList = JSON.parse(appCollector.text.trim());
                } catch (e) {
                    root.appList = [];
                }
            }
        }
    }

    Process {
        id: runningAppsProc
        command: [root.ctlScript, "running-apps"]
        stdout: StdioCollector {
            id: runningAppsCollector
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(runningAppsCollector.text.trim());
                    if (Array.isArray(parsed)) {
                        root.runningApps = parsed;
                    } else if (parsed && typeof parsed === "object") {
                        root.runningApps = parsed.bgApps || [];
                        root.workspaceIcons = parsed.wsIcons || {};
                    }
                } catch (e) {
                    root.runningApps = [];
                }
            }
        }
    }

    Process {
        id: monitorListProc
        command: [root.ctlScript, "monitor-list"]
        stdout: StdioCollector {
            id: monitorCollector
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(monitorCollector.text.trim());
                    root.monitorList = parsed;
                    if (root.selectedMonitorIndex >= parsed.length) {
                        root.selectedMonitorIndex = 0;
                    }
                    for (let i = 0; i < parsed.length; ++i) {
                        const m = parsed[i];
                        if (m && m.name) {
                            if (m.activeWsId) root.setMonitorActiveWorkspace(m.name, m.activeWsId);
                            root.setMonitorSpecialWorkspace(m.name, m.specialWs || "");
                        }
                    }
                } catch (e) {
                    root.monitorList = [];
                }
            }
        }
    }

    Process {
        id: monitorModProc
        command: ["true"]
        onExited: {
            root.loadMonitors();
            root.loadWorkspaceMap();
        }
    }

    Process {
        id: wsMapProc
        command: [root.ctlScript, "workspace-map-get"]
        stdout: StdioCollector {
            id: wsMapCollector
            onStreamFinished: {
                try {
                    root.workspaceMap = JSON.parse(wsMapCollector.text.trim());
                } catch (e) {}
            }
        }
    }

    Process {
        id: kbListProc
        command: [root.ctlScript, "kb-get"]
        stdout: StdioCollector {
            id: kbListCollector
            onStreamFinished: {
                try {
                    const data = JSON.parse(kbListCollector.text.trim());
                    if (data && data.active) {
                        root.activeKbLayouts = data.active;
                        root.kbLayout = data.current || data.active[0] || "fr";
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: statusProc
        command: [root.ctlScript, "status"]
        stdout: StdioCollector {
            id: statusCollector
            onStreamFinished: {
                try {
                    const data = JSON.parse(statusCollector.text.trim());
                    root.cpuUsage = data.cpu !== undefined ? data.cpu : 0;
                    root.ramUsage = data.ram !== undefined ? data.ram : 0;
                    root.ramText = data.ramText !== undefined ? data.ramText : "";
                    root.gpuUsage = data.gpu !== undefined ? data.gpu : 0;
                    root.gpuTemp = data.gpuTemp !== undefined ? data.gpuTemp : 0;
                    root.gpuName = data.gpuName !== undefined && data.gpuName.length > 0 ? data.gpuName : "GPU";
                    root.gpuVramText = data.gpuVram !== undefined ? data.gpuVram : "";
                    root.batPercent = data.bat !== undefined ? data.bat : 100;
                    root.batStatus = data.batStatus !== undefined ? data.batStatus : "AC";
                    const newVol = data.vol !== undefined ? data.vol : 50;
                    const newMuted = data.muted !== undefined ? data.muted : false;
                    const newBright = data.bright !== undefined ? data.bright : 100;
                    const now = Date.now();
                    const volAdjusting = (now - root.lastVolumeChangeTime) < 1200;
                    const brightAdjusting = (now - root.lastBrightnessChangeTime) < 1200;

                    if (!volAdjusting) {
                        if (root.initialStatusLoaded && (newVol !== root.volume || newMuted !== root.muted)) {
                            root.showOsd("volume", newVol, newMuted);
                        }
                        root.volume = newVol;
                        root.muted = newMuted;
                    }
                    if (!brightAdjusting) {
                        if (root.initialStatusLoaded && newBright !== root.brightness) {
                            root.showOsd("brightness", newBright, false);
                        }
                        root.brightness = newBright;
                    }
                    root.initialStatusLoaded = true;
                    root.wifiEnabled = data.wifiEnabled !== undefined ? data.wifiEnabled : false;
                    root.wifiSsid = data.wifiSsid !== undefined ? data.wifiSsid : "Disconnected";
                    root.vpnActive = data.vpnActive !== undefined ? data.vpnActive : false;
                    root.vpnName = data.vpnName !== undefined ? data.vpnName : "None";
                    root.vpnList = data.vpns !== undefined ? data.vpns : [];
                    root.btEnabled = data.btEnabled !== undefined ? data.btEnabled : false;
                    root.btDevice = data.btDevice !== undefined ? data.btDevice : "Off";
                    if (Date.now() - root.lastThemeChangeTime > 3000) {
                        if (data.theme !== undefined && data.theme.length > 0) {
                            root.themeName = data.theme;
                        }
                        if (data.wallpaper !== undefined && data.wallpaper.length > 0) {
                            root.currentWallpaper = data.wallpaper;
                        }
                    }
                    root.borderFlow = data.borderFlow !== undefined ? data.borderFlow : false;
                    root.kbLayout = data.kbLayout !== undefined ? data.kbLayout : "fr";
                    root.powerProfile = data.powerProfile !== undefined ? data.powerProfile : "balanced";
                    root.mediaText = data.media !== undefined ? data.media : "";
                } catch (e) {}
            }
        }
    }

    Process {
        id: wallListProc
        command: [root.ctlScript, "wallpaper-list"]
        stdout: StdioCollector {
            id: wallCollector
            onStreamFinished: {
                try {
                    root.wallpapers = JSON.parse(wallCollector.text.trim());
                } catch (e) {
                    root.wallpapers = [];
                }
            }
        }
    }

    Process {
        id: wifiScanProc
        command: [root.ctlScript, "wifi-list"]
        stdout: StdioCollector {
            id: wifiCollector
            onStreamFinished: {
                root.wifiScanning = false;
                try {
                    root.wifiNetworks = JSON.parse(wifiCollector.text.trim());
                } catch (e) {
                    root.wifiNetworks = [];
                }
            }
        }
    }
}
