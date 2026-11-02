
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

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

        // ═══════════════════════════════════════════════════════════════════════
        // 1. LEFT ISLAND: Great Sage Emblem + Launcher + Workspaces + Special WS
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

                // Bottom-Center App Launcher Trigger (Caelestia Style)
                Rectangle {
                    height: 26
                    width: appBtnText.implicitWidth + 16
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.launcherOpen
                           ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.25)
                           : (appBtnMouse.containsMouse ? SageState.bgCardHover : "transparent")
                    border.width: 1
                    border.color: SageState.launcherOpen
                                  ? SageState.primaryAccent
                                  : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.4)

                    Text {
                        id: appBtnText
                        anchors.centerIn: parent
                        text: "APPS"
                        color: SageState.launcherOpen ? SageState.secondaryAccent : SageState.primaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        id: appBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.toggleLauncher()
                    }
                }

                // Divider
                Rectangle {
                    width: 1
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)
                }

                // Workspaces 1..6 (plus active higher workspaces)
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

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
                                onClicked: Hyprland.dispatch("workspace " + wsPill.wsId)
                            }
                        }
                    }
                }

                // Divider before Special Workspaces
                Rectangle {
                    width: 1
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.45)
                }

                // Caelestia-style Special Workspaces (MUS / SYS / CHT / WEB)
                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: SageState.specialWorkspaces

                        Rectangle {
                            id: specBadge
                            required property var modelData
                            readonly property bool isRunning: modelData.running === true
                            readonly property string codeText: modelData.short !== undefined && modelData.short.length > 0
                                                               ? modelData.short
                                                               : (modelData.label !== undefined ? modelData.label.substring(0, 3) : "SPC")

                            height: 24
                            width: specBadgeRow.implicitWidth + 14
                            radius: 4
                            anchors.verticalCenter: parent.verticalCenter
                            color: specMouse.containsMouse
                                   ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.28)
                                   : (isRunning
                                      ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                      : SageState.bgCard)
                            border.width: 1
                            border.color: isRunning
                                          ? SageState.secondaryAccent
                                          : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

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
                                id: specMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        SageState.openDashboardTab(1);
                                    } else {
                                        SageState.toggleSpecialWs(specBadge.modelData.id);
                                    }
                                }
                            }
                        }
                    }

                    // [+] Quick button to open Special Workspaces Manager
                    Rectangle {
                        height: 24
                        width: 24
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: addSpecMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard
                        border.width: 1
                        border.color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.45)

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            id: addSpecMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SageState.openDashboardTab(1)
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // 2. CENTER ISLAND: Clock + Date + Media (Clicks open Caelestia Top Menu)
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

                // Media indicator pill when audio is playing
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
                onClicked: SageState.toggleTopDropdown()
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // 3. RIGHT ISLAND: Clean Telemetry (No Wi-Fi SSID Clutter, Zero Emojis)
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

                // CPU + RAM Compact Pill
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

                // VPN Badge (Only shown when active)
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
                        onClicked: SageState.openDashboardTab(3)
                    }
                }

                // Volume Pill (Scroll or click to mute)
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

                // Keyboard Layout Pill (Click to cycle FR / US)
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
                        onClicked: {
                            const nextKb = SageState.kbLayout === "fr" ? "us" : "fr";
                            SageState.kbLayout = nextKb;
                            SageState.runCmd([SageState.ctlScript, "set-kb", nextKb]);
                        }
                    }
                }

                // Keybinds Cheat Sheet Trigger [ ? ]
                Rectangle {
                    height: 24
                    width: 24
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: (SageState.dashboardOpen && SageState.activeTab === 4)
                           ? SageState.secondaryAccent
                           : SageState.bgCard
                    border.width: 1
                    border.color: SageState.secondaryAccent

                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        color: (SageState.dashboardOpen && SageState.activeTab === 4) ? "#050911" : SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.openDashboardTab(4)
                    }
                }

                // Quick Corner Menu Trigger [ SYS ]
                Rectangle {
                    height: 24
                    width: cornerLabel.implicitWidth + 14
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter
                    color: SageState.cornerMenuOpen ? SageState.primaryAccent : SageState.bgCard
                    border.width: 1
                    border.color: SageState.primaryAccent

                    Text {
                        id: cornerLabel
                        anchors.centerIn: parent
                        text: "QUICK"
                        color: SageState.cornerMenuOpen ? "#050911" : SageState.primaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: SageState.toggleCornerMenu()
                    }
                }
            }
        }
    }
}
