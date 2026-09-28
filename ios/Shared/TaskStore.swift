import Foundation
import WidgetKit

@MainActor
final class TaskStore: ObservableObject {
    static let suiteName = "group.com.amit.headroom"
    static let tasksKey = "headroom.tasks"

    @Published private(set) var tasks: [HeadRoomTask] = []

    init() { reload() }

    func reload() {
        tasks = Self.loadTasks()
    }

    func upsert(_ task: HeadRoomTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
        persist()
    }

    func toggle(_ task: HeadRoomTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        persist()
    }

    func delete(_ task: HeadRoomTask) {
        tasks.removeAll { $0.id == task.id }
        persist()
    }

    private func persist() {
        Self.saveTasks(tasks)
        WidgetCenter.shared.reloadAllTimelines()
    }

    nonisolated static func defaults() -> UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    nonisolated static func loadTasks() -> [HeadRoomTask] {
        guard let data = defaults().data(forKey: tasksKey),
              let tasks = try? JSONDecoder().decode([HeadRoomTask].self, from: data) else { return [] }
        return tasks
    }

    nonisolated static func saveTasks(_ tasks: [HeadRoomTask]) {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        defaults().set(data, forKey: tasksKey)
    }

    nonisolated static func toggleTask(id: UUID) {
        var tasks = loadTasks()
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isDone.toggle()
        saveTasks(tasks)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
