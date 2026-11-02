import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: ccWindow
        required property var modelData
        screen: modelData
        visible: SageState.controlCenterOpen

        WlrLayershell.namespace: "quickshell"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "#5504070d"

        // Click outside drawer to close
        MouseArea {
            anchors.fill: parent
            onClicked: SageState.controlCenterOpen = false
        }

        // Right-side Holographic Control Center Drawer (caelestia / end-4 style)
        Rectangle {
            id: drawer
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.topMargin: 52
            anchors.bottomMargin: 12
            anchors.rightMargin: 12
            width: 440
            radius: 6
            color: SageState.bgSurface
            border.width: 2
            border.color: SageState.primaryAccent

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // ─── Header ───────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "◈ GREAT SAGE SYSTEM MATRIX"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            font.bold: true
                            color: SageState.secondaryAccent
                        }
                        Text {
                            text: "« Report. All magicule subsystems online. »"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: SageState.textMuted
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 30; height: 28; radius: 4
                        color: xMouse.containsMouse ? SageState.crimsonAlert : SageState.bgCard
                        border.width: 1; border.color: SageState.crimsonAlert

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13; font.bold: true
                            color: xMouse.containsMouse ? "#080c14" : SageState.crimsonAlert
                        }
                        MouseArea {
                            id: xMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SageState.controlCenterOpen = false
                        }
                    }
                }

                // ─── Navigation Tabs ──────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: [
                            { idx: 0, title: "◈ Theme" },
                            { idx: 1, title: "◈ Wi-Fi/VPN" },
                            { idx: 2, title: "◈ Audio/Disp" },
                            { idx: 3, title: "◈ System" }
                        ]

                        Rectangle {
                            required property var modelData
                            readonly property bool active: SageState.activeTab === modelData.idx
                            Layout.fillWidth: true
                            height: 32
                            radius: 4
                            color: active ? SageState.primaryAccent : (tabMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard)
                            border.width: 1
                            border.color: active ? SageState.secondaryAccent : SageState.azureRimuru

                            Text {
                                anchors.centerIn: parent
                                text: modelData.title
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: active
                                color: active ? "#080c14" : SageState.textPrimary
                            }

                            MouseArea {
                                id: tabMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SageState.activeTab = modelData.idx;
                                    if (modelData.idx === 1) SageState.scanWifi();
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: SageState.primaryAccent
                    opacity: 0.35
                }

                // ══════════════════════════════════════════════════════════════
                //  TAB 0: THEME, BORDERS, OPACITY & KEYBOARD LAYOUT
                // ══════════════════════════════════════════════════════════════
                ColumnLayout {
                    visible: SageState.activeTab === 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    Text {
                        text: "◈ SKILL BORDER & HUD PALETTE"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12; font.bold: true
                        color: SageState.secondaryAccent
                    }

                    Repeater {
                        model: [
                            { id: "great_sage", name: "[Unique Skill: Great Sage]", desc: "Cyan Magicule -> Rimuru Azure -> Golden Eye", accent: "#ffd54f" },
                            { id: "magicule",   name: "[Slime Core: Pure Magicule]", desc: "100% Cold Magicule Cyan -> Azure -> Ice",    accent: "#84ffff" },
                            { id: "beelzebub",  name: "[Ultimate Skill: Beelzebub]", desc: "Cyan Magicule -> Azure -> Abyssal Purple",  accent: "#b388ff" }
                        ]

                        Rectangle {
                            required property var modelData
                            readonly property bool selected: SageState.themeName === modelData.id
                            Layout.fillWidth: true
                            height: 54
                            radius: 6
                            color: selected ? SageState.bgCardHover : SageState.bgCard
                            border.width: selected ? 2 : 1
                            border.color: selected ? modelData.accent : "#2a3b5c"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Rectangle {
                                    width: 14; height: 32; radius: 3
                                    color: modelData.accent
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: modelData.name
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12; font.bold: true
                                        color: selected ? modelData.accent : SageState.textPrimary
                                    }
                                    Text {
                                        text: modelData.desc
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        color: SageState.textMuted
                                    }
                                }

                                Text {
                                    text: selected ? "ACTIVE" : "SELECT"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10; font.bold: true
                                    color: selected ? modelData.accent : SageState.textMuted
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SageState.themeName = modelData.id;
                                    SageState.runCmd([SageState.ctlScript, "set-theme", modelData.id]);
                                }
                            }
                        }
                    }

                    // Border Rotation & Opacity Toggles
                    Text {
                        text: "◈ HOLOGRAPHIC EFFECTS"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12; font.bold: true
                        color: SageState.secondaryAccent
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Magicule Border Flow Toggle
                        Rectangle {
                            Layout.fillWidth: true
                            height: 46; radius: 6
                            color: SageState.borderFlow ? SageState.bgCardHover : SageState.bgCard
                            border.width: 1
                            border.color: SageState.borderFlow ? SageState.primaryAccent : "#2a3b5c"

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Magicule Border Loop"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11; font.bold: true
                                    color: SageState.textPrimary
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: SageState.borderFlow ? "ON (Animated)" : "OFF (Battery Saver)"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    color: SageState.borderFlow ? SageState.emeraldOk : SageState.textMuted
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const nextState = !SageState.borderFlow;
                                    SageState.borderFlow = nextState;
                                    SageState.runCmd([SageState.ctlScript, "set-flow", nextState ? "true" : "false"]);
                                }
                            }
                        }

                        // Window Opacity Toggle
                        Rectangle {
                            Layout.fillWidth: true
                            height: 46; radius: 6
                            color: SageState.holographicOpacity ? SageState.bgCardHover : SageState.bgCard
                            border.width: 1
                            border.color: SageState.holographicOpacity ? SageState.primaryAccent : "#2a3b5c"

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Window Translucency"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11; font.bold: true
                                    color: SageState.textPrimary
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: SageState.holographicOpacity ? "Holographic (0.96)" : "Solid Opaque (1.0)"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    color: SageState.holographicOpacity ? SageState.primaryAccent : SageState.textMuted
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SageState.holographicOpacity = !SageState.holographicOpacity;
                                    SageState.runCmd([SageState.ctlScript, "set-opacity", SageState.holographicOpacity ? "holographic" : "solid"]);
                                }
                            }
                        }
                    }

                    // Keyboard Layout Matrix
                    Text {
                        text: "◈ KEYBOARD LAYOUT MATRIX (Alt+Shift to toggle)"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12; font.bold: true
                        color: SageState.secondaryAccent
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                { code: "fr",    label: "FR (AZERTY)" },
                                { code: "us",    label: "US (QWERTY)" },
                                { code: "fr,us", label: "FR + US" },
                                { code: "be",    label: "BE" },
                                { code: "ch",    label: "CH" }
                            ]

                            Rectangle {
                                required property var modelData
                                readonly property bool active: SageState.kbLayout === modelData.code
                                Layout.fillWidth: true
                                height: 34; radius: 4
                                color: active ? SageState.primaryAccent : SageState.bgCard
                                border.width: 1
                                border.color: active ? SageState.secondaryAccent : "#2a3b5c"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10; font.bold: active
                                    color: active ? "#080c14" : SageState.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SageState.kbLayout = modelData.code;
                                        SageState.runCmd([SageState.ctlScript, "set-kb", modelData.code]);
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                // ══════════════════════════════════════════════════════════════
                //  TAB 1: WI-FI & VPN MATRIX
                // ══════════════════════════════════════════════════════════════
                ColumnLayout {
                    visible: SageState.activeTab === 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    // Wi-Fi Header Card
                    Rectangle {
                        Layout.fillWidth: true
                        height: 52; radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: SageState.wifiEnabled ? SageState.primaryAccent : SageState.crimsonAlert

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "◈ WI-FI TRANSCEIVER: " + (SageState.wifiEnabled ? "ONLINE" : "OFFLINE")
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12; font.bold: true
                                    color: SageState.wifiEnabled ? SageState.primaryAccent : SageState.crimsonAlert
                                }
                                Text {
                                    text: "Connected SSID: " + SageState.wifiSsid
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    color: SageState.textMuted
                                }
                            }

                            Rectangle {
                                width: 64; height: 28; radius: 4
                                color: SageState.bgCardHover
                                border.width: 1; border.color: SageState.secondaryAccent
                                Text {
                                    anchors.centerIn: parent
                                    text: SageState.wifiScanning ? "..." : "↻ Scan"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11; font.bold: true
                                    color: SageState.secondaryAccent
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.scanWifi()
                                }
                            }

                            Rectangle {
                                width: 64; height: 28; radius: 4
                                color: SageState.wifiEnabled ? SageState.primaryAccent : SageState.crimsonAlert
                                Text {
                                    anchors.centerIn: parent
                                    text: SageState.wifiEnabled ? "ON" : "OFF"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11; font.bold: true
                                    color: "#080c14"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd([SageState.ctlScript, "wifi-toggle"])
                                }
                            }
                        }
                    }

                    // Nearby Wi-Fi Networks List
                    Rectangle {
                        Layout.fillWidth: true
                        height: 155; radius: 6
                        color: "#88080c14"
                        border.width: 1; border.color: "#2a3b5c"
                        clip: true

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 4
                            model: SageState.wifiNetworks

                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 30; radius: 4
                                color: modelData.active ? SageState.bgCardHover : SageState.bgCard
                                border.width: modelData.active ? 1 : 0
                                border.color: SageState.emeraldOk

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8; anchors.rightMargin: 8

                                    Text {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        text: (modelData.active ? "◈ " : "  ") + modelData.ssid + " (" + modelData.signal + "%)"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: modelData.active
                                        color: modelData.active ? SageState.emeraldOk : SageState.textPrimary
                                    }

                                    Text {
                                        text: modelData.active ? "CONNECTED" : "CONNECT"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10; font.bold: true
                                        color: modelData.active ? SageState.emeraldOk : SageState.primaryAccent
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd([SageState.ctlScript, "wifi-connect", modelData.ssid])
                                }
                            }
                        }
                    }

                    // VPN Section Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "◈ VPN & ENCRYPTED TUNNELS"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12; font.bold: true
                            color: SageState.secondaryAccent
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: SageState.vpnActive ? ("🛡️ ACTIVE: " + SageState.vpnName) : "UNPROTECTED"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11; font.bold: true
                            color: SageState.vpnActive ? SageState.emeraldOk : SageState.textMuted
                        }
                    }

                    // VPN Profiles List
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: "#88080c14"
                        border.width: 1; border.color: "#2a3b5c"
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            visible: SageState.vpnList.length === 0
                            text: "No VPN profile found in NetworkManager.\nClick 'Open Network Manager' below to import WireGuard/OpenVPN."
                            horizontalAlignment: Text.AlignHCenter
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            color: SageState.textMuted
                        }

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6
                            model: SageState.vpnList

                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 36; radius: 4
                                color: modelData.active ? SageState.bgCardHover : SageState.bgCard
                                border.width: 1
                                border.color: modelData.active ? SageState.emeraldOk : "#2a3b5c"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10; anchors.rightMargin: 10

                                    Text {
                                        Layout.fillWidth: true
                                        text: "🛡️ " + modelData.name + " [" + modelData.type + "]"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11; font.bold: true
                                        color: modelData.active ? SageState.emeraldOk : SageState.textPrimary
                                    }

                                    Rectangle {
                                        width: 86; height: 24; radius: 4
                                        color: modelData.active ? SageState.emeraldOk : SageState.primaryAccent
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.active ? "DISCONNECT" : "CONNECT"
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10; font.bold: true
                                            color: "#080c14"
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd([SageState.ctlScript, "vpn-toggle", modelData.name, modelData.type])
                                }
                            }
                        }
                    }

                    // Open Advanced Network Editor Button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 34; radius: 4
                        color: SageState.bgCard
                        border.width: 1; border.color: SageState.primaryAccent
                        Text {
                            anchors.centerIn: parent
                            text: "⚙ Open Advanced Network & VPN Editor (nm-connection-editor)"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11; font.bold: true
                            color: SageState.primaryAccent
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch("exec nm-connection-editor")
                        }
                    }
                }

                // ══════════════════════════════════════════════════════════════
                //  TAB 2: AUDIO, DISPLAY BRIGHTNESS, BLUETOOTH & POWER PROFILE
                // ══════════════════════════════════════════════════════════════
                ColumnLayout {
                    visible: SageState.activeTab === 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 14

                    // Volume Slider Card
                    Rectangle {
                        Layout.fillWidth: true
                        height: 82; radius: 6
                        color: SageState.bgCard
                        border.width: 1; border.color: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: (SageState.muted ? "🔇 AUDIO MUTED" : ("🔊 MASTER VOLUME: " + SageState.volume + "%"))
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12; font.bold: true
                                    color: SageState.muted ? SageState.crimsonAlert : SageState.primaryAccent
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    width: 60; height: 22; radius: 4
                                    color: SageState.bgCardHover
                                    Text {
                                        anchors.centerIn: parent
                                        text: SageState.muted ? "Unmute" : "Mute"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        color: SageState.secondaryAccent
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: SageState.runCmd([SageState.ctlScript, "toggle-mute"])
                                    }
                                }
                                Rectangle {
                                    width: 64; height: 22; radius: 4
                                    color: SageState.bgCardHover
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Mixer"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        color: SageState.primaryAccent
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Hyprland.dispatch("exec pavucontrol")
                                    }
                                }
                            }

                            // Interactive Volume Bar
                            Rectangle {
                                id: volTrack
                                Layout.fillWidth: true
                                height: 14; radius: 4
                                color: "#080c14"
                                border.width: 1; border.color: "#2a3b5c"

                                Rectangle {
                                    width: Math.min(parent.width, parent.width * (SageState.volume / 100.0))
                                    height: parent.height; radius: 4
                                    color: SageState.muted ? SageState.crimsonAlert : SageState.primaryAccent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: mouse => {
                                        const pct = Math.max(0, Math.min(100, Math.round((mouse.x / volTrack.width) * 100)));
                                        SageState.volume = pct;
                                        SageState.runCmd([SageState.ctlScript, "set-volume", pct.toString()]);
                                    }
                                }
                            }
                        }
                    }

                    // Brightness Slider Card
                    Rectangle {
                        Layout.fillWidth: true
                        height: 76; radius: 6
                        color: SageState.bgCard
                        border.width: 1; border.color: SageState.secondaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "☀️ DISPLAY LUMINANCE: " + SageState.brightness + "%"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12; font.bold: true
                                color: SageState.secondaryAccent
                            }

                            Rectangle {
                                id: brightTrack
                                Layout.fillWidth: true
                                height: 14; radius: 4
                                color: "#080c14"
                                border.width: 1; border.color: "#2a3b5c"

                                Rectangle {
                                    width: Math.min(parent.width, parent.width * (SageState.brightness / 100.0))
                                    height: parent.height; radius: 4
                                    color: SageState.secondaryAccent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: mouse => {
                                        const pct = Math.max(5, Math.min(100, Math.round((mouse.x / brightTrack.width) * 100)));
                                        SageState.brightness = pct;
                                        SageState.runCmd([SageState.ctlScript, "set-brightness", pct.toString()]);
                                    }
                                }
                            }
                        }
                    }

                    // Bluetooth Card
                    Rectangle {
                        Layout.fillWidth: true
                        height: 54; radius: 6
                        color: SageState.bgCard
                        border.width: 1; border.color: SageState.btEnabled ? SageState.primaryAccent : "#2a3b5c"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "◈ BLUETOOTH: " + (SageState.btEnabled ? "ENABLED" : "DISABLED")
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12; font.bold: true
                                    color: SageState.btEnabled ? SageState.primaryAccent : SageState.textMuted
                                }
                                Text {
                                    text: "Device: " + SageState.btDevice
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    color: SageState.textMuted
                                }
                            }

                            Rectangle {
                                width: 70; height: 28; radius: 4
                                color: SageState.bgCardHover
                                Text {
                                    anchors.centerIn: parent
                                    text: "Blueman"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    color: SageState.secondaryAccent
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Hyprland.dispatch("exec blueman-manager")
                                }
                            }

                            Rectangle {
                                width: 60; height: 28; radius: 4
                                color: SageState.btEnabled ? SageState.primaryAccent : "#2a3b5c"
                                Text {
                                    anchors.centerIn: parent
                                    text: SageState.btEnabled ? "ON" : "OFF"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11; font.bold: true
                                    color: SageState.btEnabled ? "#080c14" : SageState.textPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd([SageState.ctlScript, "bt-toggle"])
                                }
                            }
                        }
                    }

                    // Power Profile Selector
                    Text {
                        text: "◈ MAGICULE POWER PROFILE"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12; font.bold: true
                        color: SageState.secondaryAccent
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: [
                                { id: "power-saver", label: "🍃 Power Saver" },
                                { id: "balanced",    label: "⚖ Balanced" },
                                { id: "performance", label: "⚡ Performance" }
                            ]

                            Rectangle {
                                required property var modelData
                                readonly property bool active: SageState.powerProfile === modelData.id
                                Layout.fillWidth: true
                                height: 36; radius: 4
                                color: active ? SageState.primaryAccent : SageState.bgCard
                                border.width: 1
                                border.color: active ? SageState.secondaryAccent : "#2a3b5c"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11; font.bold: active
                                    color: active ? "#080c14" : SageState.textPrimary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SageState.powerProfile = modelData.id;
                                        SageState.runCmd([SageState.ctlScript, "set-power", modelData.id]);
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }

                // ══════════════════════════════════════════════════════════════
                //  TAB 3: SYSTEM TELEMETRY & SESSION CONTROLS
                // ══════════════════════════════════════════════════════════════
                ColumnLayout {
                    visible: SageState.activeTab === 3
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    Text {
                        text: "◈ HOST TELEMETRY DIAGNOSTICS"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12; font.bold: true
                        color: SageState.secondaryAccent
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 110; radius: 6
                        color: SageState.bgCard
                        border.width: 1; border.color: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "◈ CPU Load: " + SageState.cpuUsage + "%"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12; color: SageState.textPrimary
                            }
                            Text {
                                text: "◈ Memory Used: " + SageState.ramUsage + "% (" + SageState.ramText + ")"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12; color: SageState.textPrimary
                            }
                            Text {
                                text: "◈ Battery Core: " + SageState.batPercent + "% (" + SageState.batStatus + ")"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12; color: SageState.emeraldOk
                            }
                        }
                    }

                    // Quick Keybinds Guide Button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40; radius: 6
                        color: SageState.bgCardHover
                        border.width: 1; border.color: SageState.secondaryAccent

                        Text {
                            anchors.centerIn: parent
                            text: "? Open Keybinds Cheat Sheet (Super + H)"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12; font.bold: true
                            color: SageState.secondaryAccent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SageState.controlCenterOpen = false;
                                SageState.keybindsOpen = true;
                            }
                        }
                    }

                    Text {
                        text: "◈ SESSION & POWER COMMANDS"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12; font.bold: true
                        color: SageState.secondaryAccent
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8

                        Repeater {
                            model: [
                                { label: "🔒 Lock Screen",     cmd: "hyprlock",                col: "#00e5ff" },
                                { label: "↻ Reload Hyprland", cmd: "hyprctl reload",          col: "#ffd54f" },
                                { label: "🚪 Log Out",         cmd: "hyprctl dispatch exit",   col: "#b388ff" },
                                { label: "⚡ Reboot System",   cmd: "systemctl reboot",        col: "#ff5252" },
                                { label: "⏻ Power Off",       cmd: "systemctl poweroff",      col: "#ff5252" }
                            ]

                            Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                height: 38; radius: 4
                                color: SageState.bgCard
                                border.width: 1; border.color: modelData.col

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11; font.bold: true
                                    color: modelData.col
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Hyprland.dispatch("exec " + modelData.cmd)
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}

