import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController {
    convenience init(store: BrowserStore) {
        let hosting = NSHostingController(rootView: SettingsView(store: store))
        let window = NSWindow(contentViewController: hosting)
        window.title = "BrowserPick Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 560, height: 560))
        window.isReleasedWhenClosed = false
        window.center()
        self.init(window: window)
    }

    override func showWindow(_ sender: Any?) {
        window?.center()
        window?.makeKeyAndOrderFront(sender)
        window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
}
