
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: topMenuWindow
        required property var modelData
        screen: modelData

        visible: SageState.topDropdownOpen
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: SageState.topDropdownOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: SageState.topDropdownOpen = false
        }

        SageFrame {
            id: dropdownCard
            width: 520
            height: 310
            anchors {
                top: parent.top
                topMargin: 56
                horizontalCenter: parent.horizontalCenter
            }
            chamfer: 14
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerBorder: true
            cornerDiamonds: true
            showMagicCircle: true
            magicCircleAlpha: 0.06

            // Prevent click-through inside menu
            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                // ─── Top Tab Bar (Caelestia Top Dropdown Style) ──────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { idx: 0, title: "01 // MEDIA & AUDIO" },
                            { idx: 1, title: "02 // CHRONO MATRIX" },
                            { idx: 2, title: "03 // TELEMETRY" }
                        ]

                        Rectangle {
                            id: tabBtn
                            required property var modelData
                            readonly property bool active: SageState.topDropdownTab === modelData.idx

                            Layout.fillWidth: true
                            height: 30
                            radius: 4
                            color: active
                                   ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.22)
                                   : SageState.bgCard
                            border.width: 1
                            border.color: active
                                          ? SageState.secondaryAccent
                                          : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.3)

                            Text {
                                anchors.centerIn: parent
                                text: tabBtn.modelData.title
                                color: tabBtn.active ? SageState.secondaryAccent : SageState.textPrimary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SageState.topDropdownTab = tabBtn.modelData.idx
                            }
                        }
                    }
                }

                // ─── Tab 0: MEDIA & AUDIO ────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: SageState.topDropdownTab === 0
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        height: 92
                        radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Text {
                                text: "◈ ACOUSTIC STREAM // NOW PLAYING"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Text {
                                Layout.fillWidth: true
                                text: SageState.mediaText.length > 0 ? SageState.mediaText : "No active media stream detected"
                                color: SageState.textPrimary
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Repeater {
                                    model: [
                                        { label: "PREV", cmd: ["playerctl", "previous"] },
                                        { label: "PLAY / PAUSE", cmd: ["playerctl", "play-pause"] },
                                        { label: "NEXT", cmd: ["playerctl", "next"] }
                                    ]

                                    Rectangle {
                                        id: mediaCtrlBtn
                                        required property var modelData
                                        Layout.fillWidth: true
                                        height: 26
                                        radius: 4
                                        color: SageState.bgSurface
                                        border.width: 1
                                        border.color: SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: mediaCtrlBtn.modelData.label
                                            color: SageState.primaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.runCmd(mediaCtrlBtn.modelData.cmd)
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 26
                                    radius: 4
                                    color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.2)
                                    border.width: 1
                                    border.color: SageState.secondaryAccent

                                    Text {
                                        anchors.centerIn: parent
                                        text: "OPEN MUSIC WS"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            SageState.topDropdownOpen = false;
                                            SageState.toggleSpecialWs("music");
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Volume Bar
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: SageState.muted ? "MASTER AUDIO [MUTED]" : "MASTER AUDIO"
                                color: SageState.muted ? SageState.crimsonAlert : SageState.textMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: SageState.volume + "%"
                                color: SageState.primaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Rectangle {
                            id: volBarTrack
                            Layout.fillWidth: true
                            height: 14
                            radius: 4
                            color: SageState.bgCard
                            border.width: 1
                            border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.35)

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
                                    const pct = Math.round(Math.max(0, Math.min(100, (mouse.x / volBarTrack.width) * 100)));
                                    SageState.volume = pct;
                                    SageState.runCmd([SageState.ctlScript, "vol-set", pct.toString()]);
                                }
                            }
                        }
                    }

                    // Brightness Bar
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "OPTICAL LUMINANCE (BRIGHTNESS)"
                                color: SageState.textMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: SageState.brightness + "%"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Rectangle {
                            id: brightBarTrack
                            Layout.fillWidth: true
                            height: 14
                            radius: 4
                            color: SageState.bgCard
                            border.width: 1
                            border.color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.35)

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
                                    const pct = Math.round(Math.max(5, Math.min(100, (mouse.x / brightBarTrack.width) * 100)));
                                    SageState.brightness = pct;
                                    SageState.runCmd([SageState.ctlScript, "bright-set", pct.toString()]);
                                }
                            }
                        }
                    }
                }

                // ─── Tab 1: CHRONO MATRIX ────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: SageState.topDropdownTab === 1
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 6
                        color: SageState.bgCard
                        border.width: 1
                        border.color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.45)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 18

                            // Large Date Seal
                            Rectangle {
                                width: 110
                                height: 110
                                radius: 8
                                color: SageState.bgSurface
                                border.width: 2
                                border.color: SageState.secondaryAccent

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.clockDayNumber
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 36
                                        font.bold: true
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: SageState.clockMonthName
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: "◈ GREAT SAGE CHRONOMETER"
                                    color: SageState.primaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Text {
                                    text: SageState.clockTime
                                    color: SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 32
                                    font.bold: true
                                }

                                Text {
                                    text: SageState.clockFullDate
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 28
                                        radius: 4
                                        color: SageState.bgSurface
                                        border.width: 1
                                        border.color: SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "NEXT WALLPAPER"
                                            color: SageState.primaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.cycleWallpaper()
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 28
                                        radius: 4
                                        color: SageState.bgSurface
                                        border.width: 1
                                        border.color: SageState.secondaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "OPEN DASHBOARD"
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.openDashboardTab(0)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ─── Tab 2: TELEMETRY GAUGES ─────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: SageState.topDropdownTab === 2
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10

                        // CPU Card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 6
                            color: SageState.bgCard
                            border.width: 1
                            border.color: SageState.primaryAccent

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "CPU LOAD"
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
                                    font.pixelSize: 26
                                    font.bold: true
                                }
                            }
                        }

                        // RAM Card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 6
                            color: SageState.bgCard
                            border.width: 1
                            border.color: SageState.secondaryAccent

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
                                    font.pixelSize: 26
                                    font.bold: true
                                }
                            }
                        }

                        // Battery Card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 6
                            color: SageState.bgCard
                            border.width: 1
                            border.color: SageState.emeraldOk

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "CELL (" + SageState.batStatus.toUpperCase() + ")"
                                    color: SageState.textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: SageState.batPercent + "%"
                                    color: SageState.emeraldOk
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 26
                                    font.bold: true
                                }
                            }
                        }
                    }

                    // Power Profile Selector Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: [
                                { id: "power-saver", label: "ECO MODE" },
                                { id: "balanced", label: "BALANCED" },
                                { id: "performance", label: "OVERDRIVE" }
                            ]

                            Rectangle {
                                id: pwrBtn
                                required property var modelData
                                readonly property bool active: SageState.powerProfile === modelData.id

                                Layout.fillWidth: true
                                height: 32
                                radius: 4
                                color: active
                                       ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.25)
                                       : SageState.bgCard
                                border.width: 1
                                border.color: active ? SageState.secondaryAccent : SageState.primaryAccent

                                Text {
                                    anchors.centerIn: parent
                                    text: pwrBtn.modelData.label
                                    color: pwrBtn.active ? SageState.secondaryAccent : SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        SageState.powerProfile = pwrBtn.modelData.id;
                                        SageState.runCmd([SageState.ctlScript, "set-power", pwrBtn.modelData.id]);
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
