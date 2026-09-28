import Foundation

extension Calendar {
    static var headRoom: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
}

extension HeadRoomTask {
    var schedulingDate: Date { dueDate ?? createdAt }

    var weekStart: Date {
        let calendar = Calendar.headRoom
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: schedulingDate)
        return calendar.date(from: components) ?? calendar.startOfDay(for: schedulingDate)
    }
}

func weekLabel(for start: Date) -> String {
    let calendar = Calendar.headRoom
    let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
    let startFormatter = DateFormatter()
    startFormatter.dateFormat = "d MMM"
    let endFormatter = DateFormatter()
    endFormatter.dateFormat = "d MMM yyyy"
    return "\(startFormatter.string(from: start)) – \(endFormatter.string(from: end))"
}

func shortDate(_ date: Date?) -> String {
    guard let date else { return "No due date" }
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, d MMM"
    return formatter.string(from: date)
}
