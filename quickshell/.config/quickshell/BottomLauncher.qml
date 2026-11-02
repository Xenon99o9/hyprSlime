
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: launcherWindow
        required property var modelData
        screen: modelData

        visible: SageState.launcherOpen
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: SageState.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        property string queryText: ""
        property int selectedIndex: 0

        readonly property var filteredApps: {
            const q = queryText.trim().toLowerCase();
            const list = SageState.appList;
            const out = [];
            for (let i = 0; i < list.length; ++i) {
                const item = list[i];
                const n = item.name !== undefined ? item.name.toLowerCase() : "";
                const d = item.desc !== undefined ? item.desc.toLowerCase() : "";
                if (q.length === 0 || n.indexOf(q) !== -1 || d.indexOf(q) !== -1) {
                    out.push(item);
                    if (out.length >= 24) break;
                }
            }
            return out;
        }

        onVisibleChanged: {
            if (visible) {
                queryText = "";
                selectedIndex = 0;
                searchField.text = "";
                searchField.forceActiveFocus();
            }
        }

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: SageState.launcherOpen = false
        }

        SageFrame {
            id: launcherFrame
            width: 640
            height: 460
            anchors {
                bottom: parent.bottom
                bottomMargin: 24
                horizontalCenter: parent.horizontalCenter
            }
            chamfer: 16
            fillColor: SageState.bgVoid
            borderColor: SageState.primaryAccent
            innerBorder: true
            cornerDiamonds: true
            showMagicCircle: true
            magicCircleAlpha: 0.07

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "◈ GREAT SAGE // APPLICATION SUMMONING MATRIX"
                        color: SageState.secondaryAccent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1.2
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "[ESC TO CLOSE]"
                        color: SageState.textMuted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                // Search Input Box
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: 6
                    color: SageState.bgCard
                    border.width: 1.5
                    border.color: SageState.secondaryAccent

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Text {
                            text: "▸"
                            color: SageState.secondaryAccent
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "Query Great Sage to summon application..."
                            placeholderTextColor: SageState.textMuted
                            color: SageState.textPrimary
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.bold: true
                            background: Item {}
                            onTextChanged: {
                                launcherWindow.queryText = text;
                                launcherWindow.selectedIndex = 0;
                            }
                            Keys.onEscapePressed: SageState.launcherOpen = false
                            Keys.onDownPressed: {
                                if (launcherWindow.filteredApps.length > 0) {
                                    launcherWindow.selectedIndex = Math.min(launcherWindow.filteredApps.length - 1, launcherWindow.selectedIndex + 1);
                                }
                            }
                            Keys.onUpPressed: {
                                launcherWindow.selectedIndex = Math.max(0, launcherWindow.selectedIndex - 1);
                            }
                            Keys.onReturnPressed: {
                                if (launcherWindow.filteredApps.length > launcherWindow.selectedIndex) {
                                    const targetApp = launcherWindow.filteredApps[launcherWindow.selectedIndex];
                                    SageState.launchApp(targetApp.exec);
                                }
                            }
                        }
                    }
                }

                // Quick Special Workspace Summon Row (Caelestia Quick Row)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: SageState.specialWorkspaces

                        Rectangle {
                            id: quickWsBtn
                            required property var modelData
                            Layout.fillWidth: true
                            height: 28
                            radius: 4
                            color: SageState.bgCard
                            border.width: 1
                            border.color: Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.45)

                            Text {
                                anchors.centerIn: parent
                                text: "◈ " + quickWsBtn.modelData.label + " (" + quickWsBtn.modelData.bind + ")"
                                color: SageState.primaryAccent
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    SageState.launcherOpen = false;
                                    SageState.toggleSpecialWs(quickWsBtn.modelData.id);
                                }
                            }
                        }
                    }
                }

                // Application Results List
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: appCol.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: appCol
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: launcherWindow.filteredApps

                            Rectangle {
                                id: appRow
                                required property var modelData
                                required property int index
                                readonly property bool isSel: index === launcherWindow.selectedIndex

                                Layout.fillWidth: true
                                height: 46
                                radius: 5
                                color: isSel || appMouse.containsMouse
                                       ? Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.22)
                                       : SageState.bgCard
                                border.width: 1
                                border.color: isSel
                                              ? SageState.secondaryAccent
                                              : Qt.rgba(SageState.primaryAccent.r, SageState.primaryAccent.g, SageState.primaryAccent.b, 0.28)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        width: 26
                                        height: 26
                                        radius: 4
                                        color: SageState.bgSurface
                                        border.width: 1
                                        border.color: appRow.isSel ? SageState.secondaryAccent : SageState.primaryAccent

                                        Text {
                                            anchors.centerIn: parent
                                            text: appRow.modelData.name !== undefined && appRow.modelData.name.length > 0
                                                  ? appRow.modelData.name.substring(0, 2).toUpperCase()
                                                  : "AP"
                                            color: appRow.isSel ? SageState.secondaryAccent : SageState.primaryAccent
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            Layout.fillWidth: true
                                            text: appRow.modelData.name !== undefined ? appRow.modelData.name : "Application"
                                            color: SageState.textPrimary
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 12
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: appRow.modelData.desc !== undefined && appRow.modelData.desc.length > 0
                                                  ? appRow.modelData.desc
                                                  : appRow.modelData.exec
                                            color: SageState.textMuted
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        text: "SUMMON ▸"
                                        color: appRow.isSel ? SageState.secondaryAccent : SageState.primaryAccent
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: launcherWindow.selectedIndex = appRow.index
                                    onClicked: SageState.launchApp(appRow.modelData.exec)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
