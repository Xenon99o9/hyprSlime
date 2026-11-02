import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: kbWindow
        required property var modelData
        screen: modelData
        visible: SageState.keybindsOpen

        WlrLayershell.namespace: "quickshell"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "#8804070d"

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: SageState.keybindsOpen = false
        }

        // Main Holographic Cheat Sheet Card
        Rectangle {
            id: card
            anchors.centerIn: parent
            width: Math.min(parent.width - 80, 1020)
            height: Math.min(parent.height - 100, 620)
            radius: 6
            color: SageState.bgSurface
            border.width: 2
            border.color: SageState.secondaryAccent

            // Prevent clicks inside card from closing overlay
            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 18

                // Header
                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "◈ GREAT SAGE — SKILL & KEYBINDS MATRIX ◈"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            font.bold: true
                            color: SageState.secondaryAccent
                        }
                        Text {
                            text: "Universal AZERTY & QWERTY physical keycode bindings (Press Super + H or Esc to close)"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            color: SageState.textMuted
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 80
                        height: 30
                        radius: 4
                        color: closeMouse.containsMouse ? SageState.crimsonAlert : SageState.bgCard
                        border.width: 1
                        border.color: SageState.crimsonAlert

                        Text {
                            anchors.centerIn: parent
                            text: "✕ Close"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            color: closeMouse.containsMouse ? "#080c14" : SageState.crimsonAlert
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SageState.keybindsOpen = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: SageState.primaryAccent
                    opacity: 0.4
                }

                // 4-Column Keybinds Grid (end-4 style)
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    rowSpacing: 14
                    columnSpacing: 14

                    // Category 1: Core Applications
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "◈ 1. CORE APPLICATIONS"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                font.bold: true
                                color: SageState.primaryAccent
                            }

                            Repeater {
                                model: [
                                    { k: "Super + Return / T", d: "Launch Kitty Terminal" },
                                    { k: "Super + R / Space",  d: "App Launcher (Rofi)" },
                                    { k: "Super + E",          d: "File Manager (Thunar)" },
                                    { k: "Super + B",          d: "Web Browser (Brave)" },
                                    { k: "Super + V",          d: "Clipboard History (Cliphist)" },
                                    { k: "Super + L",          d: "Lock Screen (Hyprlock)" }
                                ]
                                RowLayout {
                                    Layout.fillWidth: true
                                    required property var modelData
                                    Rectangle {
                                        width: 165; height: 24; radius: 4
                                        color: "#080c14"
                                        border.width: 1; border.color: SageState.azureRimuru
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.k
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11; font.bold: true
                                            color: SageState.secondaryAccent
                                        }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.d
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        color: SageState.textPrimary
                                    }
                                }
                            }
                        }
                    }

                    // Category 2: Window Management
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "◈ 2. WINDOW MANAGEMENT"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                font.bold: true
                                color: SageState.primaryAccent
                            }

                            Repeater {
                                model: [
                                    { k: "Super + Q",              d: "Close Active Window" },
                                    { k: "Super + F",              d: "Toggle Fullscreen" },
                                    { k: "Super + Shift + F",      d: "Toggle Floating Mode" },
                                    { k: "Super + Arrows",         d: "Move Focus (L/R/U/D)" },
                                    { k: "Super + Shift + Arrows", d: "Move Window Position" },
                                    { k: "Super + Ctrl + Arrows",  d: "Resize Active Window" }
                                ]
                                RowLayout {
                                    Layout.fillWidth: true
                                    required property var modelData
                                    Rectangle {
                                        width: 185; height: 24; radius: 4
                                        color: "#080c14"
                                        border.width: 1; border.color: SageState.azureRimuru
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.k
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11; font.bold: true
                                            color: SageState.secondaryAccent
                                        }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.d
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        color: SageState.textPrimary
                                    }
                                }
                            }
                        }
                    }

                    // Category 3: Workspaces & Special Stomach
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "◈ 3. WORKSPACES (AZERTY & QWERTY)"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                font.bold: true
                                color: SageState.primaryAccent
                            }

                            Repeater {
                                model: [
                                    { k: "Super + [1..0]",         d: "Switch to Workspace 1–10" },
                                    { k: "Super + Shift + [1..0]", d: "Move Window to WS 1–10" },
                                    { k: "Super + S",              d: "Toggle Scratchpad (Stomach)" },
                                    { k: "Super + Shift + S",      d: "Send Window to Scratchpad" },
                                    { k: "Super + Mouse Scroll",   d: "Cycle Workspaces" },
                                    { k: "Super + LMB / RMB",      d: "Drag Move / Resize Window" }
                                ]
                                RowLayout {
                                    Layout.fillWidth: true
                                    required property var modelData
                                    Rectangle {
                                        width: 185; height: 24; radius: 4
                                        color: "#080c14"
                                        border.width: 1; border.color: SageState.azureRimuru
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.k
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11; font.bold: true
                                            color: SageState.secondaryAccent
                                        }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.d
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        color: SageState.textPrimary
                                    }
                                }
                            }
                        }
                    }

                    // Category 4: Great Sage HUD & System
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: SageState.primaryAccent

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            Text {
                                text: "◈ 4. GREAT SAGE HUD & SYSTEM"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                font.bold: true
                                color: SageState.primaryAccent
                            }

                            Repeater {
                                model: [
                                    { k: "Super + Shift + G", d: "Toggle Great Sage Control Center" },
                                    { k: "Super + H / F1",    d: "Toggle Keybinds Cheat Sheet" },
                                    { k: "Alt + Shift",       d: "Switch Keyboard Layout (FR/US)" },
                                    { k: "Print",             d: "Area Screenshot to Clipboard" },
                                    { k: "Shift + Print",     d: "Fullscreen Screenshot" },
                                    { k: "Super + Shift + M", d: "Exit Hyprland Session" }
                                ]
                                RowLayout {
                                    Layout.fillWidth: true
                                    required property var modelData
                                    Rectangle {
                                        width: 165; height: 24; radius: 4
                                        color: "#080c14"
                                        border.width: 1; border.color: SageState.azureRimuru
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.k
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11; font.bold: true
                                            color: SageState.secondaryAccent
                                        }
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.d
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        color: SageState.textPrimary
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

