import Foundation
import SwiftUI

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case high, medium, low
    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var colors: [Color] {
        switch self {
        case .high:
            return [Color(red: 0.83, green: 0.23, blue: 0.31), Color(red: 0.94, green: 0.42, blue: 0.24)]
        case .medium:
            return [Color(red: 0.82, green: 0.54, blue: 0.09), Color(red: 0.91, green: 0.72, blue: 0.18)]
        case .low:
            return [Color(red: 0.08, green: 0.55, blue: 0.45), Color(red: 0.14, green: 0.70, blue: 0.61)]
        }
    }
}

struct HeadRoomTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var priority: TaskPriority = .medium
    var isDone: Bool = false
    var dueDate: Date?
    var tag: String = ""
    var notes: String = ""
    var createdAt: Date = Date()
}

enum TaskViewSize: String, CaseIterable, Identifiable {
    case compact
    case defaultSize = "default"
    case expanded
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum TaskViewStyle: String, CaseIterable, Identifiable {
    case card, list, board
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}
