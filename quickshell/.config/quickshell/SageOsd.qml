import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: osdWin
        required property var modelData
        screen: modelData

        readonly property bool isOpen: SageState.osdVisible && SageState.isActiveScreen(osdWin.modelData)

        visible: isOpen || closeAnim.running
        color: "transparent"

        WlrLayershell.namespace: "hyprslime-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        // Pass all pointer clicks through so the OSD never blocks mouse interaction
        mask: Region {}

        anchors {
            bottom: true
        }

        margins {
            bottom: 72
        }

        implicitWidth: 420
        implicitHeight: 108

        Timer {
            id: closeAnim
            interval: 200
            repeat: false
        }

        onIsOpenChanged: {
            if (!isOpen) closeAnim.restart();
        }

        readonly property color modeAccent: {
            if (SageState.osdMuted) return SageState.crimsonAlert;
            if (SageState.osdMode === "brightness") return SageState.goldSage;
            if (SageState.osdMode === "mic") return SageState.emeraldOk;
            if (SageState.osdValue > 100) return SageState.goldSage;
            return SageState.primaryAccent;
        }

        readonly property string modeHeader: {
            if (SageState.osdMode === "brightness") return "◈ « REPORT: OPTICAL LUMINANCE »";
            if (SageState.osdMode === "mic") return "◈ « REPORT: VOICE TELEPATHY »";
            return "◈ « REPORT: ACOUSTIC OUTPUT »";
        }

        readonly property string modeSubtext: {
            if (SageState.osdMode === "brightness") {
                return "DISPLAY BACKLIGHT // " + (SageState.osdValue >= 80 ? "HIGH RADIANCE" : (SageState.osdValue <= 25 ? "LOW POWER" : "NOMINAL"));
            }
            if (SageState.osdMode === "mic") {
                return SageState.osdMuted ? "MICROPHONE INPUT // SILENCED" : "MICROPHONE INPUT // TRANSMITTING";
            }
            if (SageState.osdMuted) {
                return "PIPEWIRE AUDIO SINK // SILENCED";
            }
            if (SageState.osdValue > 100) {
                return "PIPEWIRE AUDIO SINK // OVERDRIVE BOOST";
            }
            return "PIPEWIRE AUDIO SINK // NOMINAL";
        }

        readonly property string modeBadgeText: {
            if (SageState.osdMode === "brightness") return "LUX";
            if (SageState.osdMode === "mic") return SageState.osdMuted ? "OFF" : "MIC";
            return SageState.osdMuted ? "MUTE" : "VOL";
        }

        SageFrame {
            id: osdCard
            width: 404
            height: 92
            anchors.centerIn: parent
            chamfer: 14
            fillColor: "#f5060a12"
            borderColor: osdWin.modeAccent
            innerColor: SageState.secondaryAccent
            borderWidth: 2.0
            innerBorder: true
            cornerDiamonds: true
            showMagicCircle: true
            magicCircleAlpha: 0.12

            opacity: osdWin.isOpen ? 1.0 : 0.0
            scale: osdWin.isOpen ? 1.0 : 0.92
            transform: Translate {
                y: osdWin.isOpen ? 0 : 14
                Behavior on y { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
            }

            Behavior on opacity { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            Row {
                x: 16
                y: 12
                width: 372
                height: 68
                spacing: 14

                // ─── Left Radial HUD Emblem (68x68) ───────────────────────────
                Item {
                    width: 68
                    height: 68

                    Canvas {
                        id: osdRingCanvas
                        anchors.fill: parent
                        property real pct: Math.min(1.0, Math.max(0.0, SageState.osdMuted ? 0.0 : (SageState.osdValue / 100.0)))
                        property color ringColor: osdWin.modeAccent

                        onPctChanged: requestPaint()
                        onRingColorChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var cx = width * 0.5;
                            var cy = height * 0.5;
                            var r = 27;

                            // Outer octagonal frame
                            ctx.beginPath();
                            for (var i = 0; i < 8; ++i) {
                                var a = i * Math.PI / 4 + Math.PI / 8;
                                var px = cx + 32 * Math.cos(a);
                                var py = cy + 32 * Math.sin(a);
                                if (i === 0) ctx.moveTo(px, py);
                                else ctx.lineTo(px, py);
                            }
                            ctx.closePath();
                            ctx.fillStyle = "#cc0a1220";
                            ctx.fill();
                            ctx.lineWidth = 1.2;
                            ctx.strokeStyle = Qt.rgba(ringColor.r, ringColor.g, ringColor.b, 0.45);
                            ctx.stroke();

                            // Background track arc
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, Math.PI * 2);
                            ctx.lineWidth = 4.0;
                            ctx.strokeStyle = "#247c99bf";
                            ctx.stroke();

                            // Active progress arc
                            if (pct > 0.005) {
                                var startA = -Math.PI * 0.5;
                                var endA = startA + (Math.PI * 2 * pct);
                                ctx.beginPath();
                                ctx.arc(cx, cy, r, startA, endA);
                                ctx.lineWidth = 4.0;
                                ctx.lineCap = "round";
                                ctx.strokeStyle = ringColor;
                                ctx.stroke();
                            }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "◈"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: osdWin.modeBadgeText
                            color: osdWin.modeAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                // ─── Right Telemetry & Segmented Magicule Bar (290x68) ────────
                Column {
                    width: 290
                    height: 68
                    spacing: 6

                    // Header + Value Readout
                    Item {
                        width: 290
                        height: 20

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: osdWin.modeHeader
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: SageState.osdMuted ? "MUTED" : (SageState.osdValue + "%")
                            color: osdWin.modeAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 15
                            font.bold: true
                        }
                    }

                    // 20-Segment Magicule Progress Bar
                    Item {
                        width: 290
                        height: 16

                        SageFrame {
                            anchors.fill: parent
                            chamfer: 4
                            fillColor: "#14ffffff"
                            borderColor: "#357c99bf"
                            borderWidth: 1.0
                        }

                        // Smooth continuous bar underlay
                        Rectangle {
                            x: 3
                            y: 3
                            width: Math.max(0, Math.min(284, 284 * ((SageState.osdMuted ? 0 : Math.min(100, SageState.osdValue)) / 100.0)))
                            height: 10
                            radius: 2
                            color: osdWin.modeAccent
                            opacity: 0.32

                            Behavior on width {
                                NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
                            }
                        }

                        // 20 discrete Great Sage segments (5% each)
                        Row {
                            x: 4
                            y: 3
                            width: 282
                            height: 10
                            spacing: 2

                            Repeater {
                                model: 20

                                Rectangle {
                                    required property int index
                                    width: 12.2
                                    height: 10
                                    radius: 1.5
                                    readonly property int threshold: (index + 1) * 5
                                    readonly property bool activeSeg: !SageState.osdMuted && SageState.osdValue >= threshold
                                    readonly property bool partialSeg: !SageState.osdMuted && !activeSeg && SageState.osdValue > (index * 5)

                                    color: (activeSeg || partialSeg) ? osdWin.modeAccent : "#187c99bf"
                                    opacity: activeSeg ? 0.95 : (partialSeg ? 0.55 : 0.35)
                                }
                            }
                        }
                    }

                    // Subtitle Telemetry Line
                    Item {
                        width: 290
                        height: 16

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: osdWin.modeSubtext
                            color: SageState.textMuted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: SageState.osdMuted ? "[SILENCED]" : (SageState.osdValue > 100 ? "[OVERDRIVE]" : "[ONLINE]")
                            color: osdWin.modeAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }
                }
            }
        }
    }
}
