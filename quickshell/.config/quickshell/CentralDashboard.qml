
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: dashWindow
        required property var modelData
        screen: modelData

        visible: SageState.dashboardOpen
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: SageState.dashboardOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        // Dimmed backdrop — click outside to close
        Rectangle {
            anchors.fill: parent
            color: "#8803060c"

            MouseArea {
                anchors.fill: parent
                onClicked: SageState.dashboardOpen = false
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // CENTRAL GREAT SAGE / CAELESTIA DASHBOARD (1080 x 650 Centered)
        // ═══════════════════════════════════════════════════════════════════════
        SageFrame {
            id: mainDialog
            width: 1080
            height: 650
            anchors.centerIn: parent
            chamfer: 18
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerColor: SageState.secondaryAccent
            borderWidth: 2.0
            innerBorder: true
            innerAlpha: 0.45
            cornerDiamonds: true
            showMagicCircle: true
            magicCircleAlpha: 0.065

            // Prevent click-through inside dialog
            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // ─── TOP HEADER BAR + NAVIGATION TABS ────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    // Great Sage System Title Box
                    Column {
                        spacing: 2
                        Text {
                            text: "◈ « REPORT: GREAT SAGE CENTRAL NEXUS // RAPHAEL OS »"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1.4
                        }
                        Text {
                            text: "TENSEI SHITARA SLIME DATTA KEN  •  CAELESTIA + END-4 HYBRID SHELL"
                            color: SageState.primaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1.0
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // 5 Navigation Tabs
                    Row {
                        spacing: 6

                        Repeater {
                            model: [
                                { idx: 0, label: "01 // DASHBOARD" },
                                { idx: 1, label: "02 // SPECIAL WS" },
                                { idx: 2, label: "03 // WALLPAPER & THEME" },
                                { idx: 3, label: "04 // NETWORK & VPN" },
                                { idx: 4, label: "05 // KEYBINDS" }
                            ]

                            SageFrame {
                                id: navTab
                                required property var modelData
                                readonly property bool isActive: SageState.activeTab === modelData.idx

                                width: navTabText.implicitWidth + 24
                                height: 34
                                chamfer: 7
                                fillColor: isActive
                                           ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.24)
                                           : SageState.bgCard
                                borderColor: isActive ? SageState.secondaryAccent : SageState.primaryAccent
                                innerBorder: isActive

                                Text {
                                    id: navTabText
                                    anchors.centerIn: parent
                                    text: navTab.modelData.label
                                    color: navTab.isActive ? SageState.secondaryAccent : SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SageState.activeTab = navTab.modelData.idx;
                                        if (navTab.modelData.idx === 1) SageState.loadSpecialWorkspaces();
                                        if (navTab.modelData.idx === 2) SageState.loadWallpapers();
                                        if (navTab.modelData.idx === 3) SageState.scanWifi();
                                    }
                                }
                            }
                        }
                    }

                    // Close Button [ ✕ ]
                    SageFrame {
                        width: 34
                        height: 34
                        chamfer: 7
                        fillColor: SageState.bgCard
                        borderColor: SageState.crimsonAlert
                        innerBorder: false

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: SageState.crimsonAlert
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SageState.dashboardOpen = false
                        }
                    }
                }

                // Decorative Gold/Cyan Separator Line
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.45)
                }

                // ═══════════════════════════════════════════════════════════════
                // TAB 0: OVERVIEW DASHBOARD (Caelestia Left + end-4 Right)
                // ═══════════════════════════════════════════════════════════════
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: SageState.activeTab === 0
                    spacing: 18

                    // LEFT COLUMN: Rimuru Tempest Profile + Quick Special Workspaces
                    ColumnLayout {
                        Layout.preferredWidth: 440
                        Layout.fillHeight: true
                        spacing: 14

                        // Rimuru Tempest / Great Sage Profile Card
                        SageFrame {
                            Layout.fillWidth: true
                            height: 195
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.secondaryAccent
                            innerBorder: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 18

                                // Rimuru Slime Avatar inside Octagonal Frame
                                Rectangle {
                                    width: 126
                                    height: 126
                                    radius: 10
                                    color: SageState.bgVoid
                                    border.width: 2
                                    border.color: SageState.primaryAccent
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        source: "file://" + SageState.rimuruAvatar
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: "◈ ULTIMATE SKILL: RAPHAEL"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                        font.letterSpacing: 1
                                    }

                                    Text {
                                        text: "RIMURU TEMPEST"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 20
                                        font.bold: true
                                    }

                                    Text {
                                        text: "Jura Tempest Federation • Chancellor"
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 1
                                        color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.3)
                                    }

                                    Text {
                                        text: "TIME   // " + SageState.clockTime + " (" + SageState.clockDate + ")"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        text: "SKILL  // " + SageState.themeName.toUpperCase() + "  |  KB: " + SageState.kbLayout.toUpperCase()
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // Special Workspaces Summon Matrix (Caelestia Quick Cards)
                        SageFrame {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.primaryAccent
                            innerBorder: true

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 10

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "◈ CAELESTIA SPECIAL WORKSPACES"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: "CONFIGURE ▸"
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.activeTab = 1
                                        }
                                    }
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    columns: 2
                                    rowSpacing: 10
                                    columnSpacing: 10

                                    Repeater {
                                        model: SageState.specialWorkspaces

                                        Rectangle {
                                            id: dashSpecCard
                                            required property var modelData
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            radius: 6
                                            color: dashSpecMouse.containsMouse ? SageState.bgCardHover : SageState.bgSurface
                                            border.width: 1.5
                                            border.color: modelData.running ? SageState.secondaryAccent : SageState.primaryAccent

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 4

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    Text {
                                                        text: "◈ " + dashSpecCard.modelData.label
                                                        color: SageState.textPrimary
                                                        font.family: "JetBrainsMono Nerd Font"
                                                        font.pixelSize: 13
                                                        font.bold: true
                                                    }
                                                    Item { Layout.fillWidth: true }
                                                    Rectangle {
                                                        width: 8
                                                        height: 8
                                                        radius: 4
                                                        color: dashSpecCard.modelData.running ? SageState.emeraldOk : SageState.textMuted
                                                    }
                                                }

                                                Text {
                                                    text: "KEYBIND: " + dashSpecCard.modelData.bind
                                                    color: SageState.secondaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: "CMD: " + dashSpecCard.modelData.cmd
                                                    color: SageState.textMuted
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            MouseArea {
                                                id: dashSpecMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    SageState.dashboardOpen = false;
                                                    SageState.toggleSpecialWs(dashSpecCard.modelData.id);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // RIGHT COLUMN: end-4 Style Bento Quick Toggles + Sliders + Telemetry
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 14

                        // 3 Telemetry Stat Boxes
                        RowLayout {
                            Layout.fillWidth: true
                            height: 86
                            spacing: 12

                            SageFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                chamfer: 10
                                fillColor: SageState.bgCard
                                borderColor: SageState.primaryAccent

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "CPU COMPUTE"
                                        color: SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.cpuUsage + "%"
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 24
                                        font.bold: true
                                    }
                                }
                            }

                            SageFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                chamfer: 10
                                fillColor: SageState.bgCard
                                borderColor: SageState.secondaryAccent

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "MEMORY (" + SageState.ramText + ")"
                                        color: SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.ramUsage + "%"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 24
                                        font.bold: true
                                    }
                                }
                            }

                            SageFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                chamfer: 10
                                fillColor: SageState.bgCard
                                borderColor: SageState.emeraldOk

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "MAGICULE CELL (" + SageState.batStatus.toUpperCase() + ")"
                                        color: SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.batPercent + "%"
                                        color: SageState.emeraldOk
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 24
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // end-4 Style 2x2 Bento Quick Toggle Cards
                        GridLayout {
                            Layout.fillWidth: true
                            height: 155
                            columns: 2
                            rowSpacing: 10
                            columnSpacing: 10

                            // 1. Wi-Fi Card
                            SageFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                chamfer: 10
                                fillColor: SageState.wifiEnabled
                                           ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                           : SageState.bgCard
                                borderColor: SageState.wifiEnabled ? SageState.primaryAccent : SageState.textMuted

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    Text {
                                        text: "◈ WIRELESS MATRIX (WI-FI)"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: SageState.wifiEnabled ? ("ONLINE // " + SageState.wifiSsid) : "OFFLINE"
                                        color: SageState.wifiEnabled ? SageState.primaryAccent : SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: function(mouse) {
                                        if (mouse.button === Qt.RightButton) {
                                            SageState.openDashboardTab(3);
                                        } else {
                                            SageState.runCmd([SageState.ctlScript, "wifi-toggle"]);
                                        }
                                    }
                                }
                            }

                            // 2. VPN Shield Card
                            SageFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                chamfer: 10
                                fillColor: SageState.vpnActive
                                           ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.2)
                                           : SageState.bgCard
                                borderColor: SageState.vpnActive ? SageState.emeraldOk : SageState.textMuted

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    Text {
                                        text: "◈ BARRIER TUNNEL (VPN)"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: SageState.vpnActive ? ("ACTIVE // " + SageState.vpnName) : "CLICK TO CONFIGURE VPN"
                                        color: SageState.vpnActive ? SageState.emeraldOk : SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.openDashboardTab(3)
                                }
                            }

                            // 3. Bluetooth Card
                            SageFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                chamfer: 10
                                fillColor: SageState.btEnabled
                                           ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                           : SageState.bgCard
                                borderColor: SageState.btEnabled ? SageState.primaryAccent : SageState.textMuted

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    Text {
                                        text: "◈ TELEPATHY LINK (BLUETOOTH)"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: SageState.btEnabled ? ("ENABLED // " + SageState.btDevice) : "DISABLED"
                                        color: SageState.btEnabled ? SageState.primaryAccent : SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd([SageState.ctlScript, "bt-toggle"])
                                }
                            }

                            // 4. Magicule Border Flow Animation Card
                            SageFrame {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                chamfer: 10
                                fillColor: SageState.borderFlow
                                           ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.22)
                                           : SageState.bgCard
                                borderColor: SageState.borderFlow ? SageState.secondaryAccent : SageState.textMuted

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    Text {
                                        text: "◈ MAGICULE BORDER ROTATION"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        text: SageState.borderFlow ? "ANIMATED AURA // ON" : "STATIC AURA // OFF (ECO)"
                                        color: SageState.borderFlow ? SageState.secondaryAccent : SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const next = !SageState.borderFlow;
                                        SageState.borderFlow = next;
                                        SageState.runCmd([SageState.ctlScript, "set-flow", next ? "on" : "off"]);
                                    }
                                }
                            }
                        }

                        // Audio & Luminance Sliders Card
                        SageFrame {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.primaryAccent

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12

                                // Volume Slider
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: SageState.muted ? "◈ ACOUSTIC OUTPUT [MUTED]" : "◈ ACOUSTIC OUTPUT (VOLUME)"
                                            color: SageState.muted ? SageState.crimsonAlert : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: SageState.volume + "%"
                                            color: SageState.primaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Rectangle {
                                        id: dashVolBar
                                        Layout.fillWidth: true
                                        height: 16
                                        radius: 4
                                        color: SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.primaryAccent

                                        Rectangle {
                                            width: parent.width * (Math.max(0, Math.min(100, SageState.volume)) / 100.0)
                                            height: parent.height
                                            radius: 4
                                            color: SageState.primaryAccent
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: function(mouse) {
                                                const pct = Math.round(Math.max(0, Math.min(100, (mouse.x / dashVolBar.width) * 100)));
                                                SageState.volume = pct;
                                                SageState.runCmd([SageState.ctlScript, "vol-set", pct.toString()]);
                                            }
                                        }
                                    }
                                }

                                // Brightness Slider
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: "◈ OPTICAL LUMINANCE (BRIGHTNESS)"
                                            color: SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: SageState.brightness + "%"
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Rectangle {
                                        id: dashBrightBar
                                        Layout.fillWidth: true
                                        height: 16
                                        radius: 4
                                        color: SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.secondaryAccent

                                        Rectangle {
                                            width: parent.width * (Math.max(5, Math.min(100, SageState.brightness)) / 100.0)
                                            height: parent.height
                                            radius: 4
                                            color: SageState.secondaryAccent
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: function(mouse) {
                                                const pct = Math.round(Math.max(5, Math.min(100, (mouse.x / dashBrightBar.width) * 100)));
                                                SageState.brightness = pct;
                                                SageState.runCmd([SageState.ctlScript, "bright-set", pct.toString()]);
                                            }
                                        }
                                    }
                                }

                                // Power Profile Row
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Repeater {
                                        model: [
                                            { id: "power-saver", label: "ECO SAVER" },
                                            { id: "balanced", label: "BALANCED" },
                                            { id: "performance", label: "OVERDRIVE" }
                                        ]

                                        Rectangle {
                                            id: dashPwrBtn
                                            required property var modelData
                                            readonly property bool isAct: SageState.powerProfile === modelData.id

                                            Layout.fillWidth: true
                                            height: 30
                                            radius: 4
                                            color: isAct
                                                   ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.24)
                                                   : SageState.bgVoid
                                            border.width: 1
                                            border.color: isAct ? SageState.secondaryAccent : SageState.primaryAccent

                                            Text {
                                                anchors.centerIn: parent
                                                text: dashPwrBtn.modelData.label
                                                color: dashPwrBtn.isAct ? SageState.secondaryAccent : SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    SageState.powerProfile = dashPwrBtn.modelData.id;
                                                    SageState.runCmd([SageState.ctlScript, "set-power", dashPwrBtn.modelData.id]);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // TAB 1: CAELESTIA SPECIAL WORKSPACES MANAGER
                // ═══════════════════════════════════════════════════════════════
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: SageState.activeTab === 1
                    spacing: 14

                    Text {
                        text: "◈ CAELESTIA SPECIAL WORKSPACES // LIVE APPLICATION & KEYBIND EDITOR"
                        color: SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    // Existing Special Workspaces List
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: specListCol.implicitHeight
                        clip: true

                        ColumnLayout {
                            id: specListCol
                            width: parent.width
                            spacing: 10

                            Repeater {
                                model: SageState.specialWorkspaces

                                SageFrame {
                                    id: wsEditorRow
                                    required property var modelData

                                    Layout.fillWidth: true
                                    height: 68
                                    chamfer: 10
                                    fillColor: SageState.bgCard
                                    borderColor: modelData.running ? SageState.secondaryAccent : SageState.primaryAccent

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 12

                                        // Short Badge
                                        Rectangle {
                                            width: 56
                                            height: 38
                                            radius: 5
                                            color: SageState.bgVoid
                                            border.width: 1
                                            border.color: wsEditorRow.modelData.running ? SageState.secondaryAccent : SageState.primaryAccent

                                            Text {
                                                anchors.centerIn: parent
                                                text: wsEditorRow.modelData.short !== undefined ? wsEditorRow.modelData.short : "SPC"
                                                color: wsEditorRow.modelData.running ? SageState.secondaryAccent : SageState.primaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                        }

                                        // Label + Status
                                        Column {
                                            Layout.preferredWidth: 130
                                            spacing: 2
                                            Text {
                                                text: wsEditorRow.modelData.label
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 13
                                                font.bold: true
                                            }
                                            Text {
                                                text: wsEditorRow.modelData.running ? "● RUNNING" : "○ STANDBY"
                                                color: wsEditorRow.modelData.running ? SageState.emeraldOk : SageState.textMuted
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }
                                        }

                                        // Editable Keybind Input
                                        Rectangle {
                                            Layout.preferredWidth: 185
                                            height: 36
                                            radius: 4
                                            color: SageState.bgVoid
                                            border.width: 1
                                            border.color: SageState.secondaryAccent

                                            TextField {
                                                id: bindEditInput
                                                anchors.fill: parent
                                                anchors.leftMargin: 8
                                                anchors.rightMargin: 8
                                                verticalAlignment: TextInput.AlignVCenter
                                                text: wsEditorRow.modelData.bind
                                                color: SageState.secondaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 11
                                                font.bold: true
                                                background: Item {}
                                            }
                                        }

                                        // Editable Command Input
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 36
                                            radius: 4
                                            color: SageState.bgVoid
                                            border.width: 1
                                            border.color: SageState.primaryAccent

                                            TextField {
                                                id: cmdEditInput
                                                anchors.fill: parent
                                                anchors.leftMargin: 8
                                                anchors.rightMargin: 8
                                                verticalAlignment: TextInput.AlignVCenter
                                                text: wsEditorRow.modelData.cmd
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 11
                                                background: Item {}
                                            }
                                        }

                                        // [ OPEN / TOGGLE ] Button
                                        Rectangle {
                                            width: 82
                                            height: 36
                                            radius: 4
                                            color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                            border.width: 1
                                            border.color: SageState.primaryAccent

                                            Text {
                                                anchors.centerIn: parent
                                                text: "SUMMON"
                                                color: SageState.primaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    SageState.dashboardOpen = false;
                                                    SageState.toggleSpecialWs(wsEditorRow.modelData.id);
                                                }
                                            }
                                        }

                                        // [ SAVE ] Button
                                        Rectangle {
                                            width: 72
                                            height: 36
                                            radius: 4
                                            color: Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.2)
                                            border.width: 1
                                            border.color: SageState.emeraldOk

                                            Text {
                                                anchors.centerIn: parent
                                                text: "SAVE"
                                                color: SageState.emeraldOk
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: SageState.updateSpecialWs(wsEditorRow.modelData.id, bindEditInput.text, cmdEditInput.text)
                                            }
                                        }

                                        // [ DELETE ] Button
                                        Rectangle {
                                            width: 40
                                            height: 36
                                            radius: 4
                                            color: SageState.bgVoid
                                            border.width: 1
                                            border.color: SageState.crimsonAlert

                                            Text {
                                                anchors.centerIn: parent
                                                text: "✕"
                                                color: SageState.crimsonAlert
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 12
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: SageState.deleteSpecialWs(wsEditorRow.modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Create New Special Workspace Bar
                    SageFrame {
                        Layout.fillWidth: true
                        height: 76
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            Text {
                                text: "◈ NEW:"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Rectangle {
                                Layout.preferredWidth: 130
                                height: 36
                                radius: 4
                                color: SageState.bgVoid
                                border.width: 1
                                border.color: SageState.primaryAccent
                                TextField {
                                    id: newWsName
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    placeholderText: "Label (e.g. NOTES)"
                                    placeholderTextColor: SageState.textMuted
                                    color: SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    background: Item {}
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 85
                                height: 36
                                radius: 4
                                color: SageState.bgVoid
                                border.width: 1
                                border.color: SageState.primaryAccent
                                TextField {
                                    id: newWsShort
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    placeholderText: "Code (NTE)"
                                    placeholderTextColor: SageState.textMuted
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    background: Item {}
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 165
                                height: 36
                                radius: 4
                                color: SageState.bgVoid
                                border.width: 1
                                border.color: SageState.secondaryAccent
                                TextField {
                                    id: newWsBind
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    placeholderText: "SUPER + N"
                                    placeholderTextColor: SageState.textMuted
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    background: Item {}
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 36
                                radius: 4
                                color: SageState.bgVoid
                                border.width: 1
                                border.color: SageState.primaryAccent
                                TextField {
                                    id: newWsCmd
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    placeholderText: "App command (e.g. obsidian)"
                                    placeholderTextColor: SageState.textMuted
                                    color: SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    background: Item {}
                                }
                            }

                            Rectangle {
                                width: 120
                                height: 36
                                radius: 4
                                color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.25)
                                border.width: 1
                                border.color: SageState.secondaryAccent

                                Text {
                                    anchors.centerIn: parent
                                    text: "+ ADD WORKSPACE"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (newWsName.text.trim().length > 0 && newWsBind.text.trim().length > 0 && newWsCmd.text.trim().length > 0) {
                                            const sc = newWsShort.text.trim().length > 0 ? newWsShort.text.trim() : newWsName.text.trim().substring(0, 3).toUpperCase();
                                            SageState.addSpecialWs(newWsName.text.trim(), sc, newWsBind.text.trim(), newWsCmd.text.trim());
                                            newWsName.text = "";
                                            newWsShort.text = "";
                                            newWsBind.text = "";
                                            newWsCmd.text = "";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // TAB 2: WALLPAPERS & ULTIMATE SKILL THEMES (end-4 Customizer)
                // ═══════════════════════════════════════════════════════════════
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: SageState.activeTab === 2
                    spacing: 18

                    // LEFT: Visual Wallpaper Grid
                    SageFrame {
                        Layout.preferredWidth: 600
                        Layout.fillHeight: true
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "◈ HOLOGRAPHIC WALLPAPER ENGINE (SWWW)"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Item { Layout.fillWidth: true }

                                // Transition Selector Pills
                                Row {
                                    spacing: 4
                                    Repeater {
                                        model: ["wave", "outer", "grow", "wipe"]
                                        Rectangle {
                                            id: trPill
                                            required property string modelData
                                            width: 52
                                            height: 22
                                            radius: 3
                                            color: SageState.transitionType === modelData ? SageState.primaryAccent : SageState.bgVoid
                                            border.width: 1
                                            border.color: SageState.primaryAccent
                                            Text {
                                                anchors.centerIn: parent
                                                text: trPill.modelData.toUpperCase()
                                                color: SageState.transitionType === trPill.modelData ? "#050911" : SageState.primaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: SageState.transitionType = trPill.modelData
                                            }
                                        }
                                    }
                                }
                            }

                            GridView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                cellWidth: 278
                                cellHeight: 152
                                clip: true
                                model: SageState.wallpapers

                                delegate: Item {
                                    id: wallDelegate
                                    required property var modelData
                                    width: 278
                                    height: 152

                                    readonly property bool isCurrent: SageState.currentWallpaper === modelData.path

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        radius: 8
                                        color: SageState.bgVoid
                                        border.width: wallDelegate.isCurrent ? 2.5 : 1
                                        border.color: wallDelegate.isCurrent ? SageState.secondaryAccent : SageState.primaryAccent
                                        clip: true

                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 3
                                            source: "file://" + wallDelegate.modelData.path
                                            sourceSize.width: 360
                                            sourceSize.height: 202
                                            fillMode: Image.PreserveAspectCrop
                                        }

                                        Rectangle {
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                bottom: parent.bottom
                                            }
                                            height: 28
                                            color: "#cc060b14"

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 10
                                                anchors.rightMargin: 10
                                                Text {
                                                    text: wallDelegate.modelData.name.toUpperCase()
                                                    color: wallDelegate.isCurrent ? SageState.secondaryAccent : SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }
                                                Item { Layout.fillWidth: true }
                                                Text {
                                                    text: wallDelegate.isCurrent ? "ACTIVE" : "APPLY ▸"
                                                    color: wallDelegate.isCurrent ? SageState.emeraldOk : SageState.primaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.setWallpaper(wallDelegate.modelData.path)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // RIGHT: Ultimate Skill Themes + Opacity + Keyboard Layout
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12

                        SageFrame {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.secondaryAccent

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 10

                                Text {
                                    text: "◈ ULTIMATE SKILL COLOR SCHEMES"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Repeater {
                                    model: [
                                        { id: "great_sage", title: "GREAT SAGE // RAPHAEL GOLD", desc: "Cyan Magicule + Golden Seal Accents", c1: "#00e5ff", c2: "#ffd54f" },
                                        { id: "magicule", title: "RIMURU // PURE MAGICULE ICE", desc: "Luminous Cyan + Glacial Ice Blue", c1: "#00e5ff", c2: "#84ffff" },
                                        { id: "beelzebub", title: "BEELZEBUB // GLUTTONY ABYSS", desc: "Void Violet + Cyan Aura Borders", c1: "#b388ff", c2: "#00e5ff" },
                                        { id: "hellflare", title: "BENIMARU // CRIMSON HELLFLARE", desc: "Demon Lord Crimson + Gold Flame", c1: "#ff5252", c2: "#ffd54f" }
                                    ]

                                    Rectangle {
                                        id: themeCard
                                        required property var modelData
                                        readonly property bool active: SageState.themeName === modelData.id

                                        Layout.fillWidth: true
                                        height: 58
                                        radius: 6
                                        color: active
                                               ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.22)
                                               : SageState.bgVoid
                                        border.width: active ? 2 : 1
                                        border.color: active ? SageState.secondaryAccent : SageState.primaryAccent

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 12

                                            Row {
                                                spacing: 4
                                                Rectangle { width: 16; height: 28; radius: 3; color: themeCard.modelData.c1 }
                                                Rectangle { width: 16; height: 28; radius: 3; color: themeCard.modelData.c2 }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2
                                                Text {
                                                    text: themeCard.modelData.title
                                                    color: SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                }
                                                Text {
                                                    text: themeCard.modelData.desc
                                                    color: SageState.textMuted
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                }
                                            }

                                            Text {
                                                text: themeCard.active ? "ACTIVE" : "ENGAGE"
                                                color: themeCard.active ? SageState.secondaryAccent : SageState.primaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                SageState.themeName = themeCard.modelData.id;
                                                SageState.runCmd([SageState.ctlScript, "set-theme", themeCard.modelData.id]);
                                            }
                                        }
                                    }
                                }

                                // Window Opacity & Keyboard Layout Row
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 36
                                        radius: 4
                                        color: SageState.holographicOpacity
                                               ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: SageState.holographicOpacity ? "GLASS BLUR: HOLOGRAPHIC" : "GLASS BLUR: OPAQUE"
                                            color: SageState.primaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
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

                                // Keyboard Layouts
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: "KEYBOARD:"
                                        color: SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Repeater {
                                        model: ["fr", "us", "fr,us", "be", "ch"]
                                        Rectangle {
                                            id: kbChoice
                                            required property string modelData
                                            Layout.fillWidth: true
                                            height: 30
                                            radius: 4
                                            color: SageState.kbLayout === modelData ? SageState.secondaryAccent : SageState.bgVoid
                                            border.width: 1
                                            border.color: SageState.secondaryAccent

                                            Text {
                                                anchors.centerIn: parent
                                                text: kbChoice.modelData.toUpperCase()
                                                color: SageState.kbLayout === kbChoice.modelData ? "#050911" : SageState.secondaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    SageState.kbLayout = kbChoice.modelData;
                                                    SageState.runCmd([SageState.ctlScript, "set-kb", kbChoice.modelData]);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // TAB 3: NETWORK & VPN MATRIX
                // ═══════════════════════════════════════════════════════════════
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: SageState.activeTab === 3
                    spacing: 18

                    // LEFT: Wi-Fi Access Points
                    SageFrame {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "◈ WIRELESS ACCESS POINTS (NMCLI)"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Item { Layout.fillWidth: true }

                                Rectangle {
                                    width: 110
                                    height: 28
                                    radius: 4
                                    color: SageState.bgVoid
                                    border.width: 1
                                    border.color: SageState.primaryAccent

                                    Text {
                                        anchors.centerIn: parent
                                        text: SageState.wifiScanning ? "SCANNING..." : "SCAN WI-FI"
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: SageState.scanWifi()
                                    }
                                }
                            }

                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentHeight: wifiListCol.implicitHeight
                                clip: true

                                ColumnLayout {
                                    id: wifiListCol
                                    width: parent.width
                                    spacing: 6

                                    Repeater {
                                        model: SageState.wifiNetworks

                                        Rectangle {
                                            id: wifiRow
                                            required property var modelData
                                            Layout.fillWidth: true
                                            height: 44
                                            radius: 5
                                            color: modelData.inUse
                                                   ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.18)
                                                   : SageState.bgVoid
                                            border.width: 1
                                            border.color: modelData.inUse ? SageState.emeraldOk : SageState.primaryAccent

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 12
                                                anchors.rightMargin: 12
                                                spacing: 10

                                                Text {
                                                    text: wifiRow.modelData.signal + "%"
                                                    color: SageState.secondaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: wifiRow.modelData.ssid
                                                    color: SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    text: wifiRow.modelData.inUse ? "CONNECTED" : "CONNECT ▸"
                                                    color: wifiRow.modelData.inUse ? SageState.emeraldOk : SageState.primaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: SageState.runCmd([SageState.ctlScript, "wifi-connect", wifiRow.modelData.ssid])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // RIGHT: VPN Tunnels & Network Tools
                    SageFrame {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "◈ BARRIER TUNNELS (WIREGUARD / VPN)"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Item { Layout.fillWidth: true }

                                Rectangle {
                                    width: 140
                                    height: 28
                                    radius: 4
                                    color: SageState.bgVoid
                                    border.width: 1
                                    border.color: SageState.secondaryAccent

                                    Text {
                                        anchors.centerIn: parent
                                        text: "NM CONNECTION GUI"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: SageState.launchApp("nm-connection-editor")
                                    }
                                }
                            }

                            Text {
                                visible: SageState.vpnList.length === 0
                                text: "No VPN / WireGuard profiles configured in NetworkManager.\nClick 'NM CONNECTION GUI' above to import a WireGuard or OpenVPN profile."
                                color: SageState.textMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentHeight: vpnListCol.implicitHeight
                                clip: true

                                ColumnLayout {
                                    id: vpnListCol
                                    width: parent.width
                                    spacing: 8

                                    Repeater {
                                        model: SageState.vpnList

                                        Rectangle {
                                            id: vpnRow
                                            required property var modelData
                                            Layout.fillWidth: true
                                            height: 48
                                            radius: 5
                                            color: modelData.active
                                                   ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.18)
                                                   : SageState.bgVoid
                                            border.width: 1
                                            border.color: modelData.active ? SageState.emeraldOk : SageState.secondaryAccent

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 14
                                                anchors.rightMargin: 14

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: vpnRow.modelData.name
                                                    color: SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                }

                                                Text {
                                                    text: vpnRow.modelData.active ? "ACTIVE (DISCONNECT)" : "ACTIVATE TUNNEL ▸"
                                                    color: vpnRow.modelData.active ? SageState.emeraldOk : SageState.secondaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: SageState.runCmd([SageState.ctlScript, "vpn-toggle", vpnRow.modelData.name])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // TAB 4: KEYBINDS MATRIX (4-Column Great Sage Cheat Sheet)
                // ═══════════════════════════════════════════════════════════════
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: SageState.activeTab === 4
                    columns: 4
                    rowSpacing: 12
                    columnSpacing: 12

                    // Column 1: Core & Menus
                    SageFrame {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "◈ 01 // MENUS & APPS"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: [
                                    { k: "Super + Q", d: "Kitty Terminal" },
                                    { k: "Super + R / Space", d: "Bottom App Launcher" },
                                    { k: "Super + Shift + G", d: "Central Dashboard" },
                                    { k: "Super + H / F1", d: "Keybinds Matrix" },
                                    { k: "Super + W", d: "Wallpaper Studio" },
                                    { k: "Super + Shift + W", d: "Next Wallpaper" },
                                    { k: "Super + E", d: "File Manager" },
                                    { k: "Super + C", d: "Close Active Window" },
                                    { k: "Super + M (Exit)", d: "Super + Shift + M" }
                                ]

                                RowLayout {
                                    id: kbItem1
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Text {
                                        text: kbItem1.modelData.k
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: kbItem1.modelData.d
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // Column 2: Dynamic Special Workspaces
                    SageFrame {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "◈ 02 // SPECIAL WORKSPACES"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: SageState.specialWorkspaces

                                RowLayout {
                                    id: kbSpecItem
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Text {
                                        text: kbSpecItem.modelData.bind
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: kbSpecItem.modelData.label
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.3)
                            }

                            Text {
                                text: "Tip: Click Tab 02 // SPECIAL WS above to customize apps, binds, or add new special workspaces."
                                color: SageState.textMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }

                    // Column 3: Window & Workspace Navigation
                    SageFrame {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "◈ 03 // WINDOWS & TILING"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: [
                                    { k: "Super + 1..0", d: "Switch Workspace 1..10" },
                                    { k: "Super + Shift + 1..0", d: "Move Window to WS" },
                                    { k: "Super + Arrows", d: "Focus Direction" },
                                    { k: "Super + V", d: "Toggle Floating" },
                                    { k: "Super + F", d: "Fullscreen Mode" },
                                    { k: "Super + P", d: "Pseudo Tiling" },
                                    { k: "Super + J", d: "Toggle Split" },
                                    { k: "Super + S", d: "Scratchpad Toggle" }
                                ]

                                RowLayout {
                                    id: kbItem3
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Text {
                                        text: kbItem3.modelData.k
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: kbItem3.modelData.d
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // Column 4: Capture, Media & System
                    SageFrame {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: "◈ 04 // SYSTEM & CAPTURE"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: [
                                    { k: "Super + Shift + S", d: "Region Screenshot" },
                                    { k: "Print", d: "Full Screenshot" },
                                    { k: "Super + L", d: "Lock Screen" },
                                    { k: "Super + N", d: "Network & VPN Tab" },
                                    { k: "XF86AudioRaise/Lower", d: "Volume +/- 5%" },
                                    { k: "XF86AudioMute", d: "Mute Audio" },
                                    { k: "XF86MonBrightness", d: "Brightness +/- 5%" }
                                ]

                                RowLayout {
                                    id: kbItem4
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Text {
                                        text: kbItem4.modelData.k
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: kbItem4.modelData.d
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }
        }
    }
}
