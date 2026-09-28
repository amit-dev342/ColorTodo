import SwiftUI

struct ViewOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sizeRaw: String
    @Binding var styleRaw: String

    var body: some View {
        NavigationStack {
            Form {
                Section("Task size") {
                    Picker("Task size", selection: $sizeRaw) {
                        ForEach(TaskViewSize.allCases) { Text($0.title).tag($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Layout") {
                    Picker("Layout", selection: $styleRaw) {
                        ForEach(TaskViewStyle.allCases) { Text($0.title).tag($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.06, green: 0.08, blue: 0.15))
            .navigationTitle("View options")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
