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
        property bool rightCollapsed: false
        readonly property bool compactBar: barWindow.width < 1640
        readonly property bool miniBar: barWindow.width < 1380
        readonly property string activeSpecialId: {
            const sName = barWindow.screen ? barWindow.screen.name : "";
            if (!sName) return "";
            const raw = (SageState.monitorSpecialWorkspaces && SageState.monitorSpecialWorkspaces[sName])
                ? SageState.monitorSpecialWorkspaces[sName]
                : "";
            if (raw.startsWith("special:")) return raw.substring(8);
            return raw;
        }
        readonly property string activeSpecialLabel: {
            if (!barWindow.activeSpecialId) return "";
            const list = SageState.specialWorkspaces;
            for (let i = 0; i < list.length; ++i) {
                if (list[i].id === barWindow.activeSpecialId) {
                    return list[i].label !== undefined ? list[i].label : list[i].id.toUpperCase();
                }
            }
            return barWindow.activeSpecialId.toUpperCase();
        }
        readonly property bool inSpecialView: barWindow.showSpecialLayer || barWindow.activeSpecialId.length > 0

        readonly property var hyprMonitor: {
            if (!Hyprland.monitors || !Hyprland.monitors.values) return null;
            const scrName = barWindow.screen ? barWindow.screen.name : "";
            const mons = Hyprland.monitors.values;
            for (let i = 0; i < mons.length; ++i) {
                if (mons[i] && mons[i].name === scrName) {
                    return mons[i];
                }
            }
            return null;
        }

        readonly property int monitorActiveWsId: {
            // 1. From Quickshell HyprlandMonitor
            if (barWindow.hyprMonitor && barWindow.hyprMonitor.activeWorkspace && barWindow.hyprMonitor.activeWorkspace.id > 0) {
                return barWindow.hyprMonitor.activeWorkspace.id;
            }
            // 2. From SageState tracking map if available
            const scrName = barWindow.screen ? barWindow.screen.name : "";
            if (SageState.monitorActiveWorkspaces && SageState.monitorActiveWorkspaces[scrName]) {
                return SageState.monitorActiveWorkspaces[scrName];
            }
            // 3. Fallback: if this monitor is globally focused, use Hyprland.focusedWorkspace
            if (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id > 0) {
                if (Quickshell.screens.length <= 1 || (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === scrName)) {
                    return Hyprland.focusedWorkspace.id;
                }
            }
            // 4. Fallback default by screen order (screen 0 -> 1, screen 1 -> 6)
            if (Quickshell.screens.length > 1) {
                for (let s = 0; s < Quickshell.screens.length; ++s) {
                    if (Quickshell.screens[s].name === scrName) {
                        return s === 0 ? 1 : 6;
                    }
                }
            }
            return 1;
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

                // Great Sage / Raphael Mode Switcher (Toggles Normal vs Special Workspaces view; Right-click opens Dashboard)
                Rectangle {
                    height: 26
                    width: sageBtnRow.implicitWidth + 18
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: barWindow.inSpecialView
                           ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.28)
                           : (sageMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard)
                    border.width: 1
                    border.color: barWindow.inSpecialView ? SageState.secondaryAccent : SageState.primaryAccent

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
                            text: barWindow.inSpecialView ? "RAPHAEL ◈ SPC" : "RAPHAEL"
                            color: barWindow.inSpecialView ? SageState.secondaryAccent : SageState.textPrimary
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
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) {
                                SageState.toggleDashboard(barWindow.modelData.name);
                            } else {
                                if (barWindow.activeSpecialId.length > 0) {
                                    SageState.toggleSpecialWs(barWindow.activeSpecialId);
                                    barWindow.showSpecialLayer = false;
                                } else {
                                    barWindow.showSpecialLayer = !barWindow.showSpecialLayer;
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)
                }

                // 1A. Normal Workspaces 1..6 (ONLY shown when no Special Workspace is active & layer not flipped)
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !barWindow.inSpecialView

                    Repeater {
                        model: 6

                        Rectangle {
                            id: wsPill
                            required property int index

                            // Workspaces 1..5 in slots 0..4.
                            // In slot 5 (index 5): displays workspace 6 by default, OR displays any active workspace > 6 on this screen!
                            readonly property int wsId: (index === 5 && barWindow.monitorActiveWsId > 6)
                                                         ? barWindow.monitorActiveWsId
                                                         : (index + 1)

                            // Active on THIS screen independently of other screens!
                            readonly property bool isCurrentScreenActive: (wsId === barWindow.monitorActiveWsId)
                            readonly property bool isFocused: isCurrentScreenActive
                            readonly property string appEmblem: (SageState.workspaceIcons && SageState.workspaceIcons[wsId.toString()])
                                                                ? SageState.workspaceIcons[wsId.toString()]
                                                                : ""
                            readonly property bool hasApp: appEmblem.length > 0

                            height: 24
                            width: hasApp ? (isFocused ? 42 : 38) : (isFocused ? 28 : 22)
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: isFocused
                                   ? SageState.primaryAccent
                                   : (wsHover.containsMouse ? SageState.bgCardHover : SageState.bgCard)
                            border.width: 1
                            border.color: isFocused
                                          ? SageState.secondaryAccent
                                          : (hasApp
                                             ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.55)
                                             : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.3))

                            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 3

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: wsPill.wsId.toString()
                                    color: wsPill.isFocused ? "#050911" : SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                // Slime / Tensura-Style Vector App Emblem next to Workspace Number
                                Canvas {
                                    id: wsEmblemCanvas
                                    visible: wsPill.hasApp
                                    width: 14
                                    height: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    property string emblemKind: wsPill.appEmblem
                                    property bool pillFocused: wsPill.isFocused
                                    property color fgColor: wsPill.isFocused ? "#050911" : SageState.secondaryAccent
                                    property color subColor: wsPill.isFocused ? "#0a1929" : SageState.primaryAccent
                                    onEmblemKindChanged: requestPaint()
                                    onPillFocusedChanged: requestPaint()
                                    onFgColorChanged: requestPaint()

                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = fgColor.toString();
                                        ctx.fillStyle = fgColor.toString();
                                        ctx.lineWidth = 1.35;

                                        // Helper to draw Rimuru Slime body silhouette
                                        function drawSlimeBody(cyOffset) {
                                            var oy = cyOffset || 0;
                                            ctx.beginPath();
                                            ctx.moveTo(7, 2.2 + oy);
                                            ctx.bezierCurveTo(11.5, 4.2 + oy, 13.2, 8.2 + oy, 12.2, 11.2 + oy);
                                            ctx.bezierCurveTo(11.3, 12.8 + oy, 2.7, 12.8 + oy, 1.8, 11.2 + oy);
                                            ctx.bezierCurveTo(0.8, 8.2 + oy, 2.5, 4.2 + oy, 7, 2.2 + oy);
                                            ctx.closePath();
                                            ctx.stroke();
                                        }

                                        if (emblemKind === "code") {
                                            // Great Sage Octagonal Magic Circle + < > Code Rune
                                            ctx.beginPath();
                                            for (var i = 0; i < 8; ++i) {
                                                var ang = (i * Math.PI / 4) - (Math.PI / 8);
                                                var rx = 7 + 5.8 * Math.cos(ang);
                                                var ry = 7 + 5.8 * Math.sin(ang);
                                                if (i === 0) ctx.moveTo(rx, ry);
                                                else ctx.lineTo(rx, ry);
                                            }
                                            ctx.closePath();
                                            ctx.stroke();
                                            // < > brackets inside magic circle
                                            ctx.beginPath();
                                            ctx.moveTo(5.6, 5.0);
                                            ctx.lineTo(3.6, 7.0);
                                            ctx.lineTo(5.6, 9.0);
                                            ctx.moveTo(8.4, 5.0);
                                            ctx.lineTo(10.4, 7.0);
                                            ctx.lineTo(8.4, 9.0);
                                            ctx.stroke();
                                        } else if (emblemKind === "browser") {
                                            // Rimuru Slime + Dimensional Web Globe / Meridian
                                            drawSlimeBody(0.5);
                                            ctx.beginPath();
                                            ctx.moveTo(2.4, 8.2);
                                            ctx.lineTo(11.6, 8.2);
                                            ctx.moveTo(7.0, 2.8);
                                            ctx.lineTo(7.0, 12.2);
                                            ctx.stroke();
                                        } else if (emblemKind === "terminal") {
                                            // Rimuru Slime + >_ Command Rune
                                            drawSlimeBody(0.4);
                                            ctx.beginPath();
                                            ctx.moveTo(4.2, 6.8);
                                            ctx.lineTo(6.5, 8.5);
                                            ctx.lineTo(4.2, 10.2);
                                            ctx.moveTo(7.4, 10.2);
                                            ctx.lineTo(9.8, 10.2);
                                            ctx.stroke();
                                        } else if (emblemKind === "chat") {
                                            // Telepathy Slime (Rimuru Slime + Speech Wave / Controller Eyes)
                                            drawSlimeBody(0.8);
                                            ctx.fillRect(4.6, 7.4, 1.3, 2.2);
                                            ctx.fillRect(8.1, 7.4, 1.3, 2.2);
                                            // Telepathy arc above slime
                                            ctx.beginPath();
                                            ctx.arc(7, 2.4, 2.2, Math.PI * 1.15, Math.PI * 1.85);
                                            ctx.stroke();
                                        } else if (emblemKind === "media") {
                                            // Sonic Slime / Musical Aura Note
                                            drawSlimeBody(0.8);
                                            ctx.beginPath();
                                            ctx.arc(5.8, 9.2, 1.3, 0, Math.PI * 2);
                                            ctx.fill();
                                            ctx.beginPath();
                                            ctx.moveTo(7.0, 9.2);
                                            ctx.lineTo(7.0, 4.8);
                                            ctx.lineTo(9.8, 5.8);
                                            ctx.stroke();
                                        } else if (emblemKind === "game") {
                                            // Demon Lord Crossed Blades / Game Crest
                                            drawSlimeBody(0.6);
                                            ctx.beginPath();
                                            ctx.moveTo(4.4, 6.4);
                                            ctx.lineTo(9.6, 10.6);
                                            ctx.moveTo(9.6, 6.4);
                                            ctx.lineTo(4.4, 10.6);
                                            ctx.stroke();
                                        } else if (emblemKind === "files") {
                                            // Spatial Storage Magic Cube inside Slime
                                            drawSlimeBody(0.6);
                                            ctx.strokeRect(4.8, 6.6, 4.4, 3.6);
                                        } else {
                                            // Classic Rimuru Tempest Slime with iconic | | eyes
                                            drawSlimeBody(0.5);
                                            ctx.beginPath();
                                            ctx.moveTo(5.2, 6.8);
                                            ctx.lineTo(5.2, 9.6);
                                            ctx.moveTo(8.8, 6.8);
                                            ctx.lineTo(8.8, 9.6);
                                            ctx.stroke();
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: wsHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SageState.switchNormalWorkspace(wsPill.wsId)
                                onWheel: (wheel) => {
                                    if (wheel.angleDelta.y > 0) {
                                        SageState.switchNormalWorkspace(Math.max(1, barWindow.monitorActiveWsId - 1));
                                    } else if (wheel.angleDelta.y < 0) {
                                        SageState.switchNormalWorkspace(Math.min(10, barWindow.monitorActiveWsId + 1));
                                    }
                                }
                            }
                        }
                    }
                }

                // 1B. Unified Special Workspaces Layer (Replaces normal workspaces when inSpecialView is active)
                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    visible: barWindow.inSpecialView

                    Repeater {
                        model: SageState.specialWorkspaces

                        Rectangle {
                            id: specBadge
                            required property var modelData
                            readonly property bool isRunning: modelData.running === true
                            readonly property bool isVisibleNow: modelData.id === barWindow.activeSpecialId
                            readonly property string codeText: modelData.label !== undefined && modelData.label.length > 0
                                                               ? modelData.label
                                                               : (modelData.short || "SPC")

                            height: 24
                            width: specBadgeRow.implicitWidth + 14
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: isVisibleNow
                                   ? SageState.secondaryAccent
                                   : (isRunning
                                      ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.24)
                                      : (specMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard))
                            border.width: isVisibleNow ? 1.5 : 1
                            border.color: (isVisibleNow || isRunning) ? SageState.secondaryAccent : SageState.primaryAccent

                            Row {
                                id: specBadgeRow
                                anchors.centerIn: parent
                                spacing: 4

                                Rectangle {
                                    width: 5
                                    height: 5
                                    radius: 2.5
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: specBadge.isVisibleNow
                                           ? "#050911"
                                           : (specBadge.isRunning ? SageState.emeraldOk : SageState.textMuted)
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: specBadge.codeText
                                    color: specBadge.isVisibleNow
                                           ? "#050911"
                                           : (specBadge.isRunning ? SageState.secondaryAccent : SageState.textPrimary)
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Text {
                                    visible: specBadge.isVisibleNow
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "✕"
                                    color: "#050911"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                id: specMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (specBadge.isVisibleNow) {
                                        SageState.toggleSpecialWs(specBadge.modelData.id);
                                        barWindow.showSpecialLayer = false;
                                    } else {
                                        SageState.toggleSpecialWs(specBadge.modelData.id);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // 2. CENTER ISLAND: Clock + Date + Media (Click opens Caelestia Top HUD)
        //    Automatically shifts into safe free space if screen is small so it NEVER overlaps!
        // ═══════════════════════════════════════════════════════════════════════
        SageFrame {
            id: centerIsland
            readonly property real idealX: (barWindow.width - width) / 2
            readonly property real minSafeX: leftIsland.x + leftIsland.width + 8
            readonly property real maxSafeX: rightIsland.x - width - 8
            x: (maxSafeX >= minSafeX) ? Math.max(minSafeX, Math.min(maxSafeX, idealX)) : idealX
            anchors.verticalCenter: parent.verticalCenter
            height: 38
            width: centerRow.implicitWidth + (barWindow.compactBar ? 22 : 32)
            chamfer: 9
            fillColor: SageState.topDropdownOpen ? SageState.bgCardHover : SageState.bgVoid
            borderColor: SageState.topDropdownOpen ? SageState.secondaryAccent : SageState.primaryAccent
            innerBorder: true

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Row {
                id: centerRow
                anchors.centerIn: parent
                spacing: barWindow.compactBar ? 6 : 10

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
                    font.pixelSize: barWindow.compactBar ? 12 : 13
                    font.bold: true
                }

                Text {
                    visible: !barWindow.miniBar
                    anchors.verticalCenter: parent.verticalCenter
                    text: "//"
                    color: SageState.primaryAccent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    visible: !barWindow.miniBar
                    anchors.verticalCenter: parent.verticalCenter
                    text: SageState.clockDate
                    color: SageState.secondaryAccent
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    visible: SageState.mediaText.length > 0 && !barWindow.compactBar
                    height: 22
                    width: Math.min(180, mediaLabel.implicitWidth + 14)
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.16)
                    border.width: 1
                    border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.45)

                    Text {
                        id: mediaLabel
                        width: Math.min(166, implicitWidth)
                        anchors.centerIn: parent
                        text: "▸ " + SageState.mediaText
                        color: SageState.primaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                        elide: Text.ElideRight
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: SageState.toggleTopDropdown(barWindow.modelData.name)
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // 3. RIGHT ISLAND: Clean Telemetry + Collapsible Toggle + [ MENU ] Button
        // ═══════════════════════════════════════════════════════════════════════
        SageFrame {
            id: rightIsland
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            height: 38
            width: rightRow.implicitWidth + (barWindow.compactBar ? 18 : 26)
            chamfer: 9
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerBorder: true

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Row {
                id: rightRow
                anchors.centerIn: parent
                spacing: barWindow.compactBar ? 5 : 8

                // Collapse / Expand Button [ ▸ / ◂ ] to manually shrink/expand the top-right bar
                Rectangle {
                    height: 24
                    width: 20
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: barWindow.rightCollapsed ? SageState.secondaryAccent : SageState.bgCard
                    border.width: 1
                    border.color: SageState.secondaryAccent

                    Text {
                        anchors.centerIn: parent
                        text: barWindow.rightCollapsed ? "◂" : "▸"
                        color: barWindow.rightCollapsed ? "#050911" : SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barWindow.rightCollapsed = !barWindow.rightCollapsed
                    }
                }

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
                                        if (mouse.button === Qt.MiddleButton) {
                                            trayBadge.modelData.activate();
                                        } else {
                                            SageState.openTrayPopup(barWindow.modelData.name, trayBadge.modelData, null);
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
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        if (mouse.button === Qt.RightButton) {
                                            SageState.openTrayPopup(barWindow.modelData.name, null, appBadge.modelData);
                                        } else {
                                            SageState.openTrayPopup(barWindow.modelData.name, null, appBadge.modelData);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // VPN Badge
                Rectangle {
                    visible: SageState.vpnActive && !barWindow.rightCollapsed
                    height: 24
                    width: vpnText.implicitWidth + (barWindow.compactBar ? 10 : 14)
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.18)
                    border.width: 1
                    border.color: SageState.emeraldOk

                    Text {
                        id: vpnText
                        anchors.centerIn: parent
                        text: barWindow.compactBar ? "VPN" : "VPN ON"
                        color: SageState.emeraldOk
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.openDashboardTab(4, barWindow.modelData.name)
                    }
                }

                // Volume Pill
                Rectangle {
                    visible: !barWindow.rightCollapsed
                    height: 24
                    width: volText.implicitWidth + (barWindow.compactBar ? 10 : 14)
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.bgCard
                    border.width: 1
                    border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

                    Text {
                        id: volText
                        anchors.centerIn: parent
                        text: SageState.muted ? "MUTE" : ((barWindow.compactBar ? "V " : "VOL ") + SageState.volume + "%")
                        color: SageState.muted ? SageState.crimsonAlert : SageState.textPrimary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: barWindow.compactBar ? 10 : 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.toggleSideSliders(barWindow.modelData.name)
                        onWheel: function(wheel) {
                            const step = wheel.angleDelta.y > 0 ? 5 : -5;
                            const nextVol = Math.max(0, Math.min(100, SageState.volume + step));
                            SageState.setVolumeValue(nextVol);
                        }
                    }
                }

                // Battery Pill
                Rectangle {
                    visible: !barWindow.rightCollapsed
                    height: 24
                    width: batText.implicitWidth + (barWindow.compactBar ? 10 : 14)
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.bgCard
                    border.width: 1
                    border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

                    Text {
                        id: batText
                        anchors.centerIn: parent
                        text: (barWindow.compactBar ? "" : (SageState.batStatus === "Charging" || SageState.batStatus === "Full" ? "AC " : "BAT ")) + SageState.batPercent + "%"
                        color: SageState.batPercent <= 20 && SageState.batStatus === "Discharging"
                               ? SageState.crimsonAlert
                               : SageState.emeraldOk
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: barWindow.compactBar ? 10 : 11
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
                    visible: !barWindow.rightCollapsed
                    height: 24
                    width: kbText.implicitWidth + (barWindow.compactBar ? 10 : 14)
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
                        font.pixelSize: barWindow.compactBar ? 10 : 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.openDashboardTab(2, barWindow.modelData.name)
                    }
                }

                // Keybinds Cheat Sheet Trigger [ ? ]
                Rectangle {
                    visible: !barWindow.rightCollapsed && !barWindow.compactBar
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
                        onClicked: SageState.openDashboardTab(5, barWindow.modelData.name)
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
                        onClicked: SageState.toggleDashboard(barWindow.modelData.name)
                    }
                }
            }
        }
    }
}
