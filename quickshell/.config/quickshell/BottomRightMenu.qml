
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: cornerWindow
        required property var modelData
        screen: modelData

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

        MouseArea {
            anchors.fill: parent
            onClicked: SageState.cornerMenuOpen = false
        }

        SageFrame {
            id: cornerFrame
            width: 340
            height: 330
            anchors {
                right: parent.right
                rightMargin: 16
                bottom: parent.bottom
                bottomMargin: 16
            }
            chamfer: 14
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerBorder: true
            cornerDiamonds: true

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "◈ QUICK COMMAND CORNER"
                        color: SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    Item { Layout.fillWidth: true }
                    Text {
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
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 8
                    columnSpacing: 8

                    // Wi-Fi Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
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

                    // Bluetooth Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
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

                    // Border Flow Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
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

                    // Next Wallpaper
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
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
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "AUDIO LEVEL"
                            color: SageState.textMuted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: SageState.volume + "%"
                            color: SageState.primaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                    Rectangle {
                        id: cVolTrack
                        Layout.fillWidth: true
                        height: 12
                        radius: 3
                        color: SageState.bgCard
                        border.width: 1
                        border.color: SageState.primaryAccent

                        Rectangle {
                            width: parent.width * (SageState.volume / 100.0)
                            height: parent.height
                            radius: 3
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

                Item { Layout.fillHeight: true }

                // Session Power Controls (Lock / Exit / Reboot / Shutdown)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: [
                            { label: "LOCK", col: SageState.primaryAccent, cmd: ["loginctl", "lock-session"] },
                            { label: "LOGOUT", col: SageState.secondaryAccent, cmd: ["hyprctl", "dispatch", "exit"] },
                            { label: "REBOOT", col: SageState.secondaryAccent, cmd: ["systemctl", "reboot"] },
                            { label: "POWEROFF", col: SageState.crimsonAlert, cmd: ["systemctl", "poweroff"] }
                        ]

                        Rectangle {
                            id: sessBtn
                            required property var modelData
                            Layout.fillWidth: true
                            height: 32
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
