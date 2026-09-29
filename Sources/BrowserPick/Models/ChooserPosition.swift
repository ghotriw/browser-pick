import Foundation

enum ChooserPosition: String, Codable, CaseIterable, Identifiable {
    case mouseCursor = "mouseCursor"
    case screenCenter = "screenCenter"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mouseCursor:
            return "Under mouse cursor"
        case .screenCenter:
            return "Center of screen"
        }
    }
}
