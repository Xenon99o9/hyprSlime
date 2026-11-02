//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    TopBar {}
    KeybindsSheet {}
    ControlCenter {}

    // IPC Handler for Keyboard Shortcuts (e.g., `quickshell ipc call sage toggleSettings`)
    IpcHandler {
        target: "sage"

        function toggleSettings() {
            SageState.controlCenterOpen = !SageState.controlCenterOpen;
            if (SageState.controlCenterOpen) SageState.keybindsOpen = false;
        }

        function toggleKeybinds() {
            SageState.keybindsOpen = !SageState.keybindsOpen;
            if (SageState.keybindsOpen) SageState.controlCenterOpen = false;
        }

        function openNetwork() {
            SageState.activeTab = 1;
            SageState.controlCenterOpen = true;
            SageState.keybindsOpen = false;
            SageState.scanWifi();
        }
    }
}

