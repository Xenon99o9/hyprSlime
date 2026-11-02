pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // ─── Multi-Menu Visibility States (Caelestia + end-4 Architecture) ────────
    property bool dashboardOpen: false
    property int activeTab: 0 // 0: Dashboard, 1: Special WS, 2: Wallpapers & Themes, 3: Network & VPN, 4: Keybinds

    property bool topDropdownOpen: false
    property int topDropdownTab: 0 // 0: Media & Now Playing, 1: Calendar & Time, 2: Telemetry Gauges

    property bool launcherOpen: false
    property bool cornerMenuOpen: false

    // Legacy aliases for compatibility
    property alias controlCenterOpen: root.dashboardOpen

    function openDashboardTab(tabIndex) {
        activeTab = tabIndex;
        dashboardOpen = true;
        topDropdownOpen = false;
        launcherOpen = false;
        cornerMenuOpen = false;
        loadSpecialWorkspaces();
        loadWallpapers();
        if (tabIndex === 3) scanWifi();
    }

    function toggleDashboard() {
        dashboardOpen = !dashboardOpen;
        if (dashboardOpen) {
            topDropdownOpen = false;
            launcherOpen = false;
            cornerMenuOpen = false;
            loadSpecialWorkspaces();
            loadWallpapers();
        }
    }

    function toggleTopDropdown() {
        topDropdownOpen = !topDropdownOpen;
        if (topDropdownOpen) {
            dashboardOpen = false;
            launcherOpen = false;
            cornerMenuOpen = false;
            refresh();
        }
    }

    function toggleLauncher() {
        launcherOpen = !launcherOpen;
        if (launcherOpen) {
            dashboardOpen = false;
            topDropdownOpen = false;
            cornerMenuOpen = false;
            loadApps();
        }
    }

    function toggleCornerMenu() {
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

    // ─── Assets & Wallpaper Engine Properties ─────────────────────────────────
    readonly property string rimuruAvatar: Quickshell.env("HOME") + "/.config/hypr/wallpapers/rimuru-avatar.png"
    property string currentWallpaper: Quickshell.env("HOME") + "/.config/hypr/wallpapers/rimuru-great-sage.png"
    property var wallpapers: []
    property string transitionType: "wave"

    // ─── Dynamic Special Workspaces & Desktop Apps ────────────────────────────
    property var specialWorkspaces: []
    property var appList: []
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
        runCmd([specialScript, "toggle", wsId]);
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

    function scanWifi() {
        if (!wifiScanProc.running) {
            wifiScanning = true;
            wifiScanProc.running = true;
        }
    }

    function updateClock() {
        const now = new Date();
        clockTime = Qt.formatTime(now, "HH:mm:ss");
        clockDate = Qt.formatDate(now, "ddd dd MMM");
        clockFullDate = Qt.formatDate(now, "dddd, dd MMMM yyyy");
        clockDayNumber = Qt.formatDate(now, "dd");
        clockMonthName = Qt.formatDate(now, "MMMM yyyy").toUpperCase();
    }

    Component.onCompleted: {
        updateClock();
        refresh();
        loadWallpapers();
        loadSpecialWorkspaces();
        loadApps();
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

    Process {
        id: actionProc
        command: ["true"]
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
                    root.volume = data.vol !== undefined ? data.vol : 50;
                    root.muted = data.muted !== undefined ? data.muted : false;
                    root.brightness = data.bright !== undefined ? data.bright : 100;
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
