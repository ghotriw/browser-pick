import AppKit
import SwiftUI

/// Borderless panel that still accepts key events.
private final class ChooserPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

final class ChooserWindowController: NSWindowController, NSWindowDelegate {
    private let store: BrowserStore
    private let onPick: (Browser, WebURLRequest) -> Void
    private var requests = FIFOQueue<WebURLRequest>()
    private var clickMonitor: Any?
    private var lastPickTime: Date?

    init(store: BrowserStore, onPick: @escaping (Browser, WebURLRequest) -> Void) {
        self.store = store
        self.onPick = onPick

        let panel = ChooserPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 200),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]

        super.init(window: panel)
        panel.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func enqueue(_ request: WebURLRequest) {
        let shouldPresent = requests.current == nil
        requests.enqueue(request)
        if shouldPresent {
            showCurrent()
        }
    }

    private func showCurrent() {
        guard let request = requests.current else {
            hide()
            return
        }

        let view = ChooserView(
            store: store,
            request: request,
            onPick: { [weak self] browser in
                guard let self, let completedRequest = self.requests.completeCurrent() else { return }
                self.lastPickTime = Date()
                self.onPick(browser, completedRequest)
                self.showCurrent()
            },
            onCancel: { [weak self] in
                self?.requests.cancelCurrent()
                self?.showCurrent()
            }
        )
        window?.contentViewController = NSHostingController(rootView: view)

        // Size to fit content
        if let window {
            window.layoutIfNeeded()
            let fitted = window.contentViewController?.view.fittingSize ?? NSSize(width: 380, height: 200)
            window.setContentSize(fitted)

            switch store.chooserPosition {
            case .mouseCursor:
                positionWindowNearMouse(window: window, size: fitted)
            case .screenCenter:
                window.center()
            }
        }

        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        installClickMonitor()
    }

    private func positionWindowNearMouse(window: NSWindow, size: NSSize) {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSPointInRect(mouse, $0.frame) }
            ?? NSScreen.main
            ?? NSScreen.screens.first

        guard let screen else {
            window.center()
            return
        }

        let visible = screen.visibleFrame
        let padding: CGFloat = 12
        let cursorOffset: CGFloat = 10

        // 1. Center horizontally around cursor and clamp to visible bounds
        var originX = mouse.x - (size.width / 2)
        originX = max(visible.minX + padding, min(originX, visible.maxX - size.width - padding))

        // 2. Position vertically: default to below cursor
        var originY = mouse.y - size.height - cursorOffset

        // If it doesn't fit below, place it above cursor
        if originY < visible.minY + padding {
            originY = mouse.y + cursorOffset
        }

        // Clamp to screen bounds
        originY = max(visible.minY + padding, min(originY, visible.maxY - size.height - padding))

        window.setFrameOrigin(NSPoint(x: originX, y: originY))
    }

    func hide() {
        removeClickMonitor()
        window?.orderOut(nil)
        requests = FIFOQueue<WebURLRequest>()
    }

    private func installClickMonitor() {
        guard clickMonitor == nil else { return }
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.hide()
        }
    }

    private func removeClickMonitor() {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
    }

    func windowDidResignKey(_ notification: Notification) {
        if Date().timeIntervalSince(lastPickTime ?? .distantPast) < 1.0 {
            if requests.current != nil {
                window?.makeKeyAndOrderFront(nil)
                window?.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
            }
            return
        }
        hide()
    }
}
