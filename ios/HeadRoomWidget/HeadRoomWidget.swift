import WidgetKit
import SwiftUI
import AppIntents

struct HeadRoomWidgetEntry: TimelineEntry {
    let date: Date
    let task: HeadRoomTask?
    let position: Int
    let total: Int
    let missedCount: Int
    let missedTitles: [String]
    let showsMissedCard: Bool
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
            total: 1,
            missedCount: 0,
            missedTitles: [],
            showsMissedCard: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HeadRoomWidgetEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeadRoomWidgetEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date())))
    }

    private func entry() -> HeadRoomWidgetEntry {
        let tasks = TaskStore.loadTasks().sorted { $0.schedulingDate < $1.schedulingDate }
        let missed = tasks.filter(\.isMissed)
        let hasMissedCard = !missed.isEmpty
        let total = tasks.count + (hasMissedCard ? 1 : 0)
        let defaults = TaskStore.defaults()
        let rawIndex = defaults.integer(forKey: "widget.index")
        let index = total == 0 ? 0 : rawIndex % total
        let showsMissed = hasMissedCard && index == 0
        let taskIndex = index - (hasMissedCard ? 1 : 0)
        let task = showsMissed || tasks.isEmpty || taskIndex < 0 ? nil : tasks[taskIndex]

        return HeadRoomWidgetEntry(
            date: Date(),
            task: task,
            position: index,
            total: total,
            missedCount: missed.count,
            missedTitles: Array(missed.prefix(3).map(\.title)),
            showsMissedCard: showsMissed
        )
    }
}

struct HeadRoomWidgetView: View {
    let entry: HeadRoomWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.16)

            if entry.showsMissedCard {
                missedCard
            } else if let task = entry.task {
                taskCard(task)
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

    private var missedCard: some View {
        ZStack {
            stackedEdges

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("MISSED")
                        .font(.caption2.weight(.black))
                        .tracking(1.5)
                    Spacer()
                    Text("\(entry.position + 1)/\(entry.total)")
                        .font(.caption2.weight(.bold))
                        .opacity(0.75)
                }

                Text(entry.missedCount == 1 ? "1 MISSED TASK" : "\(entry.missedCount) MISSED TASKS")
                    .font(.system(size: family == .systemLarge ? 25 : 21, weight: .black, design: .rounded))

                Text("Needs attention")
                    .font(.caption.weight(.bold))
                    .opacity(0.78)

                if !entry.missedTitles.isEmpty {
                    Text(entry.missedTitles.joined(separator: "  •  "))
                        .font(.caption)
                        .opacity(0.86)
                        .lineLimit(family == .systemLarge ? 4 : 2)
                }

                Spacer(minLength: 2)

                Button(intent: NextCardIntent()) {
                    Label("NEXT", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 8)
                .background(.white.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .font(.caption2.weight(.black))
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.63, green: 0.16, blue: 0.28), Color(red: 0.82, green: 0.33, blue: 0.23)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.25)))
        }
        .padding(2)
    }

    private func taskCard(_ task: HeadRoomTask) -> some View {
        ZStack {
            stackedEdges

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
    }

    private var stackedEdges: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.05))
                .offset(y: 10)
                .scaleEffect(0.94)
            RoundedRectangle(cornerRadius: 22)
                .fill(.white.opacity(0.08))
                .offset(y: 6)
                .scaleEffect(0.97)
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
