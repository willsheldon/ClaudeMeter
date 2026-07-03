import AppKit
import SwiftUI

/// App delegate to manage menu bar lifecycle.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var appModel: AppModel?
    private var menuBarManager: MenuBarManager?

    #if DEBUG
    private var isDemoMode: Bool = false
    private var automationWindow: NSWindow?
    #endif

    func configure(appModel: AppModel) {
        self.appModel = appModel
    }

    #if DEBUG
    func configureDemoMode(_ enabled: Bool) {
        isDemoMode = enabled
    }
    #endif

    func applicationDidFinishLaunching(_ notification: Notification) {
        SessionKeyImportPromptCoordinator.install()

        guard let appModel else {
            let fallbackModel = AppModel()
            self.appModel = fallbackModel
            startMenuBar(with: fallbackModel)
            return
        }
        startMenuBar(with: appModel)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func startMenuBar(with appModel: AppModel) {
        let manager = MenuBarManager(appModel: appModel)
        menuBarManager = manager

        #if DEBUG
        if isDemoMode {
            manager.startWithoutBootstrap()
        } else {
            manager.start()
        }

        if ProcessInfo.processInfo.arguments.contains("--open-popover-after-launch") {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(500))
                showAutomationWindow(with: appModel)
            }
        }
        #else
        manager.start()
        #endif
    }

    #if DEBUG
    private func showAutomationWindow(with appModel: AppModel) {
        let markerURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop/pinemeter-vm-validation/debug-window-hook-ran.txt")
        try? FileManager.default.createDirectory(
            at: markerURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? "debug_window_hook_ran=true\n".write(to: markerURL, atomically: true, encoding: .utf8)

        NSApp.setActivationPolicy(.regular)

        if let automationWindow {
            automationWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 720),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Pinemeter Automation"
        window.contentViewController = NSHostingController(
            rootView: MenuBarPopoverView(appModel: appModel) { [weak self] in
                self?.automationWindow?.close()
            }
        )
        window.center()
        window.makeKeyAndOrderFront(nil)
        automationWindow = window
        NSApp.activate(ignoringOtherApps: true)
    }
    #endif
}
