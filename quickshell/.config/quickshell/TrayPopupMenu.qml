import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: trayPopupWindow
        required property var modelData
        screen: modelData

        visible: SageState.trayMenuOpen && SageState.isActiveScreen(trayPopupWindow.modelData)
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: (SageState.trayMenuOpen && SageState.isActiveScreen(trayPopupWindow.modelData))
                                     ? WlrKeyboardFocus.OnDemand
                                     : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        // Read DBusMenu entries from the active SystemTrayItem so we never use the ugly default OS popup
        QsMenuOpener {
            id: menuOpener
            menu: (SageState.activeTrayItem && SageState.activeTrayItem.hasMenu)
                  ? SageState.activeTrayItem.menu
                  : null
        }

        readonly property string appTitle: {
            if (SageState.activeTrayItem) {
                const t = SageState.activeTrayItem.tooltipTitle || SageState.activeTrayItem.title || SageState.activeTrayItem.id || "Background App";
                return t.toUpperCase();
            }
            if (SageState.activeBgApp) {
                return (SageState.activeBgApp.name || SageState.activeBgApp.id || "Background App").toUpperCase();
            }
            return "BACKGROUND APP";
        }

        readonly property string appKey: {
            if (SageState.activeBgApp && SageState.activeBgApp.id) {
                return SageState.activeBgApp.id.toLowerCase();
            }
            if (SageState.activeTrayItem) {
                const raw = ((SageState.activeTrayItem.id || "") + " " + (SageState.activeTrayItem.title || "") + " " + (SageState.activeTrayItem.tooltipTitle || "")).toLowerCase();
                if (raw.indexOf("discord") !== -1) return "discord";
                if (raw.indexOf("vesktop") !== -1) return "vesktop";
                if (raw.indexOf("spotify") !== -1) return "spotify";
                if (raw.indexOf("steam") !== -1) return "steam";
                if (raw.indexOf("telegram") !== -1) return "telegram-desktop";
                if (raw.indexOf("qbittorrent") !== -1) return "qbittorrent";
                if (raw.indexOf("obs") !== -1) return "obs";
                return (SageState.activeTrayItem.id || "").toLowerCase();
            }
            return "";
        }

        readonly property string inferredSpecialWs: {
            if (SageState.activeBgApp && SageState.activeBgApp.specialId) {
                return SageState.activeBgApp.specialId;
            }
            if (appKey === "discord" || appKey === "vesktop") return "chat";
            if (appKey === "spotify") return "music";
            return "";
        }

        readonly property string appIconSource: {
            if (SageState.activeTrayItem && SageState.activeTrayItem.icon) {
                return SageState.activeTrayItem.icon;
            }
            if (SageState.activeBgApp && SageState.activeBgApp.icon && SageState.activeBgApp.icon.length > 0) {
                return "file://" + SageState.activeBgApp.icon;
            }
            return "";
        }

        // Click anywhere outside the popover to close
        MouseArea {
            anchors.fill: parent
            onClicked: SageState.trayMenuOpen = false
        }

        // Caelestia-Style Background App & System Tray Popover Card
        SageFrame {
            id: trayCard
            width: 320
            height: cardCol.implicitHeight + 36
            anchors {
                top: parent.top
                topMargin: 48
                right: parent.right
                rightMargin: 110
            }
            chamfer: 14
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerColor: SageState.secondaryAccent
            borderWidth: 2.0
            innerBorder: true
            cornerDiamonds: true
            showMagicCircle: true
            magicCircleAlpha: 0.08

            MouseArea {
                anchors.fill: parent
            }

            Column {
                id: cardCol
                x: 18
                y: 18
                width: 284
                spacing: 10

                // 1. Application Header (Logo + Name + Close Button)
                Row {
                    width: 284
                    height: 40
                    spacing: 12

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 6
                        anchors.verticalCenter: parent.verticalCenter
                        color: SageState.bgCard
                        border.width: 1
                        border.color: SageState.secondaryAccent

                        Image {
                            id: headerIcon
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: trayPopupWindow.appIconSource
                            visible: status === Image.Ready
                            smooth: true
                            mipmap: true
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !headerIcon.visible
                            text: trayPopupWindow.appTitle.slice(0, 2)
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }

                    Column {
                        width: 196
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            width: 196
                            text: "◈ " + trayPopupWindow.appTitle
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            width: 196
                            text: "BACKGROUND DAEMON // ACTIVE"
                            color: SageState.emeraldOk
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 26
                        height: 26
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: closeHover.containsMouse ? SageState.bgCardHover : SageState.bgCard
                        border.width: 1
                        border.color: SageState.primaryAccent

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: SageState.textPrimary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        MouseArea {
                            id: closeHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SageState.trayMenuOpen = false
                        }
                    }
                }

                // Glowing Separator
                Rectangle {
                    width: 284
                    height: 1
                    color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)
                }

                // 2. Primary Action: Open / Restore Window or Toggle Special Workspace
                Rectangle {
                    width: 284
                    height: 36
                    radius: 5
                    color: openAppMouse.containsMouse
                           ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.28)
                           : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.14)
                    border.width: 1.5
                    border.color: openAppMouse.containsMouse ? SageState.secondaryAccent : SageState.primaryAccent

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

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
                            text: trayPopupWindow.inferredSpecialWs.length > 0
                                  ? ("OPEN SPECIAL WORKSPACE (" + trayPopupWindow.inferredSpecialWs.toUpperCase() + ")")
                                  : "OPEN / RESTORE APPLICATION"
                            color: SageState.textPrimary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: openAppMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            SageState.trayMenuOpen = false;
                            if (trayPopupWindow.inferredSpecialWs.length > 0) {
                                SageState.toggleSpecialWs(trayPopupWindow.inferredSpecialWs);
                            } else if (SageState.activeBgApp) {
                                SageState.focusRunningApp(SageState.activeBgApp);
                            } else if (SageState.activeTrayItem) {
                                SageState.activeTrayItem.activate();
                            }
                        }
                    }
                }

                // 3. Native DBusMenu Items Rendered in Custom Caelestia / Great Sage Style
                Column {
                    width: 284
                    spacing: 5
                    visible: menuOpener.children && menuOpener.children.values && menuOpener.children.values.length > 0

                    Text {
                        text: "◈ APPLICATION TRAY CONTROLS"
                        color: SageState.textMuted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 9
                        font.bold: true
                    }

                    Repeater {
                        model: menuOpener.children

                        Item {
                            id: menuEntryWrapper
                            required property var modelData
                            readonly property string cleanLabel: (modelData.text || "").replace(/&/g, "").trim()
                            readonly property bool showEntry: modelData.isSeparator || cleanLabel.length > 0

                            visible: showEntry
                            width: 284
                            height: !showEntry ? 0 : (modelData.isSeparator ? 9 : 32)

                            // Separator Line
                            Rectangle {
                                visible: menuEntryWrapper.modelData.isSeparator
                                width: 264
                                height: 1
                                anchors.centerIn: parent
                                color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.25)
                            }

                            // Action Button Row
                            Rectangle {
                                visible: !menuEntryWrapper.modelData.isSeparator && menuEntryWrapper.cleanLabel.length > 0
                                anchors.fill: parent
                                radius: 5
                                opacity: menuEntryWrapper.modelData.enabled ? 1.0 : 0.45
                                color: entryMouse.containsMouse && menuEntryWrapper.modelData.enabled
                                       ? SageState.bgCardHover
                                       : SageState.bgCard
                                border.width: 1
                                border.color: entryMouse.containsMouse && menuEntryWrapper.modelData.enabled
                                              ? SageState.secondaryAccent
                                              : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.30)

                                Row {
                                    x: 12
                                    y: 5
                                    width: 260
                                    height: 22
                                    spacing: 8

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: {
                                            if (menuEntryWrapper.modelData.buttonType !== QsMenuButtonType.None) {
                                                return menuEntryWrapper.modelData.checkState === Qt.Checked ? "◉" : "○";
                                            }
                                            return "▸";
                                        }
                                        color: menuEntryWrapper.modelData.checkState === Qt.Checked
                                               ? SageState.emeraldOk
                                               : (entryMouse.containsMouse ? SageState.secondaryAccent : SageState.primaryAccent)
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }

                                    Text {
                                        width: 230
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: menuEntryWrapper.cleanLabel
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: entryMouse.containsMouse
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: entryMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: menuEntryWrapper.modelData.enabled
                                    cursorShape: menuEntryWrapper.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        menuEntryWrapper.modelData.triggered();
                                        SageState.trayMenuOpen = false;
                                    }
                                }
                            }
                        }
                    }
                }

                // 4. Bottom Action: Terminate Background Process
                Rectangle {
                    visible: trayPopupWindow.appKey.length > 0
                    width: 284
                    height: 32
                    radius: 5
                    color: killMouse.containsMouse
                           ? Qt.rgba(SageState.crimsonAlert.r, SageState.crimsonAlert.g, SageState.crimsonAlert.b, 0.25)
                           : Qt.rgba(SageState.crimsonAlert.r, SageState.crimsonAlert.g, SageState.crimsonAlert.b, 0.12)
                    border.width: 1
                    border.color: SageState.crimsonAlert

                    Text {
                        anchors.centerIn: parent
                        text: "✕ QUIT / TERMINATE BACKGROUND APP"
                        color: SageState.crimsonAlert
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        id: killMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const k = trayPopupWindow.appKey;
                            SageState.trayMenuOpen = false;
                            if (k.length > 0) {
                                SageState.runCmd([SageState.ctlScript, "kill-bg-app", k]);
                            }
                        }
                    }
                }
            }
        }
    }
}

