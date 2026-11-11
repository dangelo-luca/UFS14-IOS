import SwiftUI

enum ColoreBuild: String, Codable, CaseIterable {
    case blu, viola, arancione, verde, rosa, indaco

    var swiftUI: Color {
        switch self {
        case .blu: return .blue
        case .viola: return .purple
        case .arancione: return .orange
        case .verde: return .green
        case .rosa: return .pink
        case .indaco: return .indigo
        }
    }
}
