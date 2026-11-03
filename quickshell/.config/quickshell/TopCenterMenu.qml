import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: topMenuWindow
        required property var modelData
        screen: modelData

        visible: SageState.topDropdownOpen && SageState.isActiveScreen(topMenuWindow.modelData)
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: (SageState.topDropdownOpen && SageState.isActiveScreen(topMenuWindow.modelData)) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        // Click anywhere outside the dropdown card to close immediately
        MouseArea {
            anchors.fill: parent
            onClicked: SageState.topDropdownOpen = false
        }

        readonly property string skillTitle: {
            if (SageState.themeName === "beelzebub") return "ULTIMATE SKILL // BEELZEBUB (LORD OF GLUTTONY)";
            if (SageState.themeName === "hellflare") return "ULTIMATE SKILL // BENIMARU (HELLFLARE)";
            if (SageState.themeName === "magicule") return "UNIQUE SKILL // PREDATOR & GREAT SAGE";
            return "ULTIMATE SKILL // RAPHAEL (LORD OF WISDOM)";
        }

        readonly property string sageReportText: {
            const vpnMsg = SageState.vpnActive
                ? ("Dimensional barrier [" + SageState.vpnName + "] is active.")
                : "No VPN barrier active (Standard network link).";
            const loadMsg = SageState.cpuUsage > 70
                ? ("High compute activity detected (" + SageState.cpuUsage + "%).")
                : ("Compute core nominal at " + SageState.cpuUsage + "% (" + SageState.ramText + " RAM).");
            return "« Report: " + loadMsg + " " + vpnMsg + " Magicule cell at " + SageState.batPercent + "% (" + SageState.batStatus + "). »";
        }

        // ═══════════════════════════════════════════════════════════════════════
        // CAELESTIA-STYLE SEPARATED TOP MENU WITH NAVIGATION BUTTONS (760 x 446)
        // ═══════════════════════════════════════════════════════════════════════
        SageFrame {
            id: dropdownCard
            width: 760
            height: 446
            anchors {
                top: parent.top
                topMargin: 48
                horizontalCenter: parent.horizontalCenter
            }
            chamfer: 18
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerColor: SageState.secondaryAccent
            borderWidth: 2.0
            innerBorder: true
            cornerDiamonds: true
            showMagicCircle: true
            magicCircleAlpha: 0.07

            MouseArea {
                anchors.fill: parent
            }

            Column {
                x: 24
                y: 18
                width: 712
                height: 410
                spacing: 14

                // ───────────────────────────────────────────────────────────────
                // TOP NAVIGATION BUTTONS BAR (4 Spacious Section Buttons)
                // ───────────────────────────────────────────────────────────────
                Row {
                    width: 712
                    height: 42
                    spacing: 8

                    Repeater {
                        model: [
                            { idx: 0, title: "01 // CHRONO & CAL", sub: "Calendar & Raphael Log" },
                            { idx: 1, title: "02 // MEDIA & AUDIO", sub: "Player, Volume & Lux" },
                            { idx: 2, title: "03 // TELEMETRY", sub: "Vitals, Rings & Power" },
                            { idx: 3, title: "04 // SKILLS & AURA", sub: "Themes, Walls & Screens" }
                        ]

                        SageFrame {
                            id: topTabBtn
                            required property var modelData
                            readonly property bool isAct: SageState.topDropdownTab === modelData.idx

                            width: 172
                            height: 42
                            chamfer: 8
                            fillColor: isAct
                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.25)
                                       : (topTabMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard)
                            borderColor: isAct ? SageState.secondaryAccent : SageState.primaryAccent
                            borderWidth: isAct ? 1.8 : 1.2
                            innerBorder: isAct

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: topTabBtn.modelData.title
                                    color: topTabBtn.isAct ? SageState.secondaryAccent : SageState.textPrimary
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: topTabBtn.modelData.sub
                                    color: topTabBtn.isAct ? SageState.primaryAccent : SageState.textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                id: topTabMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: SageState.topDropdownTab = topTabBtn.modelData.idx
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // SECTION 01: CHRONOMETER, RAPHAEL ANALYSIS LOG & LARGE CALENDAR
                // ═══════════════════════════════════════════════════════════════
                Row {
                    width: 712
                    height: 354
                    visible: SageState.topDropdownTab === 0
                    spacing: 14

                    // Left Card (318 x 354): Rimuru Identity, Chronometer & Raphael Report
                    SageFrame {
                        width: 318
                        height: 354
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent
                        innerBorder: true

                        Column {
                            x: 16
                            y: 16
                            width: 286
                            spacing: 12

                            // Big Digital Clock & Date
                            Row {
                                width: 286
                                height: 64
                                spacing: 12

                                Rectangle {
                                    width: 60
                                    height: 60
                                    radius: 8
                                    color: SageState.bgVoid
                                    border.width: 1.5
                                    border.color: SageState.secondaryAccent
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 3
                                        source: "file://" + SageState.rimuruAvatar
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }

                                Column {
                                    width: 214
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 3

                                    Text {
                                        text: SageState.clockTime
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 26
                                        font.bold: true
                                    }

                                    Text {
                                        width: 214
                                        text: SageState.clockFullDate.toUpperCase()
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            // Active Ultimate Skill Badge
                            Rectangle {
                                width: 286
                                height: 34
                                radius: 5
                                color: SageState.bgVoid
                                border.width: 1
                                border.color: SageState.secondaryAccent

                                Text {
                                    anchors.centerIn: parent
                                    width: 270
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "◈ " + topMenuWindow.skillTitle
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 9
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                            }

                            // Great Sage / Voice of the World Live System Analysis Box
                            SageFrame {
                                width: 286
                                height: 112
                                chamfer: 8
                                fillColor: SageState.bgVoid
                                borderColor: SageState.primaryAccent

                                Column {
                                    x: 12
                                    y: 10
                                    width: 262
                                    spacing: 6

                                    Text {
                                        text: "◈ VOICE OF THE WORLD // LIVE SYNTHESIS"
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }

                                    Text {
                                        width: 262
                                        text: topMenuWindow.sageReportText
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        lineHeight: 1.25
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }

                            // Quick Navigation Shortcuts to Central Dashboard Tabs
                            Text {
                                text: "◈ QUICK SYSTEM ACCESS"
                                color: SageState.textMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            Row {
                                width: 286
                                height: 38
                                spacing: 8

                                Repeater {
                                    model: [
                                        { label: "NEXUS MENU", tab: 0, col: SageState.primaryAccent },
                                        { label: "DISPLAYS", tab: 3, col: SageState.secondaryAccent },
                                        { label: "KEYBINDS", tab: 5, col: SageState.primaryAccent }
                                    ]

                                    Rectangle {
                                        id: qNavBtn
                                        required property var modelData
                                        width: 90
                                        height: 38
                                        radius: 5
                                        color: qNavMouse.containsMouse ? SageState.bgCardHover : SageState.bgVoid
                                        border.width: 1
                                        border.color: qNavBtn.modelData.col

                                        Text {
                                            anchors.centerIn: parent
                                            text: qNavBtn.modelData.label
                                            color: qNavBtn.modelData.col
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: qNavMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.openDashboardTab(qNavBtn.modelData.tab)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Right Card (380 x 354): Spacious Monthly Calendar Matrix
                    SageFrame {
                        width: 380
                        height: 354
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent
                        innerBorder: true

                        Column {
                            x: 18
                            y: 16
                            width: 344
                            spacing: 10

                            // Calendar Header
                            Item {
                                width: 344
                                height: 32

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "◈ TEMPEST IMPERIAL CALENDAR"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: monthTxt.implicitWidth + 16
                                    height: 26
                                    radius: 4
                                    color: SageState.bgVoid
                                    border.width: 1
                                    border.color: SageState.primaryAccent

                                    Text {
                                        id: monthTxt
                                        anchors.centerIn: parent
                                        text: SageState.clockMonthName
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }

                            // Weekday Headers (7 * 46 + 6 * 3.6 = 344)
                            Row {
                                width: 344
                                height: 22
                                spacing: 3.6

                                Repeater {
                                    model: ["LUN", "MAR", "MER", "JEU", "VEN", "SAM", "DIM"]
                                    Rectangle {
                                        required property string modelData
                                        width: 46
                                        height: 22
                                        radius: 3
                                        color: "#14ffffff"

                                        Text {
                                            anchors.centerIn: parent
                                            text: parent.modelData
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            // 7x6 Spacious Calendar Cells (46 x 38 each)
                            Grid {
                                width: 344
                                columns: 7
                                columnSpacing: 3.6
                                rowSpacing: 5

                                Repeater {
                                    model: SageState.calendarDays

                                    Rectangle {
                                        id: bigCalCell
                                        required property var modelData
                                        width: 46
                                        height: 38
                                        radius: 5
                                        color: modelData.isToday
                                               ? SageState.secondaryAccent
                                               : (modelData.inMonth ? SageState.bgVoid : "transparent")
                                        border.width: modelData.isToday ? 1.5 : (modelData.inMonth ? 1 : 0)
                                        border.color: modelData.isToday
                                                      ? SageState.primaryAccent
                                                      : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.22)

                                        Text {
                                            anchors.centerIn: parent
                                            text: bigCalCell.modelData.label
                                            color: bigCalCell.modelData.isToday
                                                   ? "#050911"
                                                   : (bigCalCell.modelData.inMonth ? SageState.textPrimary : SageState.textMuted)
                                            opacity: bigCalCell.modelData.inMonth ? 1.0 : 0.35
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.bold: bigCalCell.modelData.isToday || bigCalCell.modelData.inMonth
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // SECTION 02: DETAILED MEDIA PLAYER, AUDIO MIXER & LUMINANCE
                // ═══════════════════════════════════════════════════════════════
                Row {
                    width: 712
                    height: 354
                    visible: SageState.topDropdownTab === 1
                    spacing: 14

                    // Left Card (349 x 354): Detailed Acoustic Media Deck
                    SageFrame {
                        width: 349
                        height: 354
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent
                        innerBorder: true

                        Column {
                            x: 18
                            y: 16
                            width: 313
                            spacing: 14

                            Item {
                                width: 313
                                height: 24
                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "◈ ACOUSTIC RESONANCE DECK"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: SageState.mediaText.length > 0 ? "[ACTIVE STREAM]" : "[IDLE]"
                                    color: SageState.mediaText.length > 0 ? SageState.emeraldOk : SageState.textMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            // Large Vinyl / Emblem & Track Info Box
                            SageFrame {
                                width: 313
                                height: 142
                                chamfer: 10
                                fillColor: SageState.bgVoid
                                borderColor: SageState.primaryAccent
                                showMagicCircle: true
                                magicCircleAlpha: 0.14

                                Row {
                                    x: 14
                                    y: 16
                                    width: 285
                                    height: 110
                                    spacing: 14

                                    Rectangle {
                                        width: 86
                                        height: 86
                                        anchors.verticalCenter: parent.verticalCenter
                                        radius: 43
                                        color: SageState.bgCard
                                        border.width: 2
                                        border.color: SageState.secondaryAccent
                                        clip: true

                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            source: "file://" + SageState.rimuruAvatar
                                            fillMode: Image.PreserveAspectCrop
                                        }
                                    }

                                    Column {
                                        width: 185
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 6

                                        Text {
                                            text: "NOW PLAYING // PIPEWIRE"
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        Text {
                                            width: 185
                                            text: SageState.mediaText.length > 0 ? SageState.mediaText : "No Active Audio Stream"
                                            color: SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.bold: true
                                            maximumLineCount: 2
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: SageState.mediaText.length > 0 ? "Click transport buttons below" : "Summon Spotify via button below"
                                            color: SageState.textMuted
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                        }
                                    }
                                }
                            }

                            // Large Transport Controls Row
                            Row {
                                width: 313
                                height: 44
                                spacing: 8

                                Repeater {
                                    model: [
                                        { label: "◂◂ PREV", w: 88, cmd: ["playerctl", "previous"], col: SageState.primaryAccent },
                                        { label: "◈ PLAY / PAUSE", w: 121, cmd: ["playerctl", "play-pause"], col: SageState.secondaryAccent },
                                        { label: "NEXT ▸▸", w: 88, cmd: ["playerctl", "next"], col: SageState.primaryAccent }
                                    ]

                                    SageFrame {
                                        id: bigMediaBtn
                                        required property var modelData
                                        width: modelData.w
                                        height: 44
                                        chamfer: 7
                                        fillColor: bigMediaMouse.containsMouse ? SageState.bgCardHover : SageState.bgVoid
                                        borderColor: modelData.col

                                        Text {
                                            anchors.centerIn: parent
                                            text: bigMediaBtn.modelData.label
                                            color: bigMediaBtn.modelData.col
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        MouseArea {
                                            id: bigMediaMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.runCmd(bigMediaBtn.modelData.cmd)
                                        }
                                    }
                                }
                            }

                            // Summon Music Special Workspace Button
                            SageFrame {
                                width: 313
                                height: 42
                                chamfer: 8
                                fillColor: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.18)
                                borderColor: SageState.secondaryAccent

                                Text {
                                    anchors.centerIn: parent
                                    text: "◈ SUMMON MUSIC WORKSPACE (SUPER + S)"
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

                    // Right Card (349 x 354): Detailed Audio & Brightness Control Deck
                    SageFrame {
                        width: 349
                        height: 354
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent
                        innerBorder: true

                        Column {
                            x: 18
                            y: 16
                            width: 313
                            spacing: 14

                            // 1. Acoustic Output (Volume) Detailed Control
                            Column {
                                width: 313
                                spacing: 8

                                Item {
                                    width: 313
                                    height: 22
                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: SageState.muted ? "◈ ACOUSTIC OUTPUT [MUTED]" : "◈ ACOUSTIC OUTPUT (VOLUME)"
                                        color: SageState.muted ? SageState.crimsonAlert : SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: SageState.muted ? "SILENCED" : (SageState.volume + "%")
                                        color: SageState.muted ? SageState.crimsonAlert : SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                // Interactive Slider Bar
                                Rectangle {
                                    id: detVolTrack
                                    width: 313
                                    height: 22
                                    radius: 5
                                    color: SageState.bgVoid
                                    border.width: 1.5
                                    border.color: SageState.muted ? SageState.crimsonAlert : SageState.primaryAccent

                                    Rectangle {
                                        width: parent.width * (Math.max(0, Math.min(100, SageState.muted ? 0 : SageState.volume)) / 100.0)
                                        height: parent.height
                                        radius: 5
                                        color: SageState.muted ? SageState.crimsonAlert : SageState.primaryAccent
                                        opacity: 0.75
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: function(mouse) {
                                            const pct = Math.round(Math.max(0, Math.min(100, (mouse.x / detVolTrack.width) * 100)));
                                            SageState.volume = pct;
                                            SageState.runCmd([SageState.ctlScript, "vol-set", pct.toString()]);
                                        }
                                    }
                                }

                                // Volume Quick Step Buttons (-5%, MUTE, +5%, 100%)
                                Row {
                                    width: 313
                                    height: 30
                                    spacing: 6

                                    Rectangle {
                                        width: 73
                                        height: 30
                                        radius: 4
                                        color: SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.primaryAccent
                                        Text {
                                            anchors.centerIn: parent
                                            text: "-5% VOL"
                                            color: SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.osdVolume("down")
                                        }
                                    }

                                    Rectangle {
                                        width: 74
                                        height: 30
                                        radius: 4
                                        color: SageState.muted
                                               ? Qt.rgba(SageState.crimsonAlert.r, SageState.crimsonAlert.g, SageState.crimsonAlert.b, 0.25)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.muted ? SageState.crimsonAlert : SageState.primaryAccent
                                        Text {
                                            anchors.centerIn: parent
                                            text: SageState.muted ? "UNMUTE" : "MUTE"
                                            color: SageState.muted ? SageState.crimsonAlert : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.osdVolume("mute")
                                        }
                                    }

                                    Rectangle {
                                        width: 74
                                        height: 30
                                        radius: 4
                                        color: SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.primaryAccent
                                        Text {
                                            anchors.centerIn: parent
                                            text: "+5% VOL"
                                            color: SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.osdVolume("up")
                                        }
                                    }

                                    Rectangle {
                                        width: 74
                                        height: 30
                                        radius: 4
                                        color: SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.secondaryAccent
                                        Text {
                                            anchors.centerIn: parent
                                            text: "MAX 100%"
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                SageState.volume = 100;
                                                SageState.runCmd([SageState.ctlScript, "vol-set", "100"]);
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: 313
                                height: 1
                                color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.25)
                            }

                            // 2. Optical Luminance (Brightness) Detailed Control
                            Column {
                                width: 313
                                spacing: 8

                                Item {
                                    width: 313
                                    height: 22
                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "◈ OPTICAL LUMINANCE (BRIGHTNESS)"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: SageState.brightness + "%"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                Rectangle {
                                    id: detBrightTrack
                                    width: 313
                                    height: 22
                                    radius: 5
                                    color: SageState.bgVoid
                                    border.width: 1.5
                                    border.color: SageState.secondaryAccent

                                    Rectangle {
                                        width: parent.width * (Math.max(5, Math.min(100, SageState.brightness)) / 100.0)
                                        height: parent.height
                                        radius: 5
                                        color: SageState.secondaryAccent
                                        opacity: 0.75
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: function(mouse) {
                                            const pct = Math.round(Math.max(5, Math.min(100, (mouse.x / detBrightTrack.width) * 100)));
                                            SageState.brightness = pct;
                                            SageState.runCmd([SageState.ctlScript, "bright-set", pct.toString()]);
                                        }
                                    }
                                }

                                // Brightness Quick Presets (25%, 50%, 75%, 100%)
                                Row {
                                    width: 313
                                    height: 30
                                    spacing: 6

                                    Repeater {
                                        model: [25, 50, 75, 100]

                                        Rectangle {
                                            id: bPresetBtn
                                            required property int modelData
                                            width: 73.7
                                            height: 30
                                            radius: 4
                                            color: Math.abs(SageState.brightness - modelData) <= 5
                                                   ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.22)
                                                   : SageState.bgVoid
                                            border.width: 1
                                            border.color: SageState.secondaryAccent

                                            Text {
                                                anchors.centerIn: parent
                                                text: bPresetBtn.modelData + "% LUX"
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    SageState.brightness = bPresetBtn.modelData;
                                                    SageState.runCmd([SageState.ctlScript, "bright-set", bPresetBtn.modelData.toString()]);
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // 3. Special Workspaces Summon Strip
                            Row {
                                width: 313
                                height: 36
                                spacing: 6

                                Repeater {
                                    model: SageState.specialWorkspaces

                                    Rectangle {
                                        id: sec2SpecBtn
                                        required property var modelData
                                        width: Math.floor((313 - (Math.max(1, SageState.specialWorkspaces.length) - 1) * 6) / Math.max(1, SageState.specialWorkspaces.length))
                                        height: 36
                                        radius: 4
                                        color: modelData.running
                                               ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.22)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: modelData.running ? SageState.secondaryAccent : SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "◈ " + sec2SpecBtn.modelData.label
                                            color: sec2SpecBtn.modelData.running ? SageState.secondaryAccent : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                SageState.topDropdownOpen = false;
                                                SageState.toggleSpecialWs(sec2SpecBtn.modelData.id);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // SECTION 03: SPACIOUS TELEMETRY RINGS, POWER MODES & CONNECTIVITY
                // ═══════════════════════════════════════════════════════════════
                Column {
                    width: 712
                    height: 354
                    visible: SageState.topDropdownTab === 2
                    spacing: 14

                    // Top Row: 3 Large Circular Telemetry Cards (228 x 190 each)
                    Row {
                        width: 712
                        height: 190
                        spacing: 14

                        Repeater {
                            model: [
                                {
                                    title: "◈ CPU COMPUTE CORE",
                                    val: SageState.cpuUsage,
                                    sub: SageState.cpuUsage > 70 ? "STATUS // HIGH LOAD" : "STATUS // NOMINAL",
                                    detail: "Click to summon BTOP (Super+Esc)",
                                    col: SageState.primaryAccent,
                                    action: "btop"
                                },
                                {
                                    title: "◈ MAGICULE MEMORY (RAM)",
                                    val: SageState.ramUsage,
                                    sub: "ALLOCATED // " + SageState.ramText,
                                    detail: "System shared memory pool",
                                    col: SageState.secondaryAccent,
                                    action: "btop"
                                },
                                {
                                    title: "◈ ENERGY CELL (BATTERY)",
                                    val: SageState.batPercent,
                                    sub: "STATE // " + SageState.batStatus.toUpperCase(),
                                    detail: "Power profile: " + SageState.powerProfile.toUpperCase(),
                                    col: SageState.emeraldOk,
                                    action: "none"
                                }
                            ]

                            SageFrame {
                                id: bigRingCard
                                required property var modelData
                                width: 228
                                height: 190
                                chamfer: 12
                                fillColor: SageState.bgCard
                                borderColor: modelData.col
                                innerBorder: true

                                Column {
                                    x: 14
                                    y: 12
                                    width: 200
                                    spacing: 6

                                    Text {
                                        text: bigRingCard.modelData.title
                                        color: bigRingCard.modelData.col
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Row {
                                        width: 200
                                        height: 104
                                        spacing: 12

                                        Canvas {
                                            width: 96
                                            height: 96
                                            anchors.verticalCenter: parent.verticalCenter
                                            property int pct: bigRingCard.modelData.val
                                            onPctChanged: requestPaint()
                                            onPaint: {
                                                const ctx = getContext("2d");
                                                ctx.reset();
                                                const cx = width * 0.5;
                                                const cy = height * 0.5;
                                                const r = 39;
                                                const startA = -Math.PI * 0.5;
                                                const endA = startA + (Math.max(0, Math.min(100, pct)) / 100.0) * Math.PI * 2.0;

                                                ctx.lineWidth = 6.5;
                                                ctx.strokeStyle = Qt.rgba(bigRingCard.modelData.col.r, bigRingCard.modelData.col.g, bigRingCard.modelData.col.b, 0.16);
                                                ctx.beginPath();
                                                ctx.arc(cx, cy, r, 0, Math.PI * 2.0);
                                                ctx.stroke();

                                                ctx.lineWidth = 6.5;
                                                ctx.lineCap = "round";
                                                ctx.strokeStyle = bigRingCard.modelData.col;
                                                ctx.beginPath();
                                                ctx.arc(cx, cy, r, startA, endA);
                                                ctx.stroke();
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: bigRingCard.modelData.val + "%"
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 18
                                                font.bold: true
                                            }
                                        }

                                        Column {
                                            width: 92
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 6

                                            Text {
                                                width: 92
                                                text: bigRingCard.modelData.sub
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 9
                                                font.bold: true
                                                wrapMode: Text.WordWrap
                                            }

                                            Text {
                                                width: 92
                                                text: bigRingCard.modelData.detail
                                                color: SageState.textMuted
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 8
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: bigRingCard.modelData.action === "btop" ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        if (bigRingCard.modelData.action === "btop") {
                                            SageState.topDropdownOpen = false;
                                            SageState.toggleSpecialWs("sysmon");
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom Row (712 x 150): Power Profiles & Quick Connectivity Matrix
                    Row {
                        width: 712
                        height: 150
                        spacing: 14

                        // Power Profiles Card (349 x 150)
                        SageFrame {
                            width: 349
                            height: 150
                            chamfer: 10
                            fillColor: SageState.bgCard
                            borderColor: SageState.secondaryAccent

                            Column {
                                x: 16
                                y: 14
                                width: 317
                                spacing: 10

                                Text {
                                    text: "◈ MAGICULE REACTOR POWER PROFILE"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Row {
                                    width: 317
                                    height: 88
                                    spacing: 8

                                    Repeater {
                                        model: [
                                            { id: "power-saver", title: "ECO SAVER", desc: "Max battery life" },
                                            { id: "balanced", title: "BALANCED", desc: "Optimal harmony" },
                                            { id: "performance", title: "OVERDRIVE", desc: "Max clock speed" }
                                        ]

                                        SageFrame {
                                            id: pwrModeCard
                                            required property var modelData
                                            readonly property bool isCurPwr: SageState.powerProfile === modelData.id
                                            width: 100.3
                                            height: 88
                                            chamfer: 7
                                            fillColor: isCurPwr
                                                       ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.24)
                                                       : SageState.bgVoid
                                            borderColor: isCurPwr ? SageState.secondaryAccent : SageState.primaryAccent

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 4
                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: pwrModeCard.modelData.title
                                                    color: pwrModeCard.isCurPwr ? SageState.secondaryAccent : SageState.textPrimary
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }
                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: pwrModeCard.modelData.desc
                                                    color: SageState.textMuted
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 8
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    SageState.powerProfile = pwrModeCard.modelData.id;
                                                    SageState.runCmd([SageState.ctlScript, "set-power", pwrModeCard.modelData.id]);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Connectivity & Subsystem Toggles Card (349 x 150)
                        SageFrame {
                            width: 349
                            height: 150
                            chamfer: 10
                            fillColor: SageState.bgCard
                            borderColor: SageState.primaryAccent

                            Column {
                                x: 16
                                y: 14
                                width: 317
                                spacing: 10

                                Text {
                                    text: "◈ SUBSYSTEM & NETWORK LINKS"
                                    color: SageState.secondaryAccent
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                Grid {
                                    width: 317
                                    height: 88
                                    columns: 2
                                    spacing: 8

                                    // Wi-Fi
                                    Rectangle {
                                        width: 154
                                        height: 40
                                        radius: 5
                                        color: SageState.wifiEnabled
                                               ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.wifiEnabled ? SageState.primaryAccent : SageState.textMuted

                                        Text {
                                            anchors.centerIn: parent
                                            width: 142
                                            horizontalAlignment: Text.AlignHCenter
                                            text: "WI-FI: " + (SageState.wifiEnabled ? SageState.wifiSsid : "OFF")
                                            color: SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.runCmd([SageState.ctlScript, "wifi-toggle"])
                                        }
                                    }

                                    // Bluetooth
                                    Rectangle {
                                        width: 154
                                        height: 40
                                        radius: 5
                                        color: SageState.btEnabled
                                               ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.2)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.btEnabled ? SageState.primaryAccent : SageState.textMuted

                                        Text {
                                            anchors.centerIn: parent
                                            text: "BLUETOOTH: " + (SageState.btEnabled ? "ON" : "OFF")
                                            color: SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.runCmd([SageState.ctlScript, "bt-toggle"])
                                        }
                                    }

                                    // VPN Tunnel
                                    Rectangle {
                                        width: 154
                                        height: 40
                                        radius: 5
                                        color: SageState.vpnActive
                                               ? Qt.rgba(SageState.emeraldOk.r, SageState.emeraldOk.g, SageState.emeraldOk.b, 0.2)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.vpnActive ? SageState.emeraldOk : SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            width: 142
                                            horizontalAlignment: Text.AlignHCenter
                                            text: SageState.vpnActive ? ("VPN: " + SageState.vpnName) : "VPN SETTINGS ▸"
                                            color: SageState.vpnActive ? SageState.emeraldOk : SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: SageState.openDashboardTab(4)
                                        }
                                    }

                                    // Border Flow Animation
                                    Rectangle {
                                        width: 154
                                        height: 40
                                        radius: 5
                                        color: SageState.borderFlow
                                               ? Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.2)
                                               : SageState.bgVoid
                                        border.width: 1
                                        border.color: SageState.secondaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: "AURA FLOW: " + (SageState.borderFlow ? "ON" : "OFF")
                                            color: SageState.secondaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 9
                                            font.bold: true
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
                                }
                            }
                        }
                    }
                }

                // ═══════════════════════════════════════════════════════════════
                // SECTION 04: RIMURU ULTIMATE SKILLS (THEMES), WALLPAPERS & DISPLAYS
                // ═══════════════════════════════════════════════════════════════
                Row {
                    width: 712
                    height: 354
                    visible: SageState.topDropdownTab === 3
                    spacing: 14

                    // Left Card (356 x 354): Ultimate Skill Aura Selector
                    SageFrame {
                        width: 356
                        height: 354
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.primaryAccent
                        innerBorder: true

                        Column {
                            x: 16
                            y: 16
                            width: 324
                            spacing: 10

                            Text {
                                text: "◈ ULTIMATE SKILL RESONANCE (LIVE THEME)"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Flickable {
                                width: 324
                                height: 300
                                contentHeight: topSkillCol.implicitHeight
                                clip: true

                                Column {
                                    id: topSkillCol
                                    width: 324
                                    spacing: 8

                                    Repeater {
                                        model: [
                                            { id: "great_sage", title: "◈ RAPHAEL // GREAT SAGE", sub: "Cyan Magicule & Divine Gold", col: "#00e5ff", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/rimuru-great-sage.png" },
                                            { id: "diablo",     title: "◈ DIABLO // NOIR PRIMORDIAL", sub: "Lord of Darkness Crimson & Gold", col: "#e53935", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/diablo-primordial.png" },
                                            { id: "testarossa", title: "◈ TESTAROSSA // BLANC", sub: "Celestial White & Blood Ruby", col: "#ffffff", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/testarossa-primordial.png" },
                                            { id: "carrera",    title: "◈ CARRERA // JAUNE", sub: "Solar Nuclear Gold & Violet", col: "#fbbf24", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/carrera-primordial.png" },
                                            { id: "ultima",     title: "◈ ULTIMA // VIOLET", sub: "Toxic Violet Flame & Emerald Poison", col: "#c084fc", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/ultima-primordial.png" },
                                            { id: "mustang",    title: "◈ MUSTANG // DEMON", sub: "Onyx Shadow & Fiery Amber Flame", col: "#f97316", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/mustang-primordial.png" },
                                            { id: "beelzebub",  title: "◈ BEELZEBUB // GLUTTONY", sub: "Abyssal Devouring Purple & Cyan", col: "#b388ff", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/beelzebub-abyss.png" },
                                            { id: "magicule",   title: "◈ RIMURU // SLIME AURA",  sub: "Pure Azure & Ice Magicule", col: "#84ffff", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/rimuru-magicule.png" },
                                            { id: "hellflare",  title: "◈ BENIMARU // HELLFLARE", sub: "Crimson Black Flame & Gold", col: "#ff5252", wall: Quickshell.env("HOME") + "/.config/hypr/wallpapers/crimson-hellflare.png" }
                                        ]

                                        SageFrame {
                                            id: topSkillCard
                                            required property var modelData
                                            readonly property bool isCurrentSkill: SageState.themeName === modelData.id
                                            width: 324
                                            height: 58
                                            chamfer: 8
                                            fillColor: isCurrentSkill
                                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.22)
                                                       : SageState.bgVoid
                                            borderColor: isCurrentSkill ? SageState.secondaryAccent : modelData.col

                                            Row {
                                                x: 12
                                                y: 10
                                                width: 300
                                                height: 38
                                                spacing: 10

                                                Rectangle {
                                                    width: 10
                                                    height: 38
                                                    radius: 2
                                                    color: topSkillCard.modelData.col
                                                }

                                                Column {
                                                    width: 210
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 2

                                                    Text {
                                                        text: topSkillCard.modelData.title
                                                        color: SageState.textPrimary
                                                        font.family: "JetBrainsMono Nerd Font"
                                                        font.pixelSize: 10
                                                        font.bold: true
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        text: topSkillCard.modelData.sub
                                                        color: SageState.textMuted
                                                        font.family: "JetBrainsMono Nerd Font"
                                                        font.pixelSize: 9
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: topSkillCard.isCurrentSkill ? "[ACTIVE]" : "EQUIP ▸"
                                                    color: topSkillCard.isCurrentSkill ? SageState.secondaryAccent : topSkillCard.modelData.col
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    SageState.themeName = topSkillCard.modelData.id;
                                                    SageState.runCmd([SageState.ctlScript, "set-theme", topSkillCard.modelData.id]);
                                                    if (topSkillCard.modelData.wall) {
                                                        SageState.setWallpaper(topSkillCard.modelData.wall);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Right Card (342 x 354): Wallpaper Preview & Multi-Monitor Quick Access
                    SageFrame {
                        width: 342
                        height: 354
                        chamfer: 12
                        fillColor: SageState.bgCard
                        borderColor: SageState.secondaryAccent
                        innerBorder: true

                        Column {
                            x: 16
                            y: 16
                            width: 310
                            spacing: 12

                            Text {
                                text: "◈ MINDSCAPE PROJECTION (WALLPAPER)"
                                color: SageState.secondaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            // Current Wallpaper Preview Box
                            Rectangle {
                                width: 310
                                height: 146
                                radius: 6
                                color: SageState.bgVoid
                                border.width: 1.5
                                border.color: SageState.primaryAccent
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: "file://" + SageState.currentWallpaper
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 28
                                    color: "#cc050912"

                                    Text {
                                        anchors.centerIn: parent
                                        width: 290
                                        horizontalAlignment: Text.AlignHCenter
                                        text: SageState.currentWallpaper.split("/").pop()
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                        elide: Text.ElideMiddle
                                    }
                                }
                            }

                            // Wallpaper Action Buttons
                            Row {
                                width: 310
                                height: 38
                                spacing: 8

                                SageFrame {
                                    width: 151
                                    height: 38
                                    chamfer: 7
                                    fillColor: SageState.bgVoid
                                    borderColor: SageState.primaryAccent

                                    Text {
                                        anchors.centerIn: parent
                                        text: "NEXT WALLPAPER ▸"
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

                                SageFrame {
                                    width: 151
                                    height: 38
                                    chamfer: 7
                                    fillColor: SageState.bgVoid
                                    borderColor: SageState.secondaryAccent

                                    Text {
                                        anchors.centerIn: parent
                                        text: "WALLPAPER STUDIO"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: SageState.openDashboardTab(2)
                                    }
                                }
                            }

                            // Multi-Monitor Graphical Manager Shortcut Card
                            SageFrame {
                                width: 310
                                height: 84
                                chamfer: 8
                                fillColor: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.16)
                                borderColor: SageState.primaryAccent

                                Column {
                                    x: 14
                                    y: 12
                                    width: 282
                                    spacing: 4

                                    Text {
                                        text: "◈ GRAPHICAL MULTI-MONITOR MANAGER"
                                        color: SageState.secondaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    Text {
                                        text: "Detected Screens: " + SageState.monitorList.length + "  •  Click to arrange & resize"
                                        color: SageState.textPrimary
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        text: "OPEN DISPLAY STUDIO (04 // DISPLAYS) ▸"
                                        color: SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: SageState.openDashboardTab(3)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
