import AppIntents
import WidgetKit
import Foundation

struct NextCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Next task"

    func perform() async throws -> some IntentResult {
        let tasks = TaskStore.loadTasks()
        let defaults = TaskStore.defaults()
        guard !tasks.isEmpty else { return .result() }
        let next = (defaults.integer(forKey: "widget.index") + 1) % tasks.count
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
