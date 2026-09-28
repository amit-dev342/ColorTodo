import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TaskStore
    @AppStorage("view.size", store: TaskStore.defaults()) private var sizeRaw = TaskViewSize.defaultSize.rawValue
    @AppStorage("view.style", store: TaskStore.defaults()) private var styleRaw = TaskViewStyle.card.rawValue
    @State private var editor: HeadRoomTask?
    @State private var showNewTask = false
    @State private var showViewOptions = false

    private var size: TaskViewSize { TaskViewSize(rawValue: sizeRaw) ?? .defaultSize }
    private var style: TaskViewStyle { TaskViewStyle(rawValue: styleRaw) ?? .card }
    private var activeCount: Int { store.tasks.filter { !$0.isDone }.count }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.12),
                    Color(red: 0.08, green: 0.10, blue: 0.18),
                    Color(red: 0.13, green: 0.08, blue: 0.17)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                sectionHeader
                taskContent
            }

            Button {
                showNewTask = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.40, green: 0.34, blue: 0.91), Color(red: 0.63, green: 0.30, blue: 0.87)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.25), lineWidth: 1))
                    .shadow(color: .purple.opacity(0.35), radius: 18, y: 10)
            }
            .padding(24)
        }
        .sheet(isPresented: $showNewTask) {
            TaskEditorView(task: nil) { store.upsert($0) }
        }
        .sheet(item: $editor) { task in
            TaskEditorView(task: task) { store.upsert($0) }
        }
        .sheet(isPresented: $showViewOptions) {
            ViewOptionsView(sizeRaw: $sizeRaw, styleRaw: $styleRaw)
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("HEAD ROOM")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .tracking(2.1)
                    .foregroundStyle(.white)
                Text("MAKE SPACE. MOVE FORWARD.")
                    .font(.caption2.weight(.bold))
                    .tracking(2.0)
                    .foregroundStyle(Color.white.opacity(0.42))
            }
            Spacer()
            Button { showViewOptions = true } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.13)))
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 22)
    }

    private var sectionHeader: some View {
        HStack {
            Text("MY TASKS")
                .font(.caption.weight(.black))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.68))
            Spacer()
            Text("\(activeCount) ACTIVE")
                .font(.caption2.weight(.black))
                .tracking(1.4)
                .foregroundStyle(Color(red: 0.55, green: 0.49, blue: 1))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var taskContent: some View {
        if store.tasks.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(red: 0.55, green: 0.49, blue: 1))
                Text("Nothing pending")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text("Your space is clear. Add something when it matters.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        } else {
            ScrollView {
                LazyVStack(spacing: style == .list ? 6 : 16) {
                    if style == .board {
                        ForEach(TaskPriority.allCases) { priority in
                            BoardSection(
                                priority: priority,
                                tasks: store.tasks.filter { $0.priority == priority },
                                size: size,
                                onToggle: store.toggle,
                                onEdit: { editor = $0 },
                                onDelete: store.delete
                            )
                        }
                    } else {
                        let sorted = store.tasks.sorted { $0.schedulingDate < $1.schedulingDate }
                        let grouped = Dictionary(grouping: sorted, by: \.weekStart)
                        ForEach(grouped.keys.sorted(), id: \.self) { week in
                            WeekSection(
                                week: week,
                                tasks: grouped[week] ?? [],
                                size: size,
                                style: style,
                                onToggle: store.toggle,
                                onEdit: { editor = $0 },
                                onDelete: store.delete
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
    }
}

struct WeekSection: View {
    let week: Date
    let tasks: [HeadRoomTask]
    let size: TaskViewSize
    let style: TaskViewStyle
    let onToggle: (HeadRoomTask) -> Void
    let onEdit: (HeadRoomTask) -> Void
    let onDelete: (HeadRoomTask) -> Void
    @State private var expanded = true

    var body: some View {
        VStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    expanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    Text(weekLabel(for: week))
                    Spacer()
                    Text("\(tasks.count)")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.72))
                .padding(.horizontal, 18)
                .frame(height: 48)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.15, green: 0.18, blue: 0.29), Color(red: 0.10, green: 0.13, blue: 0.23)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.12)))
                .shadow(color: .black.opacity(0.3), radius: 10, y: 7)
            }

            if expanded {
                ForEach(tasks) { task in
                    TaskCard(
                        task: task,
                        size: size,
                        style: style,
                        onToggle: { onToggle(task) },
                        onEdit: { onEdit(task) },
                        onDelete: { onDelete(task) }
                    )
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                }
            }
        }
    }
}

struct BoardSection: View {
    let priority: TaskPriority
    let tasks: [HeadRoomTask]
    let size: TaskViewSize
    let onToggle: (HeadRoomTask) -> Void
    let onEdit: (HeadRoomTask) -> Void
    let onDelete: (HeadRoomTask) -> Void

    var body: some View {
        if !tasks.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(priority.title.uppercased()) PRIORITY   \(tasks.count)")
                    .font(.caption2.weight(.black))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.62))
                    .padding(.leading, 6)

                ForEach(tasks) { task in
                    TaskCard(
                        task: task,
                        size: size,
                        style: .card,
                        onToggle: { onToggle(task) },
                        onEdit: { onEdit(task) },
                        onDelete: { onDelete(task) }
                    )
                }
            }
        }
    }
}
