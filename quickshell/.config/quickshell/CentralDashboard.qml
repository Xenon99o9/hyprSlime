import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: dashWindow
        required property var modelData
        screen: modelData

        visible: SageState.dashboardOpen && SageState.isActiveScreen(dashWindow.modelData)
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: (SageState.dashboardOpen && SageState.isActiveScreen(dashWindow.modelData)) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        property bool addKbModalOpen: false

        readonly property var allKnownLayouts: [
            { code: "fr", name: "Français (AZERTY Standard)", tag: "FR" },
            { code: "us", name: "English (US QWERTY Standard)", tag: "US" },
            { code: "gb", name: "English (UK QWERTY)", tag: "UK" },
            { code: "de", name: "Deutsch (QWERTZ Standard)", tag: "DE" },
            { code: "es", name: "Español (QWERTY España)", tag: "ES" },
            { code: "it", name: "Italiano (QWERTY Italia)", tag: "IT" },
            { code: "be", name: "Belge (AZERTY Belgique)", tag: "BE" },
            { code: "ch", name: "Suisse Romand (QWERTZ)", tag: "CH" },
            { code: "ca", name: "Canadien Français", tag: "CA" },
            { code: "pt", name: "Português (Portugal)", tag: "PT" },
            { code: "ru", name: "Русский (Russian)", tag: "RU" },
            { code: "jp", name: "日本語 (Japanese)", tag: "JP" }
        ]

        function getKbInfo(code) {
            for (let i = 0; i < dashWindow.allKnownLayouts.length; ++i) {
                if (dashWindow.allKnownLayouts[i].code === code) return dashWindow.allKnownLayouts[i];
            }
            return { code: code, name: code.toUpperCase() + " Layout", tag: code.slice(0, 3).toUpperCase() };
        }

        readonly property var currentMonitor: {
            if (SageState.monitorList.length === 0) {
                return {
                    id: 0,
                    name: "eDP-1",
                    desc: "Built-in Display",
                    width: 1920,
                    height: 1080,
                    refreshRate: 144.0,
                    currentMode: "1920x1080@144",
                    physW: 340,
                    physH: 190,
                    inches: 15.3,
                    x: 0,
                    y: 0,
                    scale: 1.0,
                    transform: 0,
                    disabled: false,
                    mirrorOf: "none",
                    modes: ["1920x1080@144.00Hz", "1920x1080@60.02Hz"]
                };
            }
            const idx = Math.min(SageState.selectedMonitorIndex, SageState.monitorList.length - 1);
            return SageState.monitorList[Math.max(0, idx)];
        }

        function buildMonitorsPayload() {
            const copy = [];
            for (let i = 0; i < SageState.monitorList.length; ++i) {
                const m = SageState.monitorList[i];
                const curMode = m.width + "x" + m.height + "@" + Number(m.refreshRate).toFixed(2);
                copy.push({
                    name: m.name,
                    mode: curMode,
                    x: m.x,
                    y: m.y,
                    scale: m.scale,
                    transform: m.transform,
                    disabled: m.disabled,
                    mirrorOf: m.mirrorOf
                });
            }
            return copy;
        }

        function updateMonitorField(idx, field, val) {
            const copy = buildMonitorsPayload();
            if (idx < 0 || idx >= copy.length) return;
            copy[idx][field] = val;
            SageState.applyMonitors(copy);
        }

        function updateMonitorPos(idx, newX, newY) {
            const copy = buildMonitorsPayload();
            if (idx < 0 || idx >= copy.length) return;
            copy[idx].x = newX;
            copy[idx].y = newY;
            SageState.applyMonitors(copy);
        }

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

            MouseArea {
                anchors.fill: parent
            }

            Column {
                x: 24
                y: 22
                width: 1032
                height: 606
                spacing: 14

                // ─── TOP HEADER BAR + NAVIGATION TABS (Zero Overlap!) ────────
                Item {
                    width: 1032
                    height: 36

                    Column {
                        width: 240
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text {
                            text: "◈ RAPHAEL OS // NEXUS"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 1.1
                        }
                        Text {
                            text: "CAELESTIA + END-4 HYBRID SHELL"
                            color: SageState.primaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    Row {
                        anchors.right: closeBtn.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6

                        Repeater {
                            model: [
                                { idx: 0, label: "01 // NEXUS" },
                                { idx: 1, label: "02 // SPECIAL WS" },
                                { idx: 2, label: "03 // THEME & WALLS" },
                                { idx: 3, label: "04 // DISPLAYS" },
                                { idx: 4, label: "05 // NETWORK" },
                                { idx: 5, label: "06 // KEYBINDS" }
                            ]

                            SageFrame {
                                id: navTab
                                required property var modelData
                                readonly property bool isActive: SageState.activeTab === modelData.idx

                                width: navTabText.implicitWidth + 18
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
                                        if (navTab.modelData.idx === 3) SageState.loadMonitors();
                                        if (navTab.modelData.idx === 4) SageState.scanWifi();
                                    }
                                }
                            }
                        }
                    }

                    SageFrame {
                        id: closeBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
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

                Rectangle {
                    width: 1032
                    height: 1
                    color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.45)
                }

                // ═══════════════════════════════════════════════════════════════
                // TAB 0: OVERVIEW DASHBOARD (472px Left + 18px Gap + 542px Right = 1032px)
                // ═══════════════════════════════════════════════════════════════
                Row {
                    width: 1032
                    height: 540
                    visible: SageState.activeTab === 0
                    spacing: 18

                    // LEFT COLUMN (Width: 472, Height: 540)
                    Column {
                        width: 472
                        height: 540
                        spacing: 14

                        // 1. Rimuru Tempest / Great Sage Profile Card (472 x 186)
                        SageFrame {
                            width: 472
                            height: 186
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.secondaryAccent
                            innerBorder: true

                            Row {
                                x: 18
                                y: 18
                                width: 436
                                height: 150
                                spacing: 18

                                Rectangle {
                                    width: 146
                                    height: 146
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

                                Column {
                                    width: 272
                                    anchors.verticalCenter: parent.verticalCenter
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
                                        width: 260
                                        height: 1
                                        color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.3)
                                    }

                                    Text {
                                        text: "TIME  // " + SageState.clockTime + " (" + SageState.clockDate + ")"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        text: "SKILL // " + SageState.themeName.toUpperCase() + "  |  KB: " + SageState.kbLayout.toUpperCase()
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        // 2. Special Workspaces Summon Matrix (472 x 340, Cards 212 x 116 -> Zero overflow!)
                        SageFrame {
                            width: 472
                            height: 340
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.primaryAccent
                            innerBorder: true

                            Column {
                                x: 18
                                y: 16
                                width: 436
                                spacing: 12

                                Item {
                                    width: 436
                                    height: 20
                                    Text {
                                        anchors.left: parent.left
                                        text: "◈ CAELESTIA SPECIAL WORKSPACES"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
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

                                Grid {
                                    width: 436
                                    columns: 2
                                    spacing: 12

                                    Repeater {
                                        model: SageState.specialWorkspaces

                                        Rectangle {
                                            id: dashSpecCard
                                            required property var modelData
                                            width: 212
                                            height: 118
                                            radius: 6
                                            color: dashSpecMouse.containsMouse ? SageState.bgCardHover : SageState.bgSurface
                                            border.width: 1.5
                                            border.color: modelData.running ? SageState.secondaryAccent : SageState.primaryAccent

                                            Column {
                                                x: 14
                                                y: 12
                                                width: 184
                                                spacing: 6

                                                Item {
                                                    width: 184
                                                    height: 18
                                                    Text {
                                                        anchors.left: parent.left
                                                        text: "◈ " + dashSpecCard.modelData.label
                                                        color: SageState.textPrimary
                                                        font.family: "JetBrainsMono Nerd Font"
                                                        font.pixelSize: 12
                                                        font.bold: true
                                                    }
                                                    Rectangle {
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        width: 8
                                                        height: 8
                                                        radius: 4
                                                        color: dashSpecCard.modelData.running ? SageState.emeraldOk : SageState.textMuted
                                                    }
                                                }

                                                Text {
                                                    width: 184
                                                    text: "KEYBIND: " + dashSpecCard.modelData.bind
                                                    color: SageState.secondaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }

                                                Text {
                                                    width: 184
                                                    text: "CMD: " + dashSpecCard.modelData.cmd
                                                    color: SageState.textMuted
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    text: dashSpecCard.modelData.running ? "STATUS: RUNNING ▸" : "CLICK TO SUMMON ▸"
                                                    color: dashSpecCard.modelData.running ? SageState.emeraldOk : SageState.primaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    font.bold: true
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

                    // RIGHT COLUMN (Width: 542, Height: 540)
                    Column {
                        width: 542
                        height: 540
                        spacing: 14

                        // 1. Three Telemetry Stat Boxes
                        Row {
                            width: 542
                            height: 90
                            spacing: 10

                            SageFrame {
                                width: 174
                                height: 90
                                chamfer: 10
                                fillColor: SageState.bgCard
                                borderColor: SageState.primaryAccent

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
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
                                width: 174
                                height: 90
                                chamfer: 10
                                fillColor: SageState.bgCard
                                borderColor: SageState.secondaryAccent

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
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
                                width: 174
                                height: 90
                                chamfer: 10
                                fillColor: SageState.bgCard
                                borderColor: SageState.emeraldOk

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "GPU (" + (SageState.gpuName || "CORE") + ")"
                                        color: SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.gpuUsage + "%"
                                        color: SageState.emeraldOk
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 24
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.gpuTemp + "°C | " + (SageState.gpuVramText.length > 0 ? SageState.gpuVramText : "VRAM")
                                        color: SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                    }
                                }
                            }
                        }

                        // 2. end-4 Style 2x2 Bento Quick Toggle Cards
                        Grid {
                            width: 542
                            height: 176
                            columns: 2
                            spacing: 12

                            SageFrame {
                                width: 265
                                height: 82
                                chamfer: 10
                                fillColor: SageState.wifiEnabled
                                           ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                           : SageState.bgCard
                                borderColor: SageState.wifiEnabled ? SageState.primaryAccent : SageState.textMuted

                                Column {
                                    x: 16
                                    y: 18
                                    width: 233
                                    spacing: 6
                                    Text {
                                        text: "◈ WIRELESS MATRIX (WI-FI)"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        width: 233
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
                                            SageState.openDashboardTab(4);
                                        } else {
                                            SageState.runCmd([SageState.ctlScript, "wifi-toggle"]);
                                        }
                                    }
                                }
                            }

                            SageFrame {
                                width: 265
                                height: 82
                                chamfer: 10
                                fillColor: SageState.vpnActive
                                           ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.2)
                                           : SageState.bgCard
                                borderColor: SageState.vpnActive ? SageState.emeraldOk : SageState.textMuted

                                Column {
                                    x: 16
                                    y: 18
                                    width: 233
                                    spacing: 6
                                    Text {
                                        text: "◈ BARRIER TUNNEL (VPN)"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        width: 233
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
                                    onClicked: SageState.openDashboardTab(4)
                                }
                            }

                            SageFrame {
                                width: 265
                                height: 82
                                chamfer: 10
                                fillColor: SageState.btEnabled
                                           ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                           : SageState.bgCard
                                borderColor: SageState.btEnabled ? SageState.primaryAccent : SageState.textMuted

                                Column {
                                    x: 16
                                    y: 18
                                    width: 233
                                    spacing: 6
                                    Text {
                                        text: "◈ TELEPATHY LINK (BLUETOOTH)"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        width: 233
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

                            SageFrame {
                                width: 265
                                height: 82
                                chamfer: 10
                                fillColor: SageState.borderFlow
                                           ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.22)
                                           : SageState.bgCard
                                borderColor: SageState.borderFlow ? SageState.secondaryAccent : SageState.textMuted

                                Column {
                                    x: 16
                                    y: 18
                                    width: 233
                                    spacing: 6
                                    Text {
                                        text: "◈ MAGICULE BORDER ROTATION"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        width: 233
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

                        // 3. Audio, Luminance & Power Profile Card
                        SageFrame {
                            width: 542
                            height: 246
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.primaryAccent

                            Column {
                                x: 20
                                y: 18
                                width: 502
                                spacing: 16

                                Column {
                                    width: 502
                                    spacing: 6

                                    Item {
                                        width: 502
                                        height: 18
                                        Text {
                                            anchors.left: parent.left
                                            text: SageState.muted ? "◈ ACOUSTIC OUTPUT [MUTED]" : "◈ ACOUSTIC OUTPUT (VOLUME)"
                                            color: SageState.muted ? SageState.crimsonAlert : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        Text {
                                            anchors.right: parent.right
                                            text: SageState.volume + "%"
                                            color: SageState.primaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Rectangle {
                                        id: dashVolBar
                                        width: 502
                                        height: 18
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

                                Column {
                                    width: 502
                                    spacing: 6

                                    Item {
                                        width: 502
                                        height: 18
                                        Text {
                                            anchors.left: parent.left
                                            text: "◈ OPTICAL LUMINANCE (BRIGHTNESS)"
                                            color: SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        Text {
                                            anchors.right: parent.right
                                            text: SageState.brightness + "%"
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Rectangle {
                                        id: dashBrightBar
                                        width: 502
                                        height: 18
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

                                Row {
                                    width: 502
                                    height: 36
                                    spacing: 11

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

                                            width: 160
                                            height: 36
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
                Column {
                    width: 1032
                    height: 540
                    visible: SageState.activeTab === 1
                    spacing: 14

                    Text {
                        text: "◈ CAELESTIA SPECIAL WORKSPACES // HIDDEN OVERLAY WORKSPACES & LIVE KEYBIND EDITOR"
                        color: SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Flickable {
                        width: 1032
                        height: 416
                        contentHeight: specListCol.implicitHeight
                        clip: true

                        Column {
                            id: specListCol
                            width: 1032
                            spacing: 10

                            Repeater {
                                model: SageState.specialWorkspaces

                                SageFrame {
                                    id: wsEditorRow
                                    required property var modelData

                                    width: 1032
                                    height: 68
                                    chamfer: 10
                                    fillColor: SageState.bgCard
                                    borderColor: modelData.running ? SageState.secondaryAccent : SageState.primaryAccent

                                    Row {
                                        x: 16
                                        y: 15
                                        width: 1000
                                        height: 38
                                        spacing: 12

                                        Rectangle {
                                            width: 58
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

                                        Column {
                                            width: 130
                                            anchors.verticalCenter: parent.verticalCenter
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

                                        Rectangle {
                                            width: 185
                                            height: 38
                                            radius: 4
                                            color: SageState.bgVoid
                                            border.width: 1
                                            border.color: SageState.secondaryAccent

                                            TextField {
                                                id: bindEditInput
                                                anchors.fill: parent
                                                anchors.leftMargin: 10
                                                anchors.rightMargin: 10
                                                verticalAlignment: TextInput.AlignVCenter
                                                text: wsEditorRow.modelData.bind
                                                color: SageState.secondaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 11
                                                font.bold: true
                                                background: Item {}
                                            }
                                        }

                                        Rectangle {
                                            width: 355
                                            height: 38
                                            radius: 4
                                            color: SageState.bgVoid
                                            border.width: 1
                                            border.color: SageState.primaryAccent

                                            TextField {
                                                id: cmdEditInput
                                                anchors.fill: parent
                                                anchors.leftMargin: 10
                                                anchors.rightMargin: 10
                                                verticalAlignment: TextInput.AlignVCenter
                                                text: wsEditorRow.modelData.cmd
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 11
                                                background: Item {}
                                            }
                                        }

                                        Rectangle {
                                            width: 86
                                            height: 38
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

                                        Rectangle {
                                            width: 76
                                            height: 38
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

                                        Rectangle {
                                            width: 38
                                            height: 38
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
                        width: 1032
                        height: 74
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent

                        Row {
                            x: 16
                            y: 18
                            width: 1000
                            height: 38
                            spacing: 10

                            Text {
                                width: 62
                                anchors.verticalCenter: parent.verticalCenter
                                text: "◈ NEW:"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Rectangle {
                                width: 150
                                height: 38
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
                                width: 95
                                height: 38
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
                                width: 175
                                height: 38
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
                                width: 338
                                height: 38
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
                                width: 130
                                height: 38
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
                // TAB 2: WALLPAPERS, THEMES & KEYBOARD SELECTOR LIST
                // ═══════════════════════════════════════════════════════════════
                Row {
                    width: 1032
                    height: 540
                    visible: SageState.activeTab === 2
                    spacing: 18

                    // LEFT: Visual Wallpaper Grid (Static HD & Slow Animated GIFs for all themes!)
                    SageFrame {
                        width: 580
                        height: 540
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        Column {
                            x: 16
                            y: 16
                            width: 548
                            height: 508
                            spacing: 10

                            Item {
                                width: 548
                                height: 24

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "◈ WALLPAPER STUDIO (STATIC HD & SLOW ANIMATED)"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Row {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4
                                    Repeater {
                                        model: ["wave", "outer", "grow", "wipe"]
                                        Rectangle {
                                            id: trPill
                                            required property string modelData
                                            width: 48
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
                                width: 548
                                height: 472
                                cellWidth: 274
                                cellHeight: 152
                                clip: true
                                model: SageState.wallpapers

                                delegate: Item {
                                    id: wallDelegate
                                    required property var modelData
                                    width: 274
                                    height: 152

                                    readonly property bool isCurrent: SageState.currentWallpaper === modelData.path
                                    readonly property bool isAnim: modelData.path.indexOf(".gif") !== -1

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
                                            sourceSize.width: 320
                                            sourceSize.height: 180
                                            fillMode: Image.PreserveAspectCrop
                                        }

                                        // Top-Right Badge: ANIMATED vs HD STATIC
                                        Rectangle {
                                            anchors.top: parent.top
                                            anchors.right: parent.right
                                            anchors.margins: 8
                                            width: wallDelegate.isAnim ? 68 : 44
                                            height: 18
                                            radius: 3
                                            color: wallDelegate.isAnim ? SageState.secondaryAccent : "#cc060b14"
                                            border.width: 1
                                            border.color: wallDelegate.isAnim ? SageState.secondaryAccent : SageState.primaryAccent

                                            Text {
                                                anchors.centerIn: parent
                                                text: wallDelegate.isAnim ? "ANIMATED" : "STATIC"
                                                color: wallDelegate.isAnim ? "#050911" : SageState.primaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 8
                                                font.bold: true
                                            }
                                        }

                                        Rectangle {
                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                bottom: parent.bottom
                                            }
                                            height: 26
                                            color: "#d9060b14"

                                            Item {
                                                anchors.fill: parent
                                                anchors.leftMargin: 10
                                                anchors.rightMargin: 10
                                                Text {
                                                    width: 185
                                                    anchors.left: parent.left
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: wallDelegate.modelData.name.toUpperCase()
                                                    color: wallDelegate.isCurrent ? SageState.secondaryAccent : SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                    elide: Text.ElideRight
                                                }
                                                Text {
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
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

                    // RIGHT: Ultimate Skill Themes + Keyboard Layout Selection List (Width: 434)
                    Column {
                        width: 434
                        height: 540
                        spacing: 12

                        // 1. Ultimate Skill Color Schemes Card (434 x 272)
                        SageFrame {
                            width: 434
                            height: 272
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.secondaryAccent

                            Column {
                                x: 16
                                y: 14
                                width: 402
                                spacing: 7

                                Item {
                                    width: 402
                                    height: 20
                                    Text {
                                        anchors.left: parent.left
                                        text: "◈ ULTIMATE SKILL COLOR SCHEMES"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        text: SageState.holographicOpacity ? "[BLUR: ON]" : "[BLUR: OFF]"
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
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

                                Flickable {
                                    width: 402
                                    height: 226
                                    contentHeight: themeCol.implicitHeight
                                    clip: true

                                    Column {
                                        id: themeCol
                                        width: 402
                                        spacing: 6

                                        Repeater {
                                            model: [
                                                { id: "great_sage", title: "GREAT SAGE // RAPHAEL GOLD", desc: "Cyan Magicule + Golden Seal", c1: "#00e5ff", c2: "#ffd54f", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/rimuru-great-sage.png" },
                                                { id: "magicule", title: "RIMURU // PURE MAGICULE ICE", desc: "Luminous Cyan + Glacial Ice", c1: "#00e5ff", c2: "#84ffff", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/rimuru-magicule.png" },
                                                { id: "beelzebub", title: "BEELZEBUB // GLUTTONY ABYSS", desc: "Devouring Vortex Violet + Cyan", c1: "#b388ff", c2: "#00e5ff", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/beelzebub-abyss.png" },
                                                { id: "hellflare", title: "BENIMARU // CRIMSON HELLFLARE", desc: "Demon Lord Crimson + Gold Flame", c1: "#ff5252", c2: "#ffd54f", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/crimson-hellflare.png" },
                                                { id: "diablo", title: "DIABLO // NOIR PRIMORDIAL", desc: "Lord of Darkness Crimson & Gold", c1: "#e53935", c2: "#ffd54f", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/diablo-primordial.png" },
                                                { id: "testarossa", title: "TESTAROSSA // BLANC PRIMORDIAL", desc: "Celestial White Noble & Blood Ruby", c1: "#ffffff", c2: "#ef4444", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/testarossa-primordial.png" },
                                                { id: "carrera", title: "CARRERA // JAUNE PRIMORDIAL", desc: "Solar Lightning Yellow & Imperial Violet", c1: "#fbbf24", c2: "#a855f7", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/carrera-primordial.png" },
                                                { id: "ultima", title: "ULTIMA // VIOLET PRIMORDIAL", desc: "Toxic Violet Flame & Emerald Poison", c1: "#c084fc", c2: "#10b981", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/ultima-primordial.png" },
                                                { id: "mustang", title: "MUSTANG // DEMON PRIMORDIAL", desc: "Onyx Shadow & Fiery Amber Flame", c1: "#f97316", c2: "#ffd54f", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/mustang-primordial.png" }
                                            ]

                                            Rectangle {
                                                id: themeCard
                                                required property var modelData
                                                readonly property bool active: SageState.themeName === modelData.id

                                                width: 398
                                                height: 48
                                                radius: 5
                                                color: active
                                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.22)
                                                       : SageState.bgVoid
                                                border.width: active ? 2 : 1
                                                border.color: active ? SageState.secondaryAccent : SageState.primaryAccent

                                                Row {
                                                    x: 10
                                                    y: 7
                                                    width: 378
                                                    height: 34
                                                    spacing: 10

                                                    Row {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 3
                                                        Rectangle { width: 10; height: 26; radius: 2; color: themeCard.modelData.c1 }
                                                        Rectangle { width: 10; height: 26; radius: 2; color: themeCard.modelData.c2 }
                                                    }

                                                    Column {
                                                        width: 260
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 1
                                                        Text {
                                                            text: themeCard.modelData.title
                                                            color: SageState.textPrimary
                                                            font.family: "JetBrainsMono Nerd Font"
                                                            font.pixelSize: 10
                                                            font.bold: true
                                                            elide: Text.ElideRight
                                                        }
                                                        Text {
                                                            text: themeCard.modelData.desc
                                                            color: SageState.textMuted
                                                            font.family: "JetBrainsMono Nerd Font"
                                                            font.pixelSize: 9
                                                            elide: Text.ElideRight
                                                        }
                                                    }

                                                    Text {
                                                        width: 66
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        horizontalAlignment: Text.AlignRight
                                                        text: themeCard.active ? "ACTIVE" : "SELECT ▸"
                                                        color: themeCard.active ? SageState.secondaryAccent : SageState.primaryAccent
                                                        font.family: "JetBrainsMono Nerd Font"
                                                        font.pixelSize: 9
                                                        font.bold: true
                                                    }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        SageState.setTheme(themeCard.modelData.id, themeCard.modelData.wall);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 2. Clean Selectable List of Keyboard Layouts (434 x 256)
                        SageFrame {
                            width: 434
                            height: 256
                            chamfer: 12
                            fillColor: SageState.bgCard
                            borderColor: SageState.primaryAccent

                            Column {
                                x: 16
                                y: 14
                                width: 402
                                spacing: 6

                                Item {
                                    width: 402
                                    height: 24

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "◈ CONFIGURED KEYBOARD LAYOUTS"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 130
                                        height: 22
                                        radius: 4
                                        color: addKbMouse.containsMouse ? SageState.secondaryAccent : SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.secondaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: dashWindow.addKbModalOpen ? "▲ CLOSE" : "＋ ADD KB LAYOUT"
                                            color: addKbMouse.containsMouse ? "#050911" : SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: addKbMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: dashWindow.addKbModalOpen = !dashWindow.addKbModalOpen
                                        }
                                    }
                                }

                                // 1. Active Configured Layouts List
                                Repeater {
                                    model: SageState.activeKbLayouts

                                    Rectangle {
                                        id: kbRowItem
                                        required property string modelData
                                        readonly property var kbInfo: dashWindow.getKbInfo(modelData)
                                        readonly property bool isSelected: SageState.kbLayout === modelData

                                        width: 402
                                        height: 36
                                        radius: 5
                                        color: isSelected
                                               ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.24)
                                               : SageState.bgVoid
                                        border.width: isSelected ? 1.5 : 1
                                        border.color: isSelected ? SageState.secondaryAccent : SageState.primaryAccent

                                        Row {
                                            x: 10
                                            y: 6
                                            width: 382
                                            height: 24
                                            spacing: 8

                                            Rectangle {
                                                width: 42
                                                height: 22
                                                anchors.verticalCenter: parent.verticalCenter
                                                radius: 3
                                                color: kbRowItem.isSelected ? SageState.secondaryAccent : SageState.bgCard
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: kbRowItem.kbInfo.tag
                                                    color: kbRowItem.isSelected ? "#050911" : SageState.secondaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                }
                                            }

                                            Text {
                                                width: 220
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: kbRowItem.kbInfo.name
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.bold: kbRowItem.isSelected
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                width: 60
                                                anchors.verticalCenter: parent.verticalCenter
                                                horizontalAlignment: Text.AlignRight
                                                text: kbRowItem.isSelected ? "● ACTIVE" : "SWITCH ▸"
                                                color: kbRowItem.isSelected ? SageState.emeraldOk : SageState.primaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            // Remove button (only if more than 1 layout configured)
                                            Rectangle {
                                                visible: SageState.activeKbLayouts.length > 1
                                                width: 20
                                                height: 20
                                                radius: 3
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: remKbMouse.containsMouse ? SageState.crimsonAlert : "transparent"
                                                border.width: 1
                                                border.color: remKbMouse.containsMouse ? SageState.crimsonAlert : Qt.rgba(SageState.crimsonAlert.r, SageState.crimsonAlert.g, SageState.crimsonAlert.b, 0.4)

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "✕"
                                                    color: remKbMouse.containsMouse ? "#050911" : SageState.crimsonAlert
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                }

                                                MouseArea {
                                                    id: remKbMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: SageState.removeKbLayout(kbRowItem.modelData)
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.selectKbLayout(kbRowItem.modelData)
                                        }
                                    }
                                }

                                // 2. Picker Modal when "＋ ADD KB LAYOUT" is open
                                Rectangle {
                                    visible: dashWindow.addKbModalOpen
                                    width: 402
                                    height: 160
                                    radius: 6
                                    color: SageState.bgVoid
                                    border.width: 1.5
                                    border.color: SageState.secondaryAccent

                                    Flickable {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        contentHeight: pickerCol.implicitHeight
                                        clip: true

                                        Column {
                                            id: pickerCol
                                            width: 390
                                            spacing: 4

                                            Repeater {
                                                model: dashWindow.allKnownLayouts

                                                Rectangle {
                                                    id: pickItem
                                                    required property var modelData
                                                    readonly property bool alreadyAdded: SageState.activeKbLayouts.indexOf(modelData.code) !== -1
                                                    visible: !alreadyAdded
                                                    width: 390
                                                    height: alreadyAdded ? 0 : 28
                                                    radius: 4
                                                    color: pickMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard
                                                    border.width: 1
                                                    border.color: pickMouse.containsMouse ? SageState.secondaryAccent : SageState.primaryAccent

                                                    Item {
                                                        x: 8
                                                        y: 4
                                                        width: 374
                                                        height: 20

                                                        Row {
                                                            anchors.left: parent.left
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            spacing: 8

                                                            Text {
                                                                text: pickItem.modelData.tag
                                                                color: SageState.secondaryAccent
                                                                font.family: "JetBrainsMono Nerd Font"
                                                                font.pixelSize: 9
                                                                font.bold: true
                                                            }

                                                            Text {
                                                                width: 270
                                                                text: pickItem.modelData.name
                                                                color: SageState.textPrimary
                                                                font.family: "JetBrainsMono Nerd Font"
                                                                font.pixelSize: 10
                                                                elide: Text.ElideRight
                                                            }
                                                        }

                                                        Text {
                                                            anchors.right: parent.right
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            text: "＋ ADD"
                                                            color: SageState.emeraldOk
                                                            font.family: "JetBrainsMono Nerd Font"
                                                            font.pixelSize: 9
                                                            font.bold: true
                                                        }
                                                    }

                                                    MouseArea {
                                                        id: pickMouse
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            SageState.addKbLayout(pickItem.modelData.code);
                                                            dashWindow.addKbModalOpen = false;
                                                        }
                                                    }
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
                // TAB 3: GRAPHICAL DISPLAY & MULTI-MONITOR MANAGER (580 + 16 + 436)
                // ═══════════════════════════════════════════════════════════════
                Row {
                    width: 1032
                    height: 540
                    visible: SageState.activeTab === 3
                    spacing: 16

                    // LEFT PANEL: Interactive 2D Spatial Projection Canvas + Layout Presets
                    SageFrame {
                        width: 580
                        height: 540
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent
                        innerBorder: true

                        Column {
                            x: 18
                            y: 16
                            width: 544
                            spacing: 10

                            // Header
                            Item {
                                width: 544
                                height: 28

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "◈ SPATIAL DISPLAY PROJECTION (DRAG TO ARRANGE)"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Row {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Rectangle {
                                        width: 108
                                        height: 26
                                        radius: 4
                                        color: SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.secondaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "NWG-DISPLAYS"
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.launchApp("nwg-displays")
                                        }
                                    }

                                    Rectangle {
                                        width: 110
                                        height: 26
                                        radius: 4
                                        color: SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "SCAN DISPLAYS"
                                            color: SageState.primaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.loadMonitors()
                                        }
                                    }
                                }
                            }

                            // 2D Interactive Blueprint Canvas (544 x 300)
                            Rectangle {
                                id: displayCanvas
                                width: 544
                                height: 300
                                radius: 6
                                color: "#050912"
                                border.width: 1.5
                                border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.45)
                                clip: true

                                // Blueprint Grid & Origin Axes
                                Canvas {
                                    anchors.fill: parent
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = "rgba(0, 229, 255, 0.08)";
                                        ctx.lineWidth = 1;
                                        for (var gx = 0; gx < width; gx += 24) {
                                            ctx.beginPath();
                                            ctx.moveTo(gx, 0);
                                            ctx.lineTo(gx, height);
                                            ctx.stroke();
                                        }
                                        for (var gy = 0; gy < height; gy += 24) {
                                            ctx.beginPath();
                                            ctx.moveTo(0, gy);
                                            ctx.lineTo(width, gy);
                                            ctx.stroke();
                                        }
                                        // Origin Crosshair at (185, 110)
                                        ctx.strokeStyle = "rgba(255, 213, 79, 0.22)";
                                        ctx.beginPath();
                                        ctx.moveTo(185, 0);
                                        ctx.lineTo(185, height);
                                        ctx.moveTo(0, 110);
                                        ctx.lineTo(width, 110);
                                        ctx.stroke();
                                    }
                                }

                                Text {
                                    x: 10
                                    y: 8
                                    text: "ORIGIN (0,0) // DETECTED DISPLAYS: " + SageState.monitorList.length
                                    color: SageState.textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                Text {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 8
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: "TIP: Click to select a screen, drag to move it, or use a preset below."
                                    color: SageState.textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                }

                                Repeater {
                                    model: SageState.monitorList

                                    SageFrame {
                                        id: monBox
                                        required property var modelData
                                        required property int index
                                        readonly property bool isSel: index === SageState.selectedMonitorIndex
                                        readonly property real effW: Math.max(640, (modelData.width || 1920) / Math.max(0.5, modelData.scale || 1.0))
                                        readonly property real effH: Math.max(480, (modelData.height || 1080) / Math.max(0.5, modelData.scale || 1.0))

                                        width: Math.round(effW * 0.068)
                                        height: Math.round(effH * 0.068)
                                        x: Math.max(8, Math.min(displayCanvas.width - width - 8, Math.round(185 + (modelData.x || 0) * 0.068)))
                                        y: Math.max(24, Math.min(displayCanvas.height - height - 24, Math.round(110 + (modelData.y || 0) * 0.068)))

                                        chamfer: 8
                                        fillColor: isSel
                                                   ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.28)
                                                   : "#d80c1526"
                                        borderColor: modelData.disabled
                                                     ? SageState.crimsonAlert
                                                     : (isSel ? SageState.secondaryAccent : SageState.primaryAccent)
                                        borderWidth: isSel ? 2.0 : 1.5
                                        innerBorder: isSel

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: "◈ " + monBox.modelData.name
                                                color: monBox.isSel ? SageState.secondaryAccent : SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: monBox.modelData.width + "×" + monBox.modelData.height + " @ " + Math.round(monBox.modelData.refreshRate) + "Hz"
                                                color: SageState.primaryAccent
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 8
                                                font.bold: true
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: monBox.modelData.disabled
                                                      ? "[DISABLED]"
                                                      : (monBox.modelData.mirrorOf !== "none"
                                                         ? ("MIRROR: " + monBox.modelData.mirrorOf)
                                                         : ("POS: " + monBox.modelData.x + "," + monBox.modelData.y + (monBox.modelData.inches > 0 ? (" • " + monBox.modelData.inches + "\"") : "")))
                                                color: SageState.textMuted
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 8
                                                font.bold: true
                                            }
                                        }

                                        MouseArea {
                                            id: monDragArea
                                            anchors.fill: parent
                                            cursorShape: Qt.SizeAllCursor
                                            drag.target: monBox
                                            drag.axis: Drag.XAndYAxis
                                            drag.minimumX: 8
                                            drag.maximumX: displayCanvas.width - monBox.width - 8
                                            drag.minimumY: 24
                                            drag.maximumY: displayCanvas.height - monBox.height - 24

                                            property real startBoxX: 0
                                            property real startBoxY: 0

                                            onPressed: {
                                                SageState.selectedMonitorIndex = monBox.index;
                                                startBoxX = monBox.x;
                                                startBoxY = monBox.y;
                                            }

                                            onReleased: {
                                                const movedDist = Math.hypot(monBox.x - startBoxX, monBox.y - startBoxY);
                                                if (movedDist > 6) {
                                                    let rawX = Math.round(((monBox.x - 185) / 0.068) / 20) * 20;
                                                    let rawY = Math.round(((monBox.y - 110) / 0.068) / 20) * 20;
                                                    if (Math.abs(rawX) <= 80) rawX = 0;
                                                    if (Math.abs(rawY) <= 80) rawY = 0;
                                                    if (SageState.monitorList.length > 0 && monBox.index > 0) {
                                                        const pW = Math.round((SageState.monitorList[0].width || 1920) / (SageState.monitorList[0].scale || 1.0));
                                                        const pH = Math.round((SageState.monitorList[0].height || 1080) / (SageState.monitorList[0].scale || 1.0));
                                                        if (Math.abs(rawX - pW) <= 140) rawX = pW;
                                                        if (Math.abs(rawX + pW) <= 140) rawX = -pW;
                                                        if (Math.abs(rawY - pH) <= 140) rawY = pH;
                                                        if (Math.abs(rawY + pH) <= 140) rawY = -pH;
                                                    }
                                                    if (rawX !== monBox.modelData.x || rawY !== monBox.modelData.y) {
                                                        dashWindow.updateMonitorPos(monBox.index, rawX, rawY);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Workspace to Display Mapping Matrix (Workspaces 1 - 10)
                            Column {
                                width: 544
                                spacing: 6

                                Item {
                                    width: 544
                                    height: 20

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "◈ WORKSPACE DISTRIBUTION (1 - 10) // ASSIGN TO MONITORS"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 140
                                        height: 20
                                        radius: 3
                                        color: autoWsMouse.containsMouse ? SageState.bgCardHover : SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.secondaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "⚡ AUTO (5 & 5 / SPLIT)"
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 8
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: autoWsMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.autoDistributeWorkspaces()
                                        }
                                    }
                                }

                                Row {
                                    width: 544
                                    height: 44
                                    spacing: 5

                                    Repeater {
                                        model: 10

                                        Rectangle {
                                            id: wsCard
                                            required property int index
                                            readonly property int wsId: index + 1
                                            readonly property string wsStr: wsId.toString()
                                            readonly property string assignedMon: (SageState.workspaceMap && SageState.workspaceMap[wsStr])
                                                                                  ? SageState.workspaceMap[wsStr]
                                                                                  : (SageState.monitorList.length > 0 ? SageState.monitorList[0].name : "eDP-1")
                                            readonly property int monIndex: {
                                                for (let i = 0; i < SageState.monitorList.length; ++i) {
                                                    if (SageState.monitorList[i].name === wsCard.assignedMon) return i;
                                                }
                                                return 0;
                                            }

                                            width: 49.9
                                            height: 44
                                            radius: 4
                                            color: wsMouse.containsMouse ? SageState.bgCardHover : SageState.bgVoid
                                            border.width: 1
                                            border.color: monIndex === 0 ? SageState.primaryAccent : SageState.secondaryAccent

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 2

                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "WS " + wsCard.wsId
                                                    color: SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }

                                                Rectangle {
                                                    width: 42
                                                    height: 14
                                                    radius: 2
                                                    color: wsCard.monIndex === 0
                                                           ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.25)
                                                           : Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.25)
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: wsCard.assignedMon
                                                        color: wsCard.monIndex === 0 ? SageState.primaryAccent : SageState.secondaryAccent
                                                        font.family: "JetBrainsMono Nerd Font"
                                                        font.pixelSize: 8
                                                        font.bold: true
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: wsMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (SageState.monitorList.length > 1) {
                                                        const nextIdx = (wsCard.monIndex + 1) % SageState.monitorList.length;
                                                        const nextMon = SageState.monitorList[nextIdx].name;
                                                        const copy = Object.assign({}, SageState.workspaceMap);
                                                        copy[wsCard.wsStr] = nextMon;
                                                        SageState.applyWorkspaceMapping(copy);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Quick Multi-Monitor Layout Presets
                            Text {
                                text: "◈ MULTI-SCREEN AUTOMATIC ARRANGEMENT PRESETS"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Grid {
                                width: 544
                                height: 84
                                columns: 3
                                spacing: 8

                                Repeater {
                                    model: [
                                        { id: "extend-right", label: "EXTEND RIGHT ▸", sub: "Primary + Right" },
                                        { id: "extend-left",  label: "◂ EXTEND LEFT",  sub: "Left + Primary" },
                                        { id: "extend-above", label: "▲ EXTEND ABOVE", sub: "Top + Bottom" },
                                        { id: "mirror",       label: "◈ MIRROR SCREEN", sub: "Clone Primary" },
                                        { id: "laptop-only",  label: "PRIMARY ONLY",   sub: "Disable External" },
                                        { id: "external-only",label: "EXTERNAL ONLY",  sub: "Disable Laptop" }
                                    ]

                                    SageFrame {
                                        id: presetBtn
                                        required property var modelData
                                        width: 176
                                        height: 38
                                        chamfer: 6
                                        fillColor: presetMouse.containsMouse ? SageState.bgCardHover : SageState.bgVoid
                                        borderColor: presetMouse.containsMouse ? SageState.secondaryAccent : SageState.primaryAccent

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 1
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: presetBtn.modelData.label
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.bold: true
                                            }
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: presetBtn.modelData.sub
                                                color: SageState.textMuted
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 8
                                            }
                                        }

                                        MouseArea {
                                            id: presetMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.applyMonitorPreset(presetBtn.modelData.id)
                                        }
                                    }
                                }
                            }

                            Text {
                                width: 544
                                text: "◈ AUTO-PLUG ENABLED: Any external HDMI/DP screen connected is automatically sized to its native EDID resolution & refresh rate."
                                color: SageState.emeraldOk
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // RIGHT PANEL: Selected Monitor Inspector & Live Parameters (436 x 540)
                    SageFrame {
                        width: 436
                        height: 540
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent
                        innerBorder: true

                        Column {
                            x: 18
                            y: 16
                            width: 400
                            spacing: 10

                            // Selected Display Title & Hardware Info
                            Column {
                                width: 400
                                spacing: 3

                                Text {
                                    text: "◈ DISPLAY INSPECTOR // " + dashWindow.currentMonitor.name
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Text {
                                    width: 400
                                    text: dashWindow.currentMonitor.desc + (dashWindow.currentMonitor.inches > 0
                                          ? ("  •  " + dashWindow.currentMonitor.inches + "\" (" + dashWindow.currentMonitor.physW + "×" + dashWindow.currentMonitor.physH + "mm)")
                                          : "")
                                    color: SageState.textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                            }

                            // Selector Strip if multiple monitors exist
                            Row {
                                width: 400
                                height: 28
                                spacing: 8

                                Repeater {
                                    model: SageState.monitorList

                                    Rectangle {
                                        id: monTabPill
                                        required property var modelData
                                        required property int index
                                        readonly property bool isCur: index === SageState.selectedMonitorIndex
                                        width: Math.floor((400 - (Math.max(1, SageState.monitorList.length) - 1) * 8) / Math.max(1, SageState.monitorList.length))
                                        height: 28
                                        radius: 4
                                        color: isCur
                                               ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.22)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: isCur ? SageState.secondaryAccent : SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "◈ " + monTabPill.modelData.name + " (" + monTabPill.modelData.width + "×" + monTabPill.modelData.height + ")"
                                            color: monTabPill.isCur ? SageState.secondaryAccent : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.selectedMonitorIndex = monTabPill.index
                                        }
                                    }
                                }
                            }

                            // Enable/Disable & Mirror Mode Toggles
                            Row {
                                width: 400
                                height: 34
                                spacing: 10

                                Rectangle {
                                    width: 195
                                    height: 34
                                    radius: 4
                                    color: !dashWindow.currentMonitor.disabled
                                           ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.18)
                                           : Qt.rgba(SageState.crimsonAlert.r, SageState.crimsonAlert.g, SageState.crimsonAlert.b, 0.18)
                                    border.width: 1
                                    border.color: !dashWindow.currentMonitor.disabled ? SageState.emeraldOk : SageState.crimsonAlert

                                    Text {
                                        anchors.centerIn: parent
                                        text: !dashWindow.currentMonitor.disabled ? "STATUS: ENABLED [ON]" : "STATUS: DISABLED [OFF]"
                                        color: !dashWindow.currentMonitor.disabled ? SageState.emeraldOk : SageState.crimsonAlert
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: dashWindow.updateMonitorField(SageState.selectedMonitorIndex, "disabled", !dashWindow.currentMonitor.disabled)
                                    }
                                }

                                Rectangle {
                                    width: 195
                                    height: 34
                                    radius: 4
                                    readonly property bool isMirrored: dashWindow.currentMonitor.mirrorOf !== "none"
                                    color: isMirrored
                                           ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.20)
                                           : SageState.bgVoid
                                    border.width: 1
                                    border.color: isMirrored ? SageState.secondaryAccent : SageState.primaryAccent

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.isMirrored ? ("MIRRORING: " + dashWindow.currentMonitor.mirrorOf) : "MODE: EXTENDED DESKTOP"
                                        color: parent.isMirrored ? SageState.secondaryAccent : SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (SageState.monitorList.length > 1) {
                                                const primaryName = SageState.monitorList[0].name;
                                                const nextMirror = (dashWindow.currentMonitor.mirrorOf === "none" && dashWindow.currentMonitor.name !== primaryName)
                                                                   ? primaryName
                                                                   : "none";
                                                dashWindow.updateMonitorField(SageState.selectedMonitorIndex, "mirrorOf", nextMirror);
                                            }
                                        }
                                    }
                                }
                            }

                            // Direct Position Selector relative to Primary Monitor
                            Text {
                                text: "◈ POSITION RELATIVE TO PRIMARY (CURRENT: " + dashWindow.currentMonitor.x + ", " + dashWindow.currentMonitor.y + ")"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Row {
                                width: 400
                                height: 28
                                spacing: 6

                                Repeater {
                                    model: [
                                        { id: "origin", label: "0,0 ORIGIN" },
                                        { id: "right",  label: "RIGHT ▸" },
                                        { id: "left",   label: "◂ LEFT" },
                                        { id: "above",  label: "▲ ABOVE" },
                                        { id: "below",  label: "▼ BELOW" }
                                    ]

                                    Rectangle {
                                        id: posBtn
                                        required property var modelData
                                        width: 75.2
                                        height: 28
                                        radius: 4
                                        color: posMouse.containsMouse ? SageState.bgCardHover : SageState.bgVoid
                                        border.width: 1
                                        border.color: posMouse.containsMouse ? SageState.secondaryAccent : SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: posBtn.modelData.label
                                            color: posMouse.containsMouse ? SageState.secondaryAccent : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: posMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const idx = SageState.selectedMonitorIndex;
                                                const pMon = SageState.monitorList.length > 0 ? SageState.monitorList[0] : dashWindow.currentMonitor;
                                                const pW = Math.round((pMon.width || 1920) / Math.max(0.5, pMon.scale || 1.0));
                                                const pH = Math.round((pMon.height || 1080) / Math.max(0.5, pMon.scale || 1.0));
                                                const cW = Math.round((dashWindow.currentMonitor.width || 1920) / Math.max(0.5, dashWindow.currentMonitor.scale || 1.0));
                                                const cH = Math.round((dashWindow.currentMonitor.height || 1080) / Math.max(0.5, dashWindow.currentMonitor.scale || 1.0));
                                                if (posBtn.modelData.id === "origin") {
                                                    dashWindow.updateMonitorPos(idx, 0, 0);
                                                } else if (posBtn.modelData.id === "right") {
                                                    dashWindow.updateMonitorPos(idx, pW, 0);
                                                } else if (posBtn.modelData.id === "left") {
                                                    dashWindow.updateMonitorPos(idx, -cW, 0);
                                                } else if (posBtn.modelData.id === "above") {
                                                    dashWindow.updateMonitorPos(idx, 0, -cH);
                                                } else if (posBtn.modelData.id === "below") {
                                                    dashWindow.updateMonitorPos(idx, 0, pH);
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Scale Factor Selector
                            Text {
                                text: "◈ UI SCALING FACTOR (CURRENT: " + dashWindow.currentMonitor.scale + "x)"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Row {
                                width: 400
                                height: 28
                                spacing: 8

                                Repeater {
                                    model: [0.75, 1.0, 1.25, 1.5, 2.0]

                                    Rectangle {
                                        id: scaleBtn
                                        required property var modelData
                                        readonly property bool activeScale: Math.abs((dashWindow.currentMonitor.scale || 1.0) - modelData) < 0.05
                                        width: 73.6
                                        height: 28
                                        radius: 4
                                        color: activeScale
                                               ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.24)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: activeScale ? SageState.secondaryAccent : SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: scaleBtn.modelData + "x"
                                            color: scaleBtn.activeScale ? SageState.secondaryAccent : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: dashWindow.updateMonitorField(SageState.selectedMonitorIndex, "scale", scaleBtn.modelData)
                                        }
                                    }
                                }
                            }

                            // Rotation / Orientation Selector
                            Text {
                                text: "◈ ORIENTATION / ROTATION"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Row {
                                width: 400
                                height: 28
                                spacing: 8

                                Repeater {
                                    model: [
                                        { t: 0, label: "0° NORMAL" },
                                        { t: 1, label: "90° RIGHT" },
                                        { t: 2, label: "180° INVERT" },
                                        { t: 3, label: "270° LEFT" }
                                    ]

                                    Rectangle {
                                        id: rotBtn
                                        required property var modelData
                                        readonly property bool activeRot: (dashWindow.currentMonitor.transform || 0) === modelData.t
                                        width: 94
                                        height: 28
                                        radius: 4
                                        color: activeRot
                                               ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.24)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: activeRot ? SageState.secondaryAccent : SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: rotBtn.modelData.label
                                            color: rotBtn.activeRot ? SageState.secondaryAccent : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: dashWindow.updateMonitorField(SageState.selectedMonitorIndex, "transform", rotBtn.modelData.t)
                                        }
                                    }
                                }
                            }

                            // Detected Resolutions & Refresh Rates (EDID)
                            Text {
                                text: "◈ DETECTED RESOLUTIONS & REFRESH RATES (CLICK TO APPLY)"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Flickable {
                                width: 400
                                height: 142
                                contentHeight: modeCol.implicitHeight
                                clip: true

                                Column {
                                    id: modeCol
                                    width: 400
                                    spacing: 6

                                    Repeater {
                                        model: dashWindow.currentMonitor.modes

                                        Rectangle {
                                            id: modeRow
                                            required property var modelData
                                            readonly property string cleanMode: modelData.replace("Hz", "")
                                            readonly property bool isCurrentMode: modelData.indexOf(dashWindow.currentMonitor.width + "x" + dashWindow.currentMonitor.height + "@" + Math.floor(dashWindow.currentMonitor.refreshRate)) === 0
                                            width: 400
                                            height: 34
                                            radius: 4
                                            color: isCurrentMode
                                                   ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.18)
                                                   : (modeMouse.containsMouse ? SageState.bgCardHover : SageState.bgVoid)
                                            border.width: 1
                                            border.color: isCurrentMode ? SageState.emeraldOk : SageState.primaryAccent

                                            Item {
                                                anchors.fill: parent
                                                anchors.leftMargin: 12
                                                anchors.rightMargin: 12

                                                Text {
                                                    anchors.left: parent.left
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: "◈ " + modeRow.modelData
                                                    color: modeRow.isCurrentMode ? SageState.emeraldOk : SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                }

                                                Text {
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: modeRow.isCurrentMode ? "[ACTIVE MODE]" : "APPLY ▸"
                                                    color: modeRow.isCurrentMode ? SageState.emeraldOk : SageState.secondaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                }
                                            }

                                            MouseArea {
                                                id: modeMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: dashWindow.updateMonitorField(SageState.selectedMonitorIndex, "mode", modeRow.cleanMode)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // TAB 4: NETWORK & VPN MATRIX (507px + 18px + 507px = 1032px)
                // ═══════════════════════════════════════════════════════════════
                Row {
                    width: 1032
                    height: 540
                    visible: SageState.activeTab === 4
                    spacing: 18

                    SageFrame {
                        width: 507
                        height: 540
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        Column {
                            x: 18
                            y: 18
                            width: 471
                            spacing: 12

                            Item {
                                width: 471
                                height: 28
                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "◈ WIRELESS ACCESS POINTS (NMCLI)"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Rectangle {
                                    anchors.right: parent.right
                                    width: 115
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
                                width: 471
                                height: 460
                                contentHeight: wifiListCol.implicitHeight
                                clip: true

                                Column {
                                    id: wifiListCol
                                    width: 471
                                    spacing: 8

                                    Repeater {
                                        model: SageState.wifiNetworks

                                        Rectangle {
                                            id: wifiRow
                                            required property var modelData
                                            width: 471
                                            height: 44
                                            radius: 5
                                            color: modelData.active
                                                   ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.18)
                                                   : SageState.bgVoid
                                            border.width: 1
                                            border.color: modelData.active ? SageState.emeraldOk : SageState.primaryAccent

                                            Row {
                                                x: 14
                                                y: 12
                                                width: 443
                                                spacing: 12

                                                Text {
                                                    width: 46
                                                    text: wifiRow.modelData.signal + "%"
                                                    color: SageState.secondaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                }

                                                Text {
                                                    width: 290
                                                    text: wifiRow.modelData.ssid
                                                    color: SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    width: 82
                                                    horizontalAlignment: Text.AlignRight
                                                    text: wifiRow.modelData.active ? "CONNECTED" : "CONNECT ▸"
                                                    color: wifiRow.modelData.active ? SageState.emeraldOk : SageState.primaryAccent
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

                    SageFrame {
                        width: 507
                        height: 540
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent

                        Column {
                            x: 18
                            y: 18
                            width: 471
                            spacing: 12

                            Item {
                                width: 471
                                height: 28
                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "◈ BARRIER TUNNELS (WIREGUARD / VPN)"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Rectangle {
                                    anchors.right: parent.right
                                    width: 145
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
                                width: 471
                                text: "No VPN / WireGuard profiles configured in NetworkManager.\nClick 'NM CONNECTION GUI' above to import a WireGuard or OpenVPN profile."
                                color: SageState.textMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                            }

                            Flickable {
                                width: 471
                                height: 420
                                contentHeight: vpnListCol.implicitHeight
                                clip: true

                                Column {
                                    id: vpnListCol
                                    width: 471
                                    spacing: 8

                                    Repeater {
                                        model: SageState.vpnList

                                        Rectangle {
                                            id: vpnRow
                                            required property var modelData
                                            width: 471
                                            height: 48
                                            radius: 5
                                            color: modelData.active
                                                   ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.18)
                                                   : SageState.bgVoid
                                            border.width: 1
                                            border.color: modelData.active ? SageState.emeraldOk : SageState.secondaryAccent

                                            Item {
                                                anchors.fill: parent
                                                anchors.leftMargin: 14
                                                anchors.rightMargin: 14

                                                Text {
                                                    anchors.left: parent.left
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: vpnRow.modelData.name
                                                    color: SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                }

                                                Text {
                                                    anchors.right: parent.right
                                                    anchors.verticalCenter: parent.verticalCenter
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
                // TAB 5: KEYBINDS MATRIX (4 Columns: 249 * 4 + 12 * 3 = 1032px)
                // ═══════════════════════════════════════════════════════════════
                Row {
                    width: 1032
                    height: 540
                    visible: SageState.activeTab === 5
                    spacing: 12

                    SageFrame {
                        width: 249
                        height: 540
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        Column {
                            x: 14
                            y: 16
                            width: 221
                            spacing: 10

                            Text {
                                text: "◈ 01 // MENUS & APPS"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: [
                                    { k: "Super (Seul)", d: "Menu des Apps" },
                                    { k: "Super + M", d: "Central Dashboard" },
                                    { k: "Super + Shift + G", d: "Central Dashboard" },
                                    { k: "Super + Return / T", d: "Kitty Terminal" },
                                    { k: "Super + H / F1", d: "Keybinds Matrix" },
                                    { k: "Super + W", d: "Next Wallpaper" },
                                    { k: "Super + Shift + W", d: "Wallpaper Studio" },
                                    { k: "Super + E", d: "File Manager" },
                                    { k: "Super + Q", d: "Close Window" }
                                ]

                                Item {
                                    id: kbItem1
                                    required property var modelData
                                    width: 221
                                    height: 22
                                    Text {
                                        anchors.left: parent.left
                                        text: kbItem1.modelData.k
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        text: kbItem1.modelData.d
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }

                    SageFrame {
                        width: 249
                        height: 540
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent

                        Column {
                            x: 14
                            y: 16
                            width: 221
                            spacing: 10

                            Text {
                                text: "◈ 02 // SPECIAL WORKSPACES"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: SageState.specialWorkspaces

                                Item {
                                    id: kbSpecItem
                                    required property var modelData
                                    width: 221
                                    height: 22
                                    Text {
                                        anchors.left: parent.left
                                        text: kbSpecItem.modelData.bind
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        text: kbSpecItem.modelData.label
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                width: 221
                                height: 1
                                color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.3)
                            }

                            Text {
                                width: 221
                                text: "Special workspaces live behind normal workspaces and automatically summon their assigned app."
                                color: SageState.textMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    SageFrame {
                        width: 249
                        height: 540
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        Column {
                            x: 14
                            y: 16
                            width: 221
                            spacing: 10

                            Text {
                                text: "◈ 03 // WINDOWS & TILING"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: [
                                    { k: "Super + Espace", d: "Toggle Floating" },
                                    { k: "Super + 1..0", d: "Workspace 1..10" },
                                    { k: "Super + Shift + 1..0", d: "Move to WS 1..10" },
                                    { k: "Super + Arrows", d: "Focus Direction" },
                                    { k: "Super + F", d: "Fullscreen Mode" },
                                    { k: "Super + P", d: "Pseudo Tiling" },
                                    { k: "Super + J", d: "Toggle Split" },
                                    { k: "Super + Shift + M", d: "Exit Hyprland" }
                                ]

                                Item {
                                    id: kbItem3
                                    required property var modelData
                                    width: 221
                                    height: 22
                                    Text {
                                        anchors.left: parent.left
                                        text: kbItem3.modelData.k
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        text: kbItem3.modelData.d
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }

                    SageFrame {
                        width: 249
                        height: 540
                        chamfer: 10
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent

                        Column {
                            x: 14
                            y: 16
                            width: 221
                            spacing: 10

                            Text {
                                text: "◈ 04 // SYSTEM & CAPTURE"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: [
                                    { k: "Print", d: "Region Screenshot" },
                                    { k: "Shift + Print", d: "Full Screenshot" },
                                    { k: "Super + L", d: "Lock Screen" },
                                    { k: "Super + V", d: "Clipboard History" },
                                    { k: "AudioRaise/Lower", d: "Volume +/- 5%" },
                                    { k: "AudioMute", d: "Mute Audio" },
                                    { k: "MonBrightness", d: "Brightness +/- 5%" }
                                ]

                                Item {
                                    id: kbItem4
                                    required property var modelData
                                    width: 221
                                    height: 22
                                    Text {
                                        anchors.left: parent.left
                                        text: kbItem4.modelData.k
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        text: kbItem4.modelData.d
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
