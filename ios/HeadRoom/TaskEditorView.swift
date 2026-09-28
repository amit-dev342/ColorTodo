import SwiftUI

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let original: HeadRoomTask?
    let onSave: (HeadRoomTask) -> Void

    @State private var title: String
    @State private var priority: TaskPriority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var tag: String
    @State private var notes: String

    init(task: HeadRoomTask?, onSave: @escaping (HeadRoomTask) -> Void) {
        original = task
        self.onSave = onSave
        _title = State(initialValue: task?.title ?? "")
        _priority = State(initialValue: task?.priority ?? .medium)
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _dueDate = State(initialValue: task?.dueDate ?? Date())
        _tag = State(initialValue: task?.tag ?? "")
        _notes = State(initialValue: task?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.06, green: 0.08, blue: 0.16), Color(red: 0.13, green: 0.09, blue: 0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        field("Task title", text: $title)
                        field("Tag", text: $tag)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("PRIORITY").sectionLabel()
                            Picker("Priority", selection: $priority) {
                                ForEach(TaskPriority.allCases) { Text($0.title).tag($0) }
                            }
                            .pickerStyle(.segmented)
                        }
                        .layeredField()

                        VStack(alignment: .leading, spacing: 10) {
                            Toggle("Due date", isOn: $hasDueDate)
                                .font(.headline)
                            if hasDueDate {
                                DatePicker("Select date", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .tint(Color(red: 0.55, green: 0.49, blue: 1))
                            }
                        }
                        .layeredField()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("NOTES").sectionLabel()
                            TextEditor(text: $notes)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 110)
                        }
                        .layeredField()
                    }
                    .padding(20)
                }
            }
            .navigationTitle(original == nil ? "New task" : "Edit task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var task = original ?? HeadRoomTask(title: title)
                        task.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        task.priority = priority
                        task.dueDate = hasDueDate ? dueDate : nil
                        task.tag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
                        task.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !task.title.isEmpty else { return }
                        onSave(task)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased()).sectionLabel()
            TextField(title, text: text)
                .textInputAutocapitalization(.sentences)
        }
        .layeredField()
    }
}

private extension View {
    func layeredField() -> some View {
        self
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.10), Color.white.opacity(0.045)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.12)))
            .shadow(color: .black.opacity(0.25), radius: 10, y: 7)
    }

    func sectionLabel() -> some View {
        self
            .font(.caption2.weight(.black))
            .tracking(1.5)
            .foregroundStyle(.white.opacity(0.5))
    }
}
