import SwiftUI
import AVFoundation
import Speech

struct InlineDumpComposer: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    @Binding var expanded: Bool

    @State private var text = ""
    @State private var recording = false
    @State private var status = ""
    @State private var permissionDenied = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var engine = AVAudioEngine()
    @State private var request: SFSpeechAudioBufferRecognitionRequest?
    @State private var task: SFSpeechRecognitionTask?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Button { expanded.toggle() } label: {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            LinearGradient(colors: [
                                Color(red: 0.878, green: 0.478, blue: 0.408),
                                Color(red: 0.624, green: 0.247, blue: 0.235)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(expanded ? "Close brain dump" : "Open brain dump")

                VStack(alignment: .leading, spacing: 2) {
                    Text("Brain dump").font(.headline).foregroundStyle(Lab.ink)
                    Text("Just talk. We'll write it down here.")
                        .font(.caption).foregroundStyle(Lab.soft)
                }
                Spacer()
                if expanded {
                    Button("Close") { stop(); expanded = false }
                        .font(.caption).foregroundStyle(Lab.accent)
                }
            }

            if expanded {
                Divider().background(Lab.line)
                TextField("Or type it yourself…", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .foregroundStyle(Lab.ink)
                    .padding(12)
                    .background(Lab.bg, in: RoundedRectangle(cornerRadius: 14))
                    .keyboardDoneButton()

                HStack(spacing: 10) {
                    Button(recording ? "Stop" : "Speak") { recording ? stop() : start() }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(recording ? .white : Lab.accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(recording ? Color(red: 0.624, green: 0.247, blue: 0.235) : Color.clear, in: Capsule())
                        .overlay(Capsule().stroke(Lab.line, lineWidth: 1))
                        .disabled(permissionDenied)

                    Spacer()

                    Button("Add to list") {
                        store.addLabItem(text)
                        text = ""
                        expanded = false
                        Haptics.gentle()
                        whisper.show("noted.")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Lab.accent.opacity(0.85), in: Capsule())
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if !status.isEmpty {
                    Text(status).font(.caption2).foregroundStyle(Lab.soft)
                }
            }
        }
        .onAppear { requestPermission() }
        .onDisappear { stop() }
    }

    private func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { auth in
            DispatchQueue.main.async {
                if auth != .authorized {
                    permissionDenied = true
                    status = "Voice isn't available. You can type instead."
                }
            }
        }
    }

    private func start() {
        guard let recognizer, recognizer.isAvailable else {
            status = "Voice isn't available right now. Type instead."
            return
        }
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request?.append(buffer)
        }
        engine.prepare()
        do { try engine.start() } catch {
            status = "Couldn't start the microphone. Type instead."
            return
        }
        task = recognizer.recognitionTask(with: request!) { result, _ in
            if let result {
                DispatchQueue.main.async { text = result.bestTranscription.formattedString }
            }
        }
        recording = true
        status = "Listening. Nothing is saved until you tap Add."
        Haptics.gentle()
    }

    private func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        recording = false
        if !text.isEmpty { status = "Review the words above, then add them." }
    }
}
