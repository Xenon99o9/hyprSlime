import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: barWindow
        required property var modelData
        screen: modelData

        WlrLayershell.namespace: "quickshell"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: 44

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 44
        color: "transparent"

        // ─── Main 3-Island Floating Layout ────────────────────────────────────
        Item {
            anchors.fill: parent
            anchors.topMargin: 6
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            // ══════════════════════════════════════════════════════════════════
            //  ISLAND 1 (LEFT): Great Sage Badge + Animated Workspaces
            // ══════════════════════════════════════════════════════════════════
            Rectangle {
                id: leftIsland
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                height: 36
                width: leftRow.implicitWidth + 20
                radius: 6
                color: SageState.bgVoid
                border.width: 1
                border.color: SageState.primaryAccent

                RowLayout {
                    id: leftRow
                    anchors.centerIn: parent
                    spacing: 10

                    // Great Sage Launcher / Dashboard Button
                    Rectangle {
                        height: 26
                        width: sageLabel.implicitWidth + 18
                        radius: 4
                        color: sageMouse.containsMouse ? SageState.primaryAccent : SageState.bgCard
                        border.width: 1
                        border.color: SageState.secondaryAccent

                        Text {
                            id: sageLabel
                            anchors.centerIn: parent
                            text: "◈ GREAT SAGE"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            color: sageMouse.containsMouse ? "#080c14" : SageState.secondaryAccent
                        }

                        MouseArea {
                            id: sageMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    Hyprland.dispatch("exec rofi -show drun");
                                } else {
                                    SageState.controlCenterOpen = !SageState.controlCenterOpen;
                                }
                            }
                        }
                    }

                    // Workspaces 1..10 Pills (Caelestia / Slime fluid stretch)
                    RowLayout {
                        spacing: 5

                        Repeater {
                            model: 10

                            Rectangle {
                                required property int index
                                readonly property int wsId: index + 1
                                readonly property bool isActive: (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace ? Hyprland.focusedMonitor.activeWorkspace.id : 1) === wsId

                                height: 22
                                implicitWidth: isActive ? 34 : 22
                                radius: 4
                                color: isActive ? SageState.primaryAccent : (wsMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard)
                                border.width: isActive ? 1 : 0
                                border.color: SageState.secondaryAccent

                                Behavior on implicitWidth {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutBack }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: isActive ? ("◈ " + wsId) : wsId.toString()
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: isActive
                                    color: isActive ? "#080c14" : SageState.textPrimary
                                }

                                MouseArea {
                                    id: wsMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Hyprland.dispatch("workspace " + wsId)
                                }
                            }
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════════
            //  ISLAND 2 (CENTER): Clock, Date & Active Media
            // ══════════════════════════════════════════════════════════════════
            Rectangle {
                id: centerIsland
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height: 36
                width: centerRow.implicitWidth + 24
                radius: 6
                color: SageState.bgVoid
                border.width: 1
                border.color: SageState.secondaryAccent

                RowLayout {
                    id: centerRow
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "◈"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        color: SageState.secondaryAccent
                    }

                    Text {
                        text: SageState.clockTime
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        font.bold: true
                        color: SageState.textPrimary
                    }

                    Text {
                        text: "•  " + SageState.clockDate
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        color: SageState.textMuted
                    }

                    // Active Media Pill (visible when media plays)
                    Rectangle {
                        visible: SageState.mediaText.length > 0
                        height: 22
                        width: Math.min(mediaLabel.implicitWidth + 16, 220)
                        radius: 4
                        color: SageState.bgCard
                        border.width: 1
                        border.color: SageState.primaryAccent

                        Text {
                            id: mediaLabel
                            anchors.centerIn: parent
                            width: parent.width - 12
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            text: "♫ " + SageState.mediaText
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: SageState.primaryAccent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch("exec playerctl play-pause")
                        }
                    }
                }
            }

            // ══════════════════════════════════════════════════════════════════
            //  ISLAND 3 (RIGHT): Telemetry, Network/VPN, Keybinds Help & Settings
            // ══════════════════════════════════════════════════════════════════
            Rectangle {
                id: rightIsland
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 36
                width: rightRow.implicitWidth + 20
                radius: 6
                color: SageState.bgVoid
                border.width: 1
                border.color: SageState.primaryAccent

                RowLayout {
                    id: rightRow
                    anchors.centerIn: parent
                    spacing: 8

                    // CPU & RAM Telemetry Pill
                    Rectangle {
                        height: 24
                        width: sysLabel.implicitWidth + 14
                        radius: 4
                        color: SageState.bgCard

                        Text {
                            id: sysLabel
                            anchors.centerIn: parent
                            text: "CPU " + SageState.cpuUsage + "%  •  RAM " + SageState.ramUsage + "%"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: SageState.textPrimary
                        }
                    }

                    // Keyboard Layout Switcher Badge
                    Rectangle {
                        height: 24
                        width: kbLabel.implicitWidth + 14
                        radius: 4
                        color: kbMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard
                        border.width: 1
                        border.color: SageState.azureRimuru

                        Text {
                            id: kbLabel
                            anchors.centerIn: parent
                            text: "⌨ " + SageState.kbLayout.toUpperCase()
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                            color: SageState.primaryAccent
                        }

                        MouseArea {
                            id: kbMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const nextKb = (SageState.kbLayout === "fr") ? "us" : "fr";
                                SageState.runCmd([SageState.ctlScript, "set-kb", nextKb]);
                            }
                        }
                    }

                    // Wi-Fi & VPN Status Pill (Clicks open Network tab in Control Center)
                    Rectangle {
                        height: 24
                        width: netLabel.implicitWidth + 16
                        radius: 4
                        color: netMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard
                        border.width: 1
                        border.color: SageState.vpnActive ? SageState.emeraldOk : (SageState.wifiEnabled ? SageState.primaryAccent : SageState.crimsonAlert)

                        Text {
                            id: netLabel
                            anchors.centerIn: parent
                            text: {
                                let w = SageState.wifiEnabled ? ("Wi-Fi: " + (SageState.wifiSsid === "Disconnected" ? "On" : SageState.wifiSsid)) : "Wi-Fi: Off";
                                let v = SageState.vpnActive ? (" • 🛡️ VPN: " + SageState.vpnName) : " • VPN: Off";
                                return w + v;
                            }
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: SageState.vpnActive ? SageState.emeraldOk : SageState.textPrimary
                        }

                        MouseArea {
                            id: netMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SageState.activeTab = 1;
                                SageState.controlCenterOpen = true;
                                SageState.scanWifi();
                            }
                        }
                    }

                    // Audio & Battery Pill
                    Rectangle {
                        height: 24
                        width: pwrLabel.implicitWidth + 16
                        radius: 4
                        color: pwrMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard

                        Text {
                            id: pwrLabel
                            anchors.centerIn: parent
                            text: (SageState.muted ? "🔇 Mute" : ("🔊 " + SageState.volume + "%")) + "  •  ⚡ " + SageState.batPercent + "%"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: (SageState.batPercent <= 20 && SageState.batStatus === "Discharging") ? SageState.crimsonAlert : SageState.textPrimary
                        }

                        MouseArea {
                            id: pwrMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SageState.activeTab = 2;
                                SageState.controlCenterOpen = true;
                            }
                        }
                    }

                    // Keybinds Cheat Sheet Button [ ? ]
                    Rectangle {
                        height: 26
                        width: kbHelpLabel.implicitWidth + 16
                        radius: 4
                        color: (SageState.keybindsOpen || helpMouse.containsMouse) ? SageState.secondaryAccent : SageState.bgCard
                        border.width: 1
                        border.color: SageState.secondaryAccent

                        Text {
                            id: kbHelpLabel
                            anchors.centerIn: parent
                            text: "? Keybinds"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                            color: (SageState.keybindsOpen || helpMouse.containsMouse) ? "#080c14" : SageState.secondaryAccent
                        }

                        MouseArea {
                            id: helpMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SageState.keybindsOpen = !SageState.keybindsOpen;
                                if (SageState.keybindsOpen) SageState.controlCenterOpen = false;
                            }
                        }
                    }

                    // Control Center / Settings Button [ ⚙ ]
                    Rectangle {
                        height: 26
                        width: cfgLabel.implicitWidth + 16
                        radius: 4
                        color: (SageState.controlCenterOpen || cfgMouse.containsMouse) ? SageState.primaryAccent : SageState.bgCard
                        border.width: 1
                        border.color: SageState.primaryAccent

                        Text {
                            id: cfgLabel
                            anchors.centerIn: parent
                            text: "⚙ Menu"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                            color: (SageState.controlCenterOpen || cfgMouse.containsMouse) ? "#080c14" : SageState.primaryAccent
                        }

                        MouseArea {
                            id: cfgMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                SageState.controlCenterOpen = !SageState.controlCenterOpen;
                                if (SageState.controlCenterOpen) SageState.keybindsOpen = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
