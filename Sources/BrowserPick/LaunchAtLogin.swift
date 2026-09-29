import Foundation
import os
import ServiceManagement

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "BrowserPick", category: "LaunchAtLogin")

enum LaunchAtLogin {
    static var isEnabled: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue {
                    if SMAppService.mainApp.status == .enabled { return }
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                logger.error("BrowserPick: failed to toggle launch at login: \(error.localizedDescription)")
            }
        }
    }
}
