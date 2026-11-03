import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: launcherWindow
        required property var modelData
        screen: modelData

        visible: SageState.launcherOpen && SageState.isActiveScreen(launcherWindow.modelData)
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: (SageState.launcherOpen && SageState.isActiveScreen(launcherWindow.modelData))
                                     ? WlrKeyboardFocus.OnDemand
                                     : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        property string queryText: ""
        property int selectedIndex: 0

        Timer {
            id: focusGuardTimer
            interval: 30
            repeat: false
            onTriggered: {
                if (launcherWindow.visible) {
                    searchField.forceActiveFocus();
                }
            }
        }

        readonly property var filteredApps: {
            const q = queryText.trim().toLowerCase();
            const list = SageState.appList;
            const out = [];
            for (let i = 0; i < list.length; ++i) {
                const item = list[i];
                const n = item.name !== undefined ? item.name.toLowerCase() : "";
                const d = item.desc !== undefined ? item.desc.toLowerCase() : "";
                const e = item.exec !== undefined ? item.exec.toLowerCase() : "";
                if (q.length === 0 || n.indexOf(q) !== -1 || d.indexOf(q) !== -1 || e.indexOf(q) !== -1) {
                    out.push(item);
                    if (out.length >= 30) break;
                }
            }
            return out;
        }

        function ensureSelectedVisible() {
            const rowH = 66; // 58px height + 8px spacing
            const topY = selectedIndex * rowH;
            const botY = topY + 58;
            if (topY < appFlick.contentY) {
                appFlick.contentY = topY;
            } else if (botY > appFlick.contentY + appFlick.height) {
                appFlick.contentY = botY - appFlick.height;
            }
        }

        onVisibleChanged: {
            if (visible) {
                queryText = "";
                selectedIndex = 0;
                appFlick.contentY = 0;
                searchField.text = "";
                SageState.loadApps();
                searchField.forceActiveFocus();
                focusGuardTimer.restart();
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: SageState.launcherOpen = false
        }

        SageFrame {
            id: launcherFrame
            width: 720
            height: 510
            anchors {
                bottom: parent.bottom
                bottomMargin: 22
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
                y: 20
                width: 672
                spacing: 12

                // Header
                Item {
                    width: 672
                    height: 22

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "◈ GREAT SAGE // APPLICATION SUMMONING MATRIX (MOST USED FIRST)"
                        color: SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 1.0
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "[SUPER / SUPER+M / ESC TO CLOSE]"
                        color: SageState.textMuted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                // Search Box (Larger & Clearer)
                Rectangle {
                    width: 672
                    height: 46
                    radius: 6
                    color: SageState.bgCard
                    border.width: 1.5
                    border.color: SageState.secondaryAccent

                    Row {
                        x: 16
                        y: 8
                        width: 640
                        height: 30
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "▸"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        TextField {
                            id: searchField
                            width: 608
                            height: 30
                            verticalAlignment: TextInput.AlignVCenter
                            placeholderText: "Rechercher une application (triées par fréquence d'utilisation)..."
                            placeholderTextColor: SageState.textMuted
                            color: SageState.textPrimary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            font.bold: true
                            background: Item {}
                            onTextChanged: {
                                launcherWindow.queryText = text;
                                launcherWindow.selectedIndex = 0;
                                appFlick.contentY = 0;
                            }
                            onActiveFocusChanged: {
                                if (!activeFocus && launcherWindow.visible) {
                                    focusGuardTimer.restart();
                                }
                            }
                            Keys.onEscapePressed: {
                                SageState.lastLauncherToggleTime = Date.now();
                                SageState.launcherOpen = false;
                            }
                            Keys.onDownPressed: {
                                if (launcherWindow.filteredApps.length > 0) {
                                    launcherWindow.selectedIndex = Math.min(launcherWindow.filteredApps.length - 1, launcherWindow.selectedIndex + 1);
                                    launcherWindow.ensureSelectedVisible();
                                }
                            }
                            Keys.onUpPressed: {
                                launcherWindow.selectedIndex = Math.max(0, launcherWindow.selectedIndex - 1);
                                launcherWindow.ensureSelectedVisible();
                            }
                            Keys.onReturnPressed: {
                                if (launcherWindow.filteredApps.length > launcherWindow.selectedIndex) {
                                    const targetApp = launcherWindow.filteredApps[launcherWindow.selectedIndex];
                                    SageState.launchApp(targetApp.exec, targetApp.name);
                                }
                            }
                        }
                    }
                }

                // Quick Special Workspaces Row
                Row {
                    width: 672
                    height: 32
                    spacing: 8

                    Repeater {
                        model: SageState.specialWorkspaces

                        Rectangle {
                            id: quickWsBtn
                            required property var modelData
                            width: Math.floor((672 - (Math.max(1, SageState.specialWorkspaces.length) - 1) * 8) / Math.max(1, SageState.specialWorkspaces.length))
                            height: 32
                            radius: 5
                            color: quickWsMouse.containsMouse ? SageState.bgCardHover : SageState.bgCard
                            border.width: 1
                            border.color: quickWsMouse.containsMouse
                                          ? SageState.secondaryAccent
                                          : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.45)

                            Text {
                                anchors.centerIn: parent
                                text: "◈ " + quickWsBtn.modelData.label + " (" + quickWsBtn.modelData.bind + ")"
                                color: quickWsMouse.containsMouse ? SageState.secondaryAccent : SageState.primaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                id: quickWsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SageState.launcherOpen = false;
                                    SageState.toggleSpecialWs(quickWsBtn.modelData.id);
                                }
                            }
                        }
                    }
                }

                // Spacious Application Results List (5 large items visible at once with Logos & Larger Text)
                Flickable {
                    id: appFlick
                    width: 672
                    height: 324
                    contentHeight: appCol.implicitHeight
                    clip: true

                    Behavior on contentY { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                    Column {
                        id: appCol
                        width: 672
                        spacing: 8

                        Repeater {
                            model: launcherWindow.filteredApps

                            Rectangle {
                                id: appRow
                                required property var modelData
                                required property int index
                                readonly property bool isSel: index === launcherWindow.selectedIndex

                                width: 672
                                height: 58
                                radius: 6
                                color: isSel || appMouse.containsMouse
                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.24)
                                       : SageState.bgCard
                                border.width: isSel ? 1.8 : 1
                                border.color: isSel
                                              ? SageState.secondaryAccent
                                              : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.32)

                                Row {
                                    x: 14
                                    y: 9
                                    width: 644
                                    height: 40
                                    spacing: 14

                                    // Application Logo Badge (40 x 40)
                                    Rectangle {
                                        width: 40
                                        height: 40
                                        anchors.verticalCenter: parent.verticalCenter
                                        radius: 6
                                        color: SageState.bgSurface
                                        border.width: 1
                                        border.color: appRow.isSel ? SageState.secondaryAccent : SageState.primaryAccent

                                        Image {
                                            id: appIconImg
                                            anchors.centerIn: parent
                                            width: 28
                                            height: 28
                                            source: appRow.modelData.icon !== undefined && appRow.modelData.icon.length > 0
                                                    ? ("file://" + appRow.modelData.icon)
                                                    : ""
                                            visible: status === Image.Ready
                                            smooth: true
                                            mipmap: true
                                            fillMode: Image.PreserveAspectFit
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !appIconImg.visible
                                            text: appRow.modelData.name !== undefined && appRow.modelData.name.length > 0
                                                  ? appRow.modelData.name.substring(0, 2).toUpperCase()
                                                  : "AP"
                                            color: appRow.isSel ? SageState.secondaryAccent : SageState.primaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 13
                                            font.bold: true
                                        }
                                    }

                                    // App Title + Frequent Badge + Description
                                    Column {
                                        width: 496
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 3

                                        Row {
                                            spacing: 8

                                            Text {
                                                text: appRow.modelData.name !== undefined ? appRow.modelData.name : "Application"
                                                color: SageState.textPrimary
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 14
                                                font.bold: true
                                            }

                                            Rectangle {
                                                visible: appRow.modelData.frequent === true
                                                height: 18
                                                width: freqLabel.implicitWidth + 10
                                                radius: 3
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: Qt.rgba(SageState.secondaryAccent.r, SageState.secondaryAccent.g, SageState.secondaryAccent.b, 0.20)
                                                border.width: 1
                                                border.color: SageState.secondaryAccent

                                                Text {
                                                    id: freqLabel
                                                    anchors.centerIn: parent
                                                    text: "★ FREQUENT"
                                                    color: SageState.secondaryAccent
                                                    font.family: "JetBrainsMono Nerd Font"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                }
                                            }
                                        }

                                        Text {
                                            width: 496
                                            text: appRow.modelData.desc !== undefined && appRow.modelData.desc.length > 0
                                                  ? appRow.modelData.desc
                                                  : appRow.modelData.exec
                                            color: SageState.textMuted
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // Launch Action Label
                                    Text {
                                        width: 80
                                        anchors.verticalCenter: parent.verticalCenter
                                        horizontalAlignment: Text.AlignRight
                                        text: "SUMMON ▸"
                                        color: appRow.isSel ? SageState.secondaryAccent : SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: launcherWindow.selectedIndex = appRow.index
                                    onClicked: SageState.launchApp(appRow.modelData.exec, appRow.modelData.name)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
