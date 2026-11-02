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

    // Super-tap tracking so Super alone works reliably without misfiring on Super+Key
    property double lastSuperPressTime: 0
    property double lastLauncherToggleTime: 0
    property bool superComboUsed: false

    property alias controlCenterOpen: root.dashboardOpen

    function superPress() {
        lastSuperPressTime = Date.now();
        superComboUsed = false;
    }

    function superCancel() {
        superComboUsed = true;
    }

    function superRelease() {
        const now = Date.now();
        if (now - lastLauncherToggleTime < 220) {
            return;
        }
        if (superComboUsed) {
            superComboUsed = false;
            return;
        }
        if (lastSuperPressTime > 0 && (now - lastSuperPressTime > 700)) {
            return;
        }
        lastLauncherToggleTime = now;
        toggleLauncher();
    }

    function openDashboardTab(tabIndex) {
        superComboUsed = true;
        activeTab = tabIndex;
        dashboardOpen = true;
        topDropdownOpen = false;
        launcherOpen = false;
        cornerMenuOpen = false;
        loadSpecialWorkspaces();
        loadWallpapers();
        if (tabIndex === 3) loadMonitors();
        if (tabIndex === 4) scanWifi();
    }

    function toggleDashboard() {
        superComboUsed = true;
        dashboardOpen = !dashboardOpen;
        if (dashboardOpen) {
            topDropdownOpen = false;
            launcherOpen = false;
            cornerMenuOpen = false;
            loadSpecialWorkspaces();
            loadWallpapers();
            loadMonitors();
        }
    }

    function toggleTopDropdown() {
        superComboUsed = true;
        topDropdownOpen = !topDropdownOpen;
        if (topDropdownOpen) {
            dashboardOpen = false;
            launcherOpen = false;
            cornerMenuOpen = false;
            refresh();
        }
    }

    function toggleLauncher() {
        lastLauncherToggleTime = Date.now();
        launcherOpen = !launcherOpen;
        if (launcherOpen) {
            dashboardOpen = false;
            topDropdownOpen = false;
            cornerMenuOpen = false;
            loadApps();
        }
    }

    function toggleCornerMenu() {
        superComboUsed = true;
        cornerMenuOpen = !cornerMenuOpen;
        if (cornerMenuOpen) {
            dashboardOpen = false;
            topDropdownOpen = false;
            launcherOpen = false;
            refresh();
        }
    }

    // ─── Telemetry Properties ─────────────────────────────────────────────────
    property int cpuUsage: 0
    property int ramUsage: 0
    property string ramText: "0G/0G"
    property int batPercent: 100
    property string batStatus: "AC"
    property int volume: 50
    property bool muted: false
    property int brightness: 100
    property bool initialStatusLoaded: false

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
        if (action === "up") {
            muted = false;
            volume = Math.min(150, volume + 5);
            showOsd("volume", volume, false);
        } else if (action === "down") {
            volume = Math.max(0, volume - 5);
            showOsd("volume", volume, muted);
        } else if (action === "mute") {
            muted = !muted;
            showOsd("volume", volume, muted);
        } else if (action === "mic") {
            showOsd("mic", 100, !osdMuted);
        }
        if (osdProc.running) {
            osdProc.running = false;
        }
        osdProc.command = [ctlScript, "osd-vol", action];
        osdProc.running = true;
    }

    function osdBrightness(action) {
        if (action === "up") {
            brightness = Math.min(100, brightness + 5);
        } else {
            brightness = Math.max(5, brightness - 5);
        }
        showOsd("brightness", brightness, false);
        if (osdProc.running) {
            osdProc.running = false;
        }
        osdProc.command = [ctlScript, "osd-bright", action];
        osdProc.running = true;
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
    property bool borderFlow: false
    property bool holographicOpacity: true
    property string kbLayout: "fr"
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
    property var appList: []
    property var runningApps: []
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

    readonly property color primaryAccent: {
        if (themeName === "beelzebub") return purpleBeelzebub;
        if (themeName === "hellflare") return crimsonAlert;
        if (themeName === "magicule") return cyanMagicule;
        return cyanMagicule;
    }

    readonly property color secondaryAccent: {
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

    function launchApp(execCmd) {
        launcherOpen = false;
        runCmd(["bash", "-c", "nohup " + execCmd + " >/dev/null 2>&1 &"]);
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

    // Wallpaper Actions
    function setWallpaper(path) {
        currentWallpaper = path;
        runCmd([ctlScript, "set-wallpaper", path, transitionType]);
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
        loadApps();
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "monitoradded" || event.name === "monitorremoved" || event.name === "configreloaded") {
                root.loadMonitors();
            } else if (event.name === "openwindow" || event.name === "closewindow" || event.name === "movewindow" || event.name === "activespecial") {
                root.loadRunningApps();
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

    Process {
        id: osdProc
        command: ["true"]
        stdout: StdioCollector {
            id: osdCollector
            onStreamFinished: {
                try {
                    const data = JSON.parse(osdCollector.text.trim());
                    if (data.mode === "volume") {
                        root.volume = data.value;
                        root.muted = data.muted === true;
                        root.showOsd("volume", root.volume, root.muted);
                    } else if (data.mode === "brightness") {
                        root.brightness = data.value;
                        root.showOsd("brightness", root.brightness, false);
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
                    root.runningApps = JSON.parse(runningAppsCollector.text.trim());
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
                } catch (e) {
                    root.monitorList = [];
                }
            }
        }
    }

    Process {
        id: monitorModProc
        command: ["true"]
        onExited: root.loadMonitors()
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
                    root.batPercent = data.bat !== undefined ? data.bat : 100;
                    root.batStatus = data.batStatus !== undefined ? data.batStatus : "AC";
                    const newVol = data.vol !== undefined ? data.vol : 50;
                    const newMuted = data.muted !== undefined ? data.muted : false;
                    const newBright = data.bright !== undefined ? data.bright : 100;
                    if (root.initialStatusLoaded) {
                        if (newVol !== root.volume || newMuted !== root.muted) {
                            root.showOsd("volume", newVol, newMuted);
                        } else if (newBright !== root.brightness) {
                            root.showOsd("brightness", newBright, false);
                        }
                    }
                    root.volume = newVol;
                    root.muted = newMuted;
                    root.brightness = newBright;
                    root.initialStatusLoaded = true;
                    root.wifiEnabled = data.wifiEnabled !== undefined ? data.wifiEnabled : false;
                    root.wifiSsid = data.wifiSsid !== undefined ? data.wifiSsid : "Disconnected";
                    root.vpnActive = data.vpnActive !== undefined ? data.vpnActive : false;
                    root.vpnName = data.vpnName !== undefined ? data.vpnName : "None";
                    root.vpnList = data.vpns !== undefined ? data.vpns : [];
                    root.btEnabled = data.btEnabled !== undefined ? data.btEnabled : false;
                    root.btDevice = data.btDevice !== undefined ? data.btDevice : "Off";
                    root.themeName = data.theme !== undefined ? data.theme : "great_sage";
                    root.borderFlow = data.borderFlow !== undefined ? data.borderFlow : false;
                    root.kbLayout = data.kbLayout !== undefined ? data.kbLayout : "fr";
                    root.powerProfile = data.powerProfile !== undefined ? data.powerProfile : "balanced";
                    root.mediaText = data.media !== undefined ? data.media : "";
                    if (data.wallpaper !== undefined && data.wallpaper.length > 0) {
                        root.currentWallpaper = data.wallpaper;
                    }
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
