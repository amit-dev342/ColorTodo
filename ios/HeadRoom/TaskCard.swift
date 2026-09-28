import SwiftUI

struct TaskCard: View {
    let task: HeadRoomTask
    let size: TaskViewSize
    let style: TaskViewStyle
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    @GestureState private var pressing = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .font(.system(size: size == .compact ? 16 : 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .strikethrough(task.isDone, color: .white.opacity(0.6))
                    .opacity(task.isDone ? 0.55 : 1)

                if size != .compact {
                    HStack(spacing: 6) {
                        if let date = task.dueDate { pill(shortDate(date)) }
                        if !task.tag.isEmpty { pill(task.tag) }
                        pill(task.priority.title.uppercased())
                    }
                }

                if size == .expanded && !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 6)

            Menu {
                Button("Edit task", systemImage: "pencil", action: onEdit)
                Button(
                    task.isDone ? "Mark active" : "Mark complete",
                    systemImage: task.isDone ? "arrow.uturn.backward.circle" : "checkmark.circle",
                    action: onToggle
                )
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 36, height: 44)
            }
        }
        .padding(size == .compact ? 14 : size == .expanded ? 20 : 18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.24), lineWidth: 1))
        .shadow(
            color: shadowColor.opacity(style == .list ? 0.16 : 0.40),
            radius: style == .list ? 4 : 16,
            y: style == .list ? 3 : 10
        )
        .scaleEffect(pressing ? 0.975 : 1)
        .animation(.spring(response: 0.28, dampingFraction: 0.68), value: pressing)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($pressing) { _, state, _ in state = true }
        )
        .onTapGesture(count: 2) {
            onToggle()
        }
        .onLongPressGesture(minimumDuration: 0.55) {
            onDelete()
        }
    }

    private var cardBackground: some View {
        let colors = task.isDone
            ? [Color(red: 0.26, green: 0.29, blue: 0.41), Color(red: 0.18, green: 0.22, blue: 0.31)]
            : task.priority.colors
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var shadowColor: Color {
        task.isDone ? .black : task.priority.colors.first ?? .black
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(.white.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.16)))
    }
}
