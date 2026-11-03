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
    RightSideSliders {}
    SageOsd {}
    TrayPopupMenu {}

    // IPC Handler for Keyboard Shortcuts (`quickshell ipc call sage <fn>`)
    IpcHandler {
        target: "sage"

        function volumeUp() {
            SageState.osdVolume("up");
        }

        function volumeDown() {
            SageState.osdVolume("down");
        }

        function volumeMute() {
            SageState.osdVolume("mute");
        }

        function micMute() {
            SageState.osdVolume("mic");
        }

        function brightnessUp() {
            SageState.osdBrightness("up");
        }

        function brightnessDown() {
            SageState.osdBrightness("down");
        }

        function toggleSettings() {
            SageState.toggleDashboard();
        }

        function superPress() {
            SageState.superPress();
        }

        function superCancel() {
            SageState.superCancel();
        }

        function superRelease() {
            SageState.superRelease();
        }

        function toggleLauncher() {
            SageState.toggleLauncher();
        }

        function toggleTopDropdown() {
            SageState.toggleTopDropdown();
        }

        function toggleCornerMenu() {
            SageState.toggleSideSliders();
        }

        function toggleSideSliders() {
            SageState.toggleSideSliders();
        }

        function toggleKeybinds() {
            if (SageState.dashboardOpen && SageState.activeTab === 5) {
                SageState.dashboardOpen = false;
            } else {
                SageState.openDashboardTab(5);
            }
        }

        function openSpecialWs() {
            SageState.openDashboardTab(1);
        }

        function openWallpapers() {
            SageState.openDashboardTab(2);
        }

        function openDisplays() {
            SageState.openDashboardTab(3);
        }

        function nextWallpaper() {
            SageState.cycleWallpaper();
        }

        function openNetwork() {
            SageState.openDashboardTab(4);
        }
    }
}
