pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // ─── UI Overlay Visibility States ─────────────────────────────────────────
    property bool controlCenterOpen: false
    property bool keybindsOpen: false
    property int activeTab: 0 // 0: Theme/HUD, 1: Wi-Fi & VPN, 2: Audio/Display, 3: Power/Session

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
    property string wifiSsid: "Scanning..."
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

    // ─── Dynamic Great Sage Palette (Reactive to themeName) ───────────────────
    readonly property color bgVoid: "#e8080c14"
    readonly property color bgSurface: "#f20d1524"
    readonly property color bgCard: "#cc142038"
    readonly property color bgCardHover: "#dd1d2e50"
    readonly property color textPrimary: "#e2f1ff"
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
        if (themeName === "magicule") return cyanMagicule;
        return cyanMagicule;
    }

    readonly property color secondaryAccent: {
        if (themeName === "beelzebub") return cyanMagicule;
        if (themeName === "magicule") return iceMagicule;
        return goldSage;
    }

    readonly property string ctlScript: Quickshell.env("HOME") + "/.config/hypr/scripts/sage-ctl.sh"

    // ─── Helper to run shell commands ─────────────────────────────────────────
    function runCmd(args) {
        actionProc.command = args;
        actionProc.running = true;
        refreshDelayed.restart();
    }

    function runShell(cmdStr) {
        Hyprland.dispatch("exec " + cmdStr);
        refreshDelayed.restart();
    }

    function refresh() {
        if (!statusProc.running) {
            statusProc.running = true;
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
    }

    Component.onCompleted: {
        updateClock();
        refresh();
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
        interval: 350
        repeat: false
        onTriggered: root.refresh()
    }

    Process {
        id: actionProc
        command: ["true"]
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
                } catch (e) {
                    // Ignore partial parse errors
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
