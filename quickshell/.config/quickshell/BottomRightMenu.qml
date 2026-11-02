import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    Item {
        id: cornerRoot
        required property var modelData

        // 1. Subtle Caelestia Edge Hover Sensor at Bottom-Right Corner
        PanelWindow {
            screen: cornerRoot.modelData
            visible: !SageState.cornerMenuOpen && !SageState.dashboardOpen && !SageState.launcherOpen
            color: "transparent"

            anchors {
                bottom: true
                right: true
            }

            implicitWidth: 150
            implicitHeight: 7
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                anchors.fill: parent
                anchors.rightMargin: 12
                anchors.bottomMargin: 1
                radius: 3
                color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    SageState.cornerMenuOpen = true;
                    SageState.topDropdownOpen = false;
                }
            }
        }

        // 2. Bottom-Right Quick Corner Popup Window (With Safe Bridge so it NEVER flickers)
        PanelWindow {
            id: cornerWindow
            screen: cornerRoot.modelData

            visible: SageState.cornerMenuOpen
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: SageState.cornerMenuOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore

            Timer {
                id: closeCornerTimer
                interval: 340
                running: SageState.cornerMenuOpen && !cornerHoverHandler.hovered
                repeat: false
                onTriggered: {
                    if (!cornerHoverHandler.hovered) {
                        SageState.cornerMenuOpen = false;
                    }
                }
            }

            // Click outside to close immediately
            MouseArea {
                anchors.fill: parent
                onClicked: SageState.cornerMenuOpen = false
            }

            // Safe Hover Zone extending all the way to the bottom-right screen edges (0px gap!)
            Item {
                width: 386
                height: 352
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }

                HoverHandler {
                    id: cornerHoverHandler
                }

                MouseArea {
                    anchors.fill: parent
                }

                SageFrame {
                    id: cornerFrame
                    width: 348
                    height: 315
                    anchors {
                        right: parent.right
                        rightMargin: 14
                        bottom: parent.bottom
                        bottomMargin: 14
                    }
                    chamfer: 14
                    fillColor: SageState.bgVoid
                    borderColor: SageState.primaryAccent
                    innerBorder: true
                    cornerDiamonds: true

                    Column {
                        x: 18
                        y: 16
                        width: 312
                        spacing: 12

                        // Header
                        Item {
                            width: 312
                            height: 20
                            Text {
                                anchors.left: parent.left
                                text: "◈ QUICK COMMAND CORNER"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }
                            Text {
                                anchors.right: parent.right
                                text: "✕"
                                color: SageState.textMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.bold: true
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.cornerMenuOpen = false
                                }
                            }
                        }

                        // 2x2 Quick Toggle Matrix
                        Grid {
                            width: 312
                            columns: 2
                            spacing: 10

                            Rectangle {
                                width: 151
                                height: 52
                                radius: 5
                                color: SageState.wifiEnabled
                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.22)
                                       : SageState.bgCard
                                border.width: 1
                                border.color: SageState.wifiEnabled ? SageState.primaryAccent : SageState.textMuted

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "WI-FI LINK"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.wifiEnabled ? "ONLINE" : "OFFLINE"
                                        color: SageState.wifiEnabled ? SageState.primaryAccent : SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd([SageState.ctlScript, "wifi-toggle"])
                                }
                            }

                            Rectangle {
                                width: 151
                                height: 52
                                radius: 5
                                color: SageState.btEnabled
                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.22)
                                       : SageState.bgCard
                                border.width: 1
                                border.color: SageState.btEnabled ? SageState.primaryAccent : SageState.textMuted

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "BLUETOOTH"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.btEnabled ? "ACTIVE" : "DISABLED"
                                        color: SageState.btEnabled ? SageState.primaryAccent : SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd([SageState.ctlScript, "bt-toggle"])
                                }
                            }

                            Rectangle {
                                width: 151
                                height: 52
                                radius: 5
                                color: SageState.borderFlow
                                       ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.22)
                                       : SageState.bgCard
                                border.width: 1
                                border.color: SageState.borderFlow ? SageState.secondaryAccent : SageState.textMuted

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "MAGICULE FLOW"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.borderFlow ? "ANIMATED" : "STATIC"
                                        color: SageState.borderFlow ? SageState.secondaryAccent : SageState.textMuted
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
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

                            Rectangle {
                                width: 151
                                height: 52
                                radius: 5
                                color: SageState.bgCard
                                border.width: 1
                                border.color: SageState.primaryAccent

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "WALLPAPER"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "CYCLE NEXT ▸"
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.cycleWallpaper()
                                }
                            }
                        }

                        // Quick Volume Slider
                        Column {
                            width: 312
                            spacing: 6

                            Item {
                                width: 312
                                height: 16
                                Text {
                                    anchors.left: parent.left
                                    text: "AUDIO LEVEL"
                                    color: SageState.textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                                Text {
                                    anchors.right: parent.right
                                    text: SageState.volume + "%"
                                    color: SageState.primaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                id: cVolTrack
                                width: 312
                                height: 14
                                radius: 4
                                color: SageState.bgCard
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
                                        const pct = Math.round(Math.max(0, Math.min(100, (mouse.x / cVolTrack.width) * 100)));
                                        SageState.volume = pct;
                                        SageState.runCmd([SageState.ctlScript, "vol-set", pct.toString()]);
                                    }
                                }
                            }
                        }

                        // Session Power Controls
                        Row {
                            width: 312
                            height: 36
                            spacing: 8

                            Repeater {
                                model: [
                                    { label: "LOCK", col: SageState.primaryAccent, cmd: ["bash", "-c", "faillock --user \"$USER\" --reset 2>/dev/null || true; sleep 0.15; pidof hyprlock >/dev/null || hyprlock"] },
                                    { label: "LOGOUT", col: SageState.secondaryAccent, cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
                                    { label: "REBOOT", col: SageState.secondaryAccent, cmd: ["systemctl", "reboot"] },
                                    { label: "POWER", col: SageState.crimsonAlert, cmd: ["systemctl", "poweroff"] }
                                ]

                                Rectangle {
                                    id: sessBtn
                                    required property var modelData
                                    width: 72
                                    height: 36
                                    radius: 4
                                    color: SageState.bgCard
                                    border.width: 1
                                    border.color: sessBtn.modelData.col

                                    Text {
                                        anchors.centerIn: parent
                                        text: sessBtn.modelData.label
                                        color: sessBtn.modelData.col
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            SageState.cornerMenuOpen = false;
                                            SageState.runCmd(sessBtn.modelData.cmd);
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
