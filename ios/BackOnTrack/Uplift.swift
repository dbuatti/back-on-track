import SwiftUI
import UIKit

@MainActor
final class WhisperManager: ObservableObject {
    @Published var text: String?
    @Published var isShowing = false

    private let words = ["there.", "good.", "done.", "nice.", "that counts.", "mm.", "yep.", "lovely."]
    private var token = 0

    func show(_ custom: String? = nil) {
        token += 1
        let current = token
        let value = custom ?? words.randomElement() ?? "good."
        withAnimation(.easeOut(duration: 0.18)) {
            text = value
            isShowing = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard current == token else { return }
            withAnimation(.easeIn(duration: 0.35)) {
                isShowing = false
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard current == token else { return }
            text = nil
        }
    }
}

private struct KeyboardDismissModifier: ViewModifier {
    @FocusState private var focused: Bool

    func body(content: Content) -> some View {
        content
            .focused($focused)
            .submitLabel(.done)
            .onSubmit { focused = false }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BotTheme.accent)
                }
            }
    }
}

extension View {
    func keyboardDoneButton() -> some View {
        modifier(KeyboardDismissModifier())
    }
}

enum Haptics {
    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func gentle() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
}
