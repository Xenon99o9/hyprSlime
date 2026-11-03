import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: sideSlidersWindow
        required property var modelData
        screen: modelData

        visible: SageState.sideSlidersOpen && SageState.isActiveScreen(sideSlidersWindow.modelData)
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        exclusionMode: ExclusionMode.Ignore

        // Close when clicking anywhere outside the side panel
        MouseArea {
            anchors.fill: parent
            onClicked: SageState.sideSlidersOpen = false
        }

        SageFrame {
            id: sliderFrame
            width: 320
            height: SageState.mediaText.length > 0 ? 370 : 310
            anchors {
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            chamfer: 14
            fillColor: SageState.bgVoid
            borderColor: SageState.secondaryAccent
            innerColor: SageState.primaryAccent
            borderWidth: 2.0
            innerBorder: true
            cornerDiamonds: true

            // Stop click propagation inside panel
            MouseArea {
                anchors.fill: parent
            }

            Column {
                x: 18
                y: 16
                width: 284
                spacing: 14

                // Header
                Item {
                    width: 284
                    height: 24

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

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
                            text: "AUDIO & ILLUMINATION"
                            color: SageState.textPrimary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1.1
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        height: 22
                        radius: 4
                        color: closeMouse.containsMouse ? SageState.bgCardHover : "transparent"
                        border.width: 1
                        border.color: closeMouse.containsMouse ? SageState.crimsonAlert : SageState.primaryAccent

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: closeMouse.containsMouse ? SageState.crimsonAlert : SageState.textMuted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SageState.sideSlidersOpen = false
                        }
                    }
                }

                // Divider
                Rectangle {
                    width: 284
                    height: 1
                    color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)
                }

                // 1. VOLUME SECTION
                Column {
                    width: 284
                    spacing: 6

                    Item {
                        width: 284
                        height: 20

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Text {
                                text: SageState.muted ? "󰝟" : (SageState.volume > 50 ? "󰕾" : "󰖀")
                                color: SageState.muted ? SageState.crimsonAlert : SageState.primaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Text {
                                text: "MASTER AUDIO"
                                color: SageState.textPrimary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: SageState.muted ? "MUTED" : (SageState.volume + "%")
                            color: SageState.muted ? SageState.crimsonAlert : SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    // Interactive Drag Slider Bar
                    Rectangle {
                        id: volTrack
                        width: 284
                        height: 28
                        radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: volMouse.containsMouse ? SageState.secondaryAccent : SageState.primaryAccent
                        clip: true

                        Rectangle {
                            height: parent.height
                            width: Math.max(0, Math.min(parent.width, parent.width * (SageState.volume / 100.0)))
                            radius: 6
                            color: SageState.muted
                                   ? Qt.rgba(SageState.crimsonAlert.r, SageState.crimsonAlert.g, SageState.crimsonAlert.b, 0.45)
                                   : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.45)
                        }

                        // Gold Thumb Indicator
                        Rectangle {
                            x: Math.max(0, Math.min(parent.width - 6, (parent.width * (SageState.volume / 100.0)) - 3))
                            width: 6
                            height: parent.height
                            radius: 3
                            color: SageState.secondaryAccent
                        }

                        MouseArea {
                            id: volMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            function applyPos(mouseX) {
                                const frac = Math.max(0.0, Math.min(1.0, mouseX / width));
                                SageState.setVolumeValue(Math.round(frac * 100));
                            }
                            onPressed: function(mouse) { applyPos(mouse.x); }
                            onPositionChanged: function(mouse) {
                                if (pressed) applyPos(mouse.x);
                            }
                        }
                    }

                    // Preset Buttons + Mute Toggle
                    Row {
                        width: 284
                        height: 22
                        spacing: 6

                        Rectangle {
                            width: 58
                            height: 22
                            radius: 4
                            color: SageState.muted ? SageState.crimsonAlert : SageState.bgCard
                            border.width: 1
                            border.color: SageState.crimsonAlert

                            Text {
                                anchors.centerIn: parent
                                text: SageState.muted ? "UNMUTE" : "MUTE"
                                color: SageState.muted ? "#050911" : SageState.crimsonAlert
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SageState.toggleMute()
                            }
                        }

                        Repeater {
                            model: [25, 50, 75, 100]

                            Rectangle {
                                id: pBtn
                                required property int modelData
                                width: 50
                                height: 22
                                radius: 4
                                readonly property bool isNear: Math.abs(SageState.volume - modelData) <= 5 && !SageState.muted
                                color: isNear ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.28) : SageState.bgCard
                                border.width: 1
                                border.color: isNear ? SageState.secondaryAccent : SageState.primaryAccent

                                Text {
                                    anchors.centerIn: parent
                                    text: pBtn.modelData + "%"
                                    color: pBtn.isNear ? SageState.secondaryAccent : SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.setVolumeValue(pBtn.modelData)
                                }
                            }
                        }
                    }
                }

                // 2. BRIGHTNESS SECTION
                Column {
                    width: 284
                    spacing: 6

                    Item {
                        width: 284
                        height: 20

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Text {
                                text: "󰃠"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Text {
                                text: "DISPLAY BRIGHTNESS"
                                color: SageState.textPrimary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: SageState.brightness + "%"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    // Interactive Drag Slider Bar
                    Rectangle {
                        id: brightTrack
                        width: 284
                        height: 28
                        radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: brightMouse.containsMouse ? SageState.secondaryAccent : SageState.primaryAccent
                        clip: true

                        Rectangle {
                            height: parent.height
                            width: Math.max(0, Math.min(parent.width, parent.width * (SageState.brightness / 100.0)))
                            radius: 6
                            color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.42)
                        }

                        // Gold Thumb Indicator
                        Rectangle {
                            x: Math.max(0, Math.min(parent.width - 6, (parent.width * (SageState.brightness / 100.0)) - 3))
                            width: 6
                            height: parent.height
                            radius: 3
                            color: SageState.secondaryAccent
                        }

                        MouseArea {
                            id: brightMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            function applyPos(mouseX) {
                                const frac = Math.max(0.05, Math.min(1.0, mouseX / width));
                                SageState.setBrightnessValue(Math.round(frac * 100));
                            }
                            onPressed: function(mouse) { applyPos(mouse.x); }
                            onPositionChanged: function(mouse) {
                                if (pressed) applyPos(mouse.x);
                            }
                        }
                    }

                    // Preset Buttons + Mic Toggle
                    Row {
                        width: 284
                        height: 22
                        spacing: 6

                        Rectangle {
                            width: 58
                            height: 22
                            radius: 4
                            color: SageState.bgCard
                            border.width: 1
                            border.color: SageState.primaryAccent

                            Text {
                                anchors.centerIn: parent
                                text: " MIC"
                                color: SageState.primaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SageState.toggleMicMute()
                            }
                        }

                        Repeater {
                            model: [25, 50, 75, 100]

                            Rectangle {
                                id: bBtn
                                required property int modelData
                                width: 50
                                height: 22
                                radius: 4
                                readonly property bool isNear: Math.abs(SageState.brightness - modelData) <= 5
                                color: isNear ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.28) : SageState.bgCard
                                border.width: 1
                                border.color: isNear ? SageState.secondaryAccent : SageState.primaryAccent

                                Text {
                                    anchors.centerIn: parent
                                    text: bBtn.modelData + "%"
                                    color: bBtn.isNear ? SageState.secondaryAccent : SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.setBrightnessValue(bBtn.modelData)
                                }
                            }
                        }
                    }
                }

                // 3. MEDIA MINI CONTROLS (If active)
                Rectangle {
                    visible: SageState.mediaText.length > 0
                    width: 284
                    height: 40
                    radius: 6
                    color: SageState.bgCard
                    border.width: 1
                    border.color: SageState.primaryAccent

                    Item {
                        x: 8
                        y: 8
                        width: 268
                        height: 24

                        Text {
                            width: 170
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰎈 " + SageState.mediaText
                            color: SageState.primaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Rectangle {
                                width: 26
                                height: 22
                                radius: 4
                                color: SageState.bgVoid
                                border.width: 1
                                border.color: SageState.secondaryAccent
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰒮"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd(["playerctl", "previous"])
                                }
                            }

                            Rectangle {
                                width: 26
                                height: 22
                                radius: 4
                                color: SageState.secondaryAccent
                                Text {
                                    anchors.centerIn: parent
                                    text: "⏯"
                                    color: "#050911"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd(["playerctl", "play-pause"])
                                }
                            }

                            Rectangle {
                                width: 26
                                height: 22
                                radius: 4
                                color: SageState.bgVoid
                                border.width: 1
                                border.color: SageState.secondaryAccent
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰒭"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.runCmd(["playerctl", "next"])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
