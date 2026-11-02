import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: barWindow
        required property var modelData
        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 50
        color: "transparent"

        property bool showSpecialLayer: false
        readonly property string activeSpecialLabel: {
            const list = SageState.specialWorkspaces;
            for (let i = 0; i < list.length; ++i) {
                if (list[i].visible === true) {
                    return list[i].label !== undefined ? list[i].label : "SPECIAL";
                }
            }
            return "";
        }

        // ═══════════════════════════════════════════════════════════════════════
        // 1. LEFT ISLAND: RAPHAEL Emblem + Normal Workspaces (Special WS Hidden Behind)
        // ═══════════════════════════════════════════════════════════════════════
        SageFrame {
            id: leftIsland
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }
            height: 38
            width: leftRow.implicitWidth + 24
            chamfer: 9
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerBorder: true

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Row {
                id: leftRow
                anchors.centerIn: parent
                spacing: 8

                // Great Sage / Raphael Central Dashboard Trigger
                Rectangle {
                    height: 26
                    width: sageBtnRow.implicitWidth + 18
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.dashboardOpen
                           ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.25)
                           : (sageMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard)
                    border.width: 1
                    border.color: SageState.dashboardOpen ? SageState.secondaryAccent : SageState.primaryAccent

                    Row {
                        id: sageBtnRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "◈"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "RAPHAEL"
                            color: SageState.textPrimary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.2
                        }
                    }

                    MouseArea {
                        id: sageMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.toggleDashboard()
                    }
                }

                Rectangle {
                    width: 1
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)
                }

                // Normal Workspaces 1..6 (Special Workspaces hidden behind)
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !barWindow.showSpecialLayer

                    Repeater {
                        model: 6

                        Rectangle {
                            id: wsPill
                            required property int index
                            readonly property int wsId: index + 1
                            readonly property bool isFocused: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.id === wsId) : (wsId === 1)

                            height: 24
                            width: isFocused ? 30 : 22
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: isFocused
                                   ? SageState.primaryAccent
                                   : (wsHover.containsMouse ? SageState.bgCardHover : SageState.bgCard)
                            border.width: 1
                            border.color: isFocused
                                          ? SageState.secondaryAccent
                                          : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.3)

                            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                text: wsPill.wsId.toString()
                                color: wsPill.isFocused ? "#050911" : SageState.textPrimary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                id: wsHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsPill.wsId + " })")
                            }
                        }
                    }
                }

                // Active Special Workspace Indicator (When open over normal workspaces)
                Rectangle {
                    visible: !barWindow.showSpecialLayer && barWindow.activeSpecialLabel.length > 0
                    height: 24
                    width: actSpecText.implicitWidth + 16
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.25)
                    border.width: 1
                    border.color: SageState.secondaryAccent

                    Text {
                        id: actSpecText
                        anchors.centerIn: parent
                        text: "◈ " + barWindow.activeSpecialLabel
                        color: SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                // Hidden Special Workspaces Layer (Revealed when flipping behind normal workspaces)
                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    visible: barWindow.showSpecialLayer

                    Repeater {
                        model: SageState.specialWorkspaces

                        Rectangle {
                            id: specBadge
                            required property var modelData
                            readonly property bool isRunning: modelData.running === true
                            readonly property string codeText: modelData.short !== undefined && modelData.short.length > 0
                                                               ? modelData.short
                                                               : "SPC"

                            height: 24
                            width: specBadgeRow.implicitWidth + 14
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: isRunning
                                   ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.24)
                                   : SageState.bgCard
                            border.width: 1
                            border.color: isRunning ? SageState.secondaryAccent : SageState.primaryAccent

                            Row {
                                id: specBadgeRow
                                anchors.centerIn: parent
                                spacing: 4

                                Rectangle {
                                    width: 5
                                    height: 5
                                    radius: 2.5
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: specBadge.isRunning ? SageState.emeraldOk : SageState.textMuted
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: specBadge.codeText
                                    color: specBadge.isRunning ? SageState.secondaryAccent : SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SageState.toggleSpecialWs(specBadge.modelData.id)
                            }
                        }
                    }
                }

                // Flip Button to peek at hidden Special Workspaces behind normal ones
                Rectangle {
                    height: 24
                    width: 24
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: barWindow.showSpecialLayer ? SageState.secondaryAccent : SageState.bgCard
                    border.width: 1
                    border.color: SageState.secondaryAccent

                    Text {
                        anchors.centerIn: parent
                        text: barWindow.showSpecialLayer ? "◂" : "▸"
                        color: barWindow.showSpecialLayer ? "#050911" : SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barWindow.showSpecialLayer = !barWindow.showSpecialLayer
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // 2. CENTER ISLAND: Clock + Date + Media (Hover or Click opens Caelestia Top HUD)
        // ═══════════════════════════════════════════════════════════════════════
        SageFrame {
            id: centerIsland
            anchors.centerIn: parent
            height: 38
            width: centerRow.implicitWidth + 32
            chamfer: 9
            fillColor: SageState.topDropdownOpen ? SageState.bgCardHover : SageState.bgVoid
            borderColor: SageState.topDropdownOpen ? SageState.secondaryAccent : SageState.primaryAccent
            innerBorder: true

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Row {
                id: centerRow
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "◈"
                    color: SageState.secondaryAccent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: SageState.clockTime
                    color: SageState.textPrimary
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "//"
                    color: SageState.primaryAccent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: SageState.clockDate
                    color: SageState.secondaryAccent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    visible: SageState.mediaText.length > 0
                    height: 22
                    width: mediaLabel.implicitWidth + 14
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.16)
                    border.width: 1
                    border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.45)

                    Text {
                        id: mediaLabel
                        anchors.centerIn: parent
                        text: "▸ " + SageState.mediaText
                        color: SageState.primaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    if (!SageState.dashboardOpen && !SageState.launcherOpen) {
                        SageState.topDropdownOpen = true;
                        SageState.cornerMenuOpen = false;
                    }
                }
                onClicked: SageState.toggleTopDropdown()
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // 3. RIGHT ISLAND: Clean Telemetry + [ MENU ] Button -> Opens Dashboard
        // ═══════════════════════════════════════════════════════════════════════
        SageFrame {
            id: rightIsland
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            height: 38
            width: rightRow.implicitWidth + 26
            chamfer: 9
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerBorder: true

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Row {
                id: rightRow
                anchors.centerIn: parent
                spacing: 8

                // Background & System Tray Apps Logos Pill (Left of CPU)
                Rectangle {
                    readonly property int trayCount: SystemTray.items.values ? SystemTray.items.values.length : 0
                    readonly property var extraBgApps: {
                        const trayList = SystemTray.items.values || [];
                        const out = [];
                        for (let i = 0; i < SageState.runningApps.length; ++i) {
                            const app = SageState.runningApps[i];
                            const k = (app.id || "").toLowerCase();
                            let inTray = false;
                            for (let j = 0; j < trayList.length; ++j) {
                                const tid = ((trayList[j].id || "") + " " + (trayList[j].title || "") + " " + (trayList[j].tooltipTitle || "")).toLowerCase();
                                if (k.length > 0 && tid.indexOf(k) !== -1) {
                                    inTray = true;
                                    break;
                                }
                            }
                            if (!inTray) {
                                out.push(app);
                            }
                        }
                        return out;
                    }

                    visible: (trayCount + extraBgApps.length) > 0
                    height: 24
                    width: runningAppsRow.implicitWidth + 10
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.bgCard
                    border.width: 1
                    border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

                    Row {
                        id: runningAppsRow
                        anchors.centerIn: parent
                        spacing: 4

                        // 1. Native System Tray Apps (Discord closed to tray, Steam, Telegram, etc.)
                        Repeater {
                            model: SystemTray.items

                            Rectangle {
                                id: trayBadge
                                required property var modelData
                                width: 20
                                height: 20
                                radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: trayMouse.containsMouse
                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.25)
                                       : "transparent"
                                border.width: trayMouse.containsMouse ? 1 : 0
                                border.color: SageState.secondaryAccent

                                Image {
                                    anchors.centerIn: parent
                                    width: 15
                                    height: 15
                                    source: trayBadge.modelData.icon || ""
                                    smooth: true
                                    mipmap: true
                                    fillMode: Image.PreserveAspectFit
                                }

                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.rightMargin: 1
                                    anchors.bottomMargin: 1
                                    color: SageState.emeraldOk
                                }

                                MouseArea {
                                    id: trayMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        if (mouse.button === Qt.RightButton) {
                                            if (trayBadge.modelData.hasMenu) {
                                                const pos = trayBadge.mapToItem(null, 0, trayBadge.height + 4);
                                                trayBadge.modelData.display(barWindow, Math.round(pos.x), Math.round(pos.y));
                                            } else {
                                                trayBadge.modelData.secondaryActivate();
                                            }
                                        } else if (mouse.button === Qt.MiddleButton) {
                                            trayBadge.modelData.secondaryActivate();
                                        } else {
                                            if (trayBadge.modelData.onlyMenu && trayBadge.modelData.hasMenu) {
                                                const pos = trayBadge.mapToItem(null, 0, trayBadge.height + 4);
                                                trayBadge.modelData.display(barWindow, Math.round(pos.x), Math.round(pos.y));
                                            } else {
                                                trayBadge.modelData.activate();
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // 2. Fallback Background Daemons & Hidden Special Workspace Apps
                        Repeater {
                            model: parent.parent.extraBgApps

                            Rectangle {
                                id: appBadge
                                required property var modelData
                                width: 20
                                height: 20
                                radius: 4
                                anchors.verticalCenter: parent.verticalCenter
                                color: appMouse.containsMouse
                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.25)
                                       : "transparent"
                                border.width: appMouse.containsMouse ? 1 : 0
                                border.color: SageState.secondaryAccent

                                Image {
                                    id: appLogoImg
                                    anchors.centerIn: parent
                                    width: 15
                                    height: 15
                                    source: appBadge.modelData.icon && appBadge.modelData.icon.length > 0
                                            ? ("file://" + appBadge.modelData.icon)
                                            : ""
                                    visible: status === Image.Ready
                                    smooth: true
                                    mipmap: true
                                    fillMode: Image.PreserveAspectFit
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: !appLogoImg.visible
                                    text: (appBadge.modelData.name || appBadge.modelData.id || "?").slice(0, 2).toUpperCase()
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 8
                                    font.bold: true
                                }

                                // Status dot (Gold = Special Workspace, Emerald = Background Tray)
                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.rightMargin: 1
                                    anchors.bottomMargin: 1
                                    color: appBadge.modelData.isSpecial
                                           ? SageState.secondaryAccent
                                           : SageState.emeraldOk
                                }

                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.focusRunningApp(appBadge.modelData)
                                }
                            }
                        }
                    }
                }

                // CPU + RAM Pill
                Rectangle {
                    height: 24
                    width: sysRow.implicitWidth + 16
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.bgCard
                    border.width: 1
                    border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

                    Row {
                        id: sysRow
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "CPU " + SageState.cpuUsage + "%"
                            color: SageState.cpuUsage > 80 ? SageState.crimsonAlert : SageState.primaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "|"
                            color: SageState.textMuted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "RAM " + SageState.ramUsage + "%"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.toggleSpecialWs("sysmon")
                    }
                }

                // VPN Badge
                Rectangle {
                    visible: SageState.vpnActive
                    height: 24
                    width: vpnText.implicitWidth + 14
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.18)
                    border.width: 1
                    border.color: SageState.emeraldOk

                    Text {
                        id: vpnText
                        anchors.centerIn: parent
                        text: "VPN ON"
                        color: SageState.emeraldOk
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.openDashboardTab(4)
                    }
                }

                // Volume Pill
                Rectangle {
                    height: 24
                    width: volText.implicitWidth + 14
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.bgCard
                    border.width: 1
                    border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

                    Text {
                        id: volText
                        anchors.centerIn: parent
                        text: SageState.muted ? "MUTE" : ("VOL " + SageState.volume + "%")
                        color: SageState.muted ? SageState.crimsonAlert : SageState.textPrimary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.runCmd([SageState.ctlScript, "vol-mute"])
                        onWheel: function(wheel) {
                            const step = wheel.angleDelta.y > 0 ? 5 : -5;
                            const nextVol = Math.max(0, Math.min(100, SageState.volume + step));
                            SageState.volume = nextVol;
                            SageState.runCmd([SageState.ctlScript, "vol-set", nextVol.toString()]);
                        }
                    }
                }

                // Battery Pill
                Rectangle {
                    height: 24
                    width: batText.implicitWidth + 14
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.bgCard
                    border.width: 1
                    border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

                    Text {
                        id: batText
                        anchors.centerIn: parent
                        text: (SageState.batStatus === "Charging" || SageState.batStatus === "Full" ? "AC " : "BAT ") + SageState.batPercent + "%"
                        color: SageState.batPercent <= 20 && SageState.batStatus === "Discharging"
                               ? SageState.crimsonAlert
                               : SageState.emeraldOk
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                // Power Mode Pill (ECO / BAL / PERF) with Vector Logo & Click-to-Cycle
                Rectangle {
                    id: pwrPill
                    height: 24
                    width: pwrRow.implicitWidth + 14
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    readonly property color modeColor: {
                        if (SageState.powerProfile === "power-saver") return SageState.emeraldOk;
                        if (SageState.powerProfile === "performance") return SageState.secondaryAccent;
                        return SageState.primaryAccent;
                    }
                    color: pwrMouse.containsMouse
                           ? Qt.rgba(modeColor.r, modeColor.g, modeColor.b, 0.22)
                           : SageState.bgCard
                    border.width: 1
                    border.color: Qt.rgba(modeColor.r, modeColor.g, modeColor.b, pwrMouse.containsMouse ? 0.85 : 0.45)

                    Row {
                        id: pwrRow
                        anchors.centerIn: parent
                        spacing: 5

                        // Custom Vector Mode Logo (Leaf for Eco, Diamond Core for Balanced, Lightning Bolt for Perf)
                        Canvas {
                            id: pwrIconCanvas
                            width: 12
                            height: 12
                            anchors.verticalCenter: parent.verticalCenter
                            property string currentMode: SageState.powerProfile
                            property color iconColor: pwrPill.modeColor
                            onCurrentModeChanged: requestPaint()
                            onIconColorChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.fillStyle = iconColor.toString();
                                ctx.strokeStyle = iconColor.toString();
                                ctx.lineWidth = 1.4;

                                if (currentMode === "power-saver") {
                                    // Eco Leaf / Crescent Rune
                                    ctx.beginPath();
                                    ctx.moveTo(2, 10);
                                    ctx.quadraticCurveTo(2, 2, 10, 2);
                                    ctx.quadraticCurveTo(10, 10, 2, 10);
                                    ctx.closePath();
                                    ctx.stroke();
                                    ctx.beginPath();
                                    ctx.moveTo(2, 10);
                                    ctx.lineTo(8, 4);
                                    ctx.stroke();
                                } else if (currentMode === "performance") {
                                    // Performance Lightning Bolt
                                    ctx.beginPath();
                                    ctx.moveTo(7, 1);
                                    ctx.lineTo(2, 6.8);
                                    ctx.lineTo(5.8, 6.8);
                                    ctx.lineTo(4.8, 11);
                                    ctx.lineTo(10, 5.2);
                                    ctx.lineTo(6.2, 5.2);
                                    ctx.closePath();
                                    ctx.fill();
                                } else {
                                    // Balanced Octagonal / Diamond Core
                                    ctx.beginPath();
                                    ctx.moveTo(6, 1);
                                    ctx.lineTo(11, 6);
                                    ctx.lineTo(6, 11);
                                    ctx.lineTo(1, 6);
                                    ctx.closePath();
                                    ctx.stroke();
                                    ctx.beginPath();
                                    ctx.arc(6, 6, 1.8, 0, Math.PI * 2);
                                    ctx.fill();
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: {
                                if (SageState.powerProfile === "power-saver") return "ECO";
                                if (SageState.powerProfile === "performance") return "PERF";
                                return "BAL";
                            }
                            color: pwrPill.modeColor
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: pwrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.cyclePowerProfile()
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y !== 0) {
                                SageState.cyclePowerProfile();
                            }
                        }
                    }
                }

                // Keyboard Layout Pill -> Opens the Keyboard Selector List in Tab 03
                Rectangle {
                    height: 24
                    width: kbText.implicitWidth + 14
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.bgCard
                    border.width: 1
                    border.color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.45)

                    Text {
                        id: kbText
                        anchors.centerIn: parent
                        text: SageState.kbLayout.toUpperCase()
                        color: SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.openDashboardTab(2)
                    }
                }

                // Keybinds Cheat Sheet Trigger [ ? ]
                Rectangle {
                    height: 24
                    width: 24
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: (SageState.dashboardOpen && SageState.activeTab === 5)
                           ? SageState.secondaryAccent
                           : SageState.bgCard
                    border.width: 1
                    border.color: SageState.secondaryAccent

                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        color: (SageState.dashboardOpen && SageState.activeTab === 5) ? "#050911" : SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.openDashboardTab(5)
                    }
                }

                // [ MENU ] Button -> Opens the Central Dashboard
                Rectangle {
                    height: 24
                    width: menuBtnLabel.implicitWidth + 16
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.dashboardOpen ? SageState.primaryAccent : SageState.bgCard
                    border.width: 1
                    border.color: SageState.primaryAccent

                    Text {
                        id: menuBtnLabel
                        anchors.centerIn: parent
                        text: "MENU"
                        color: SageState.dashboardOpen ? "#050911" : SageState.primaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.toggleDashboard()
                    }
                }
            }
        }
    }
}
