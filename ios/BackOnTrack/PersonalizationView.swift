import SwiftUI

struct PersonalizationView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var focusArea = "none"
    @State private var customFocus = ""
    @State private var supports: Set<String> = ["pause", "smallSteps"]

    private let options = [
        ("coding", "Coding / AI"), ("gaming", "Gaming"), ("scrolling", "Scrolling"),
        ("shopping", "Shopping"), ("food", "Food"), ("other", "Something else"), ("none", "Nothing specific")
    ]
    private let supportOptions = [
        ("pause", "60-second pause"), ("smallSteps", "Smallest steps"), ("sleep", "Sleep logging"),
        ("evening", "Evening alternatives"), ("movement", "Movement"), ("selfreg", "Self-regulation")
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("What tends to pull you in?") {
                    Picker("Focus", selection: $focusArea) {
                        ForEach(options, id: \.0) { Text($0.1).tag($0.0) }
                    }
                    if focusArea == "other" {
                        TextField("Your own words", text: $customFocus)
                    }
                }
                Section("Support cards") {
                    ForEach(supportOptions, id: \.0) { option in
                        Toggle(option.1, isOn: Binding(
                            get: { supports.contains(option.0) },
                            set: { if $0 { supports.insert(option.0) } else { supports.remove(option.0) } }
                        ))
                    }
                }
            }
            .navigationTitle("Make it yours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() } }
            }
            .onAppear {
                let p = store.state.settings.personalization ?? Personalization()
                focusArea = p.focusArea
                customFocus = p.customFocus
                supports = Set(p.supports)
            }
        }
    }

    private func save() {
        let label: String
        switch focusArea {
        case "coding": label = "Coding"
        case "gaming": label = "Gaming"
        case "scrolling": label = "Scrolling"
        case "shopping": label = "Shopping"
        case "food": label = "Food"
        case "other": label = customFocus.isEmpty ? "This" : customFocus
        default: label = "a gentle pause"
        }
        let current = store.state.settings.personalization ?? Personalization()
        store.state.settings.personalization = Personalization(
            onboardingComplete: true,
            focusArea: focusArea,
            focusLabel: label,
            customFocus: customFocus,
            supports: Array(supports).sorted(),
            starterSet: current.starterSet
        )
        store.save()
        dismiss()
    }
}
