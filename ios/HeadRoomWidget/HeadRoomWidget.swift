import WidgetKit
import SwiftUI
import AppIntents

struct HeadRoomWidgetEntry: TimelineEntry {
    let date: Date
    let task: HeadRoomTask?
    let position: Int
    let total: Int
}

struct HeadRoomWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HeadRoomWidgetEntry {
        HeadRoomWidgetEntry(
            date: Date(),
            task: HeadRoomTask(
                title: "Plan tomorrow",
                priority: .medium,
                dueDate: Date(),
                tag: "Personal",
                notes: "A little space for what matters next."
            ),
            position: 0,
            total: 1
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HeadRoomWidgetEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeadRoomWidgetEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .never))
    }

    private func entry() -> HeadRoomWidgetEntry {
        let tasks = TaskStore.loadTasks().sorted { $0.schedulingDate < $1.schedulingDate }
        let defaults = TaskStore.defaults()
        let rawIndex = defaults.integer(forKey: "widget.index")
        let index = tasks.isEmpty ? 0 : rawIndex % tasks.count
        return HeadRoomWidgetEntry(
            date: Date(),
            task: tasks.isEmpty ? nil : tasks[index],
            position: index,
            total: tasks.count
        )
    }
}

struct HeadRoomWidgetView: View {
    let entry: HeadRoomWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.16)

            if let task = entry.task {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.white.opacity(0.05))
                        .offset(y: 10)
                        .scaleEffect(0.94)

                    RoundedRectangle(cornerRadius: 22)
                        .fill(.white.opacity(0.08))
                        .offset(y: 6)
                        .scaleEffect(0.97)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("HEAD ROOM")
                                .font(.caption2.weight(.black))
                                .tracking(1.4)
                            Spacer()
                            Text("\(entry.position + 1)/\(entry.total)")
                                .font(.caption2.weight(.bold))
                                .opacity(0.75)
                        }

                        Text(task.title)
                            .font(.system(size: family == .systemLarge ? 22 : 18, weight: .black, design: .rounded))
                            .strikethrough(task.isDone)
                            .lineLimit(2)

                        Text(weekLabel(for: task.weekStart))
                            .font(.caption2.weight(.bold))
                            .opacity(0.72)

                        HStack(spacing: 6) {
                            widgetPill(shortDate(task.dueDate))
                            widgetPill(task.priority.title.uppercased())
                            if !task.tag.isEmpty {
                                widgetPill(task.tag.uppercased())
                            }
                        }

                        if !task.notes.isEmpty {
                            Text(task.notes)
                                .font(.caption)
                                .opacity(0.8)
                                .lineLimit(family == .systemLarge ? 4 : 2)
                        }

                        Spacer(minLength: 2)

                        HStack(spacing: 8) {
                            Button(intent: ToggleTaskIntent(taskID: task.id.uuidString)) {
                                Label(task.isDone ? "ACTIVE" : "DONE", systemImage: task.isDone ? "arrow.uturn.backward" : "checkmark")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.16))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            Button(intent: NextCardIntent()) {
                                Label("NEXT", systemImage: "arrow.right")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.16))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .font(.caption2.weight(.black))
                    }
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(
                        LinearGradient(
                            colors: task.isDone
                                ? [Color(red: 0.26, green: 0.29, blue: 0.41), Color(red: 0.18, green: 0.22, blue: 0.31)]
                                : task.priority.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.25)))
                }
                .padding(2)
            } else {
                VStack(spacing: 8) {
                    Text("HEAD ROOM")
                        .font(.caption.weight(.black))
                        .tracking(1.6)
                    Text("Nothing pending")
                        .font(.headline)
                    Text("Open Head Room to add a task.")
                        .font(.caption)
                        .opacity(0.6)
                }
                .foregroundStyle(.white)
            }
        }
        .containerBackground(for: .widget) {
            Color(red: 0.07, green: 0.09, blue: 0.16)
        }
    }

    private func widgetPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .lineLimit(1)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(.white.opacity(0.16))
            .clipShape(Capsule())
    }
}

@main
struct HeadRoomWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HeadRoomWidget", provider: HeadRoomWidgetProvider()) { entry in
            HeadRoomWidgetView(entry: entry)
        }
        .configurationDisplayName("Head Room")
        .description("See one full task card at a time and move through your stack.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
