import AppIntents
import WidgetKit
import Foundation

struct NextCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Next task"

    func perform() async throws -> some IntentResult {
        let tasks = TaskStore.loadTasks()
        let hasMissedCard = tasks.contains(where: \.isMissed)
        let total = tasks.count + (hasMissedCard ? 1 : 0)
        let defaults = TaskStore.defaults()
        guard total > 0 else { return .result() }
        let next = (defaults.integer(forKey: "widget.index") + 1) % total
        defaults.set(next, forKey: "widget.index")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle task"

    @Parameter(title: "Task ID")
    var taskID: String

    init() {
        taskID = ""
    }

    init(taskID: String) {
        self.taskID = taskID
    }

    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: taskID) else { return .result() }
        TaskStore.toggleTask(id: id)
        return .result()
    }
}
