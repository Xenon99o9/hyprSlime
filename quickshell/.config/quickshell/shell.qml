//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    TopBar {}
    CentralDashboard {}
    TopCenterMenu {}
    BottomLauncher {}
    BottomRightMenu {}

    // IPC Handler for Keyboard Shortcuts (`quickshell ipc call sage <fn>`)
    IpcHandler {
        target: "sage"

        function toggleSettings() {
            SageState.toggleDashboard();
        }

        function toggleLauncher() {
            SageState.toggleLauncher();
        }

        function toggleTopDropdown() {
            SageState.toggleTopDropdown();
        }

        function toggleCornerMenu() {
            SageState.toggleCornerMenu();
        }

        function toggleKeybinds() {
            if (SageState.dashboardOpen && SageState.activeTab === 4) {
                SageState.dashboardOpen = false;
            } else {
                SageState.openDashboardTab(4);
            }
        }

        function openSpecialWs() {
            SageState.openDashboardTab(1);
        }

        function openWallpapers() {
            SageState.openDashboardTab(2);
        }

        function nextWallpaper() {
            SageState.cycleWallpaper();
        }

        function openNetwork() {
            SageState.openDashboardTab(3);
        }
    }
}
