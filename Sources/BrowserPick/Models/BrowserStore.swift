import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class BrowserStore {
    private(set) var browsers: [Browser] = []
    var chooserPosition: ChooserPosition = .mouseCursor {
        didSet {
            defaults.set(chooserPosition.rawValue, forKey: chooserPositionKey)
        }
    }

    private let storageKey = "browsers"
    private let chooserPositionKey = "chooserPosition"
    private let defaults = UserDefaults.standard

    init() {
        load()
        if browsers.isEmpty {
            browsers = Browser.discoverInstalled()
            save()
        }
    }

    func add(_ browser: Browser) {
        guard !browsers.contains(where: { $0.bundleIdentifier == browser.bundleIdentifier }) else {
            return
        }
        browsers.append(browser)
        save()
    }

    func remove(at offsets: IndexSet) {
        browsers.remove(atOffsets: offsets)
        save()
    }

    func remove(_ browser: Browser) {
        browsers.removeAll { $0.bundleIdentifier == browser.bundleIdentifier }
        save()
    }

    func update(_ browser: Browser) {
        guard let idx = browsers.firstIndex(where: { $0.bundleIdentifier == browser.bundleIdentifier }) else {
            return
        }
        browsers[idx] = browser
        save()
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        browsers.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func move(fromId: String, toId: String) {
        guard let sourceIndex = browsers.firstIndex(where: { $0.id == fromId }),
              let targetIndex = browsers.firstIndex(where: { $0.id == toId }),
              sourceIndex != targetIndex else { return }

        let item = browsers.remove(at: sourceIndex)
        let destinationIndex = browsers.firstIndex(where: { $0.id == toId })!
        let insertIndex = sourceIndex < targetIndex ? destinationIndex + 1 : destinationIndex
        browsers.insert(item, at: insertIndex)
        save()
    }

    func moveUp(id: String) {
        guard let index = browsers.firstIndex(where: { $0.id == id }), index > 0 else { return }
        browsers.swapAt(index, index - 1)
        save()
    }

    func moveDown(id: String) {
        guard let index = browsers.firstIndex(where: { $0.id == id }), index < browsers.count - 1 else { return }
        browsers.swapAt(index, index + 1)
        save()
    }

    func rediscover() {
        let discovered = Browser.discoverInstalled()
        let existingIDs = Set(browsers.map(\.bundleIdentifier))
        for b in discovered where !existingIDs.contains(b.bundleIdentifier) {
            browsers.append(b)
        }
        save()
    }

    func browser(forShortcut key: String) -> Browser? {
        browsers.first { $0.shortcut?.lowercased() == key.lowercased() }
    }

    func browser(at index: Int) -> Browser? {
        guard browsers.indices.contains(index) else { return nil }
        return browsers[index]
    }

    private func load() {
        if let raw = defaults.string(forKey: chooserPositionKey),
           let pos = ChooserPosition(rawValue: raw) {
            chooserPosition = pos
        }

        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Browser].self, from: data) else {
            return
        }
        browsers = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(browsers) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
