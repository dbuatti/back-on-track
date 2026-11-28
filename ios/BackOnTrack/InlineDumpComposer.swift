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
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "mic.fill")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Lab.micGradient, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Brain dump").font(.headline).foregroundStyle(Lab.ink)
                    Text("Just talk. We'll write it down here.")
                        .font(.caption).foregroundStyle(Lab.soft)
                }
                Spacer()
                if expanded {
                    Button("Close") { stop(); expanded = false }
                        .font(.caption.weight(.semibold)).foregroundStyle(Lab.accent)
                }
            }

            if !expanded {
                Button { expanded = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "mic.circle.fill")
                            .font(.title2)
                        Text("Start a brain dump")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Lab.micGradient, in: Capsule())
                }
                .buttonStyle(.plain)
            } else {
                Divider().background(Lab.line)

                // The big, obvious microphone.
                VStack(spacing: 10) {
                    Button { recording ? stop() : start() } label: {
                        ZStack {
                            Circle().fill(Lab.micGradient)
                                .frame(width: 104, height: 104)
                            if recording {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                            } else {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 38, weight: .light))
                                    .foregroundStyle(.white)
                            }
                        }
                        .overlay(Circle().stroke(recording ? Lab.accent : Color.white.opacity(0.25), lineWidth: recording ? 4 : 1))
                        .shadow(color: Lab.micShadow, radius: 18, x: 0, y: 9)
                    }
                    .buttonStyle(.plain)
                    .disabled(permissionDenied)
                    .accessibilityLabel(recording ? "Stop recording" : "Start recording")
                    .accessibilityHint(permissionDenied ? "Voice is off. You can type instead." : "Tap to speak your thought")

                    Text(recording ? "Listening… tap to stop" : "Tap to speak")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(recording ? Lab.accent : Lab.soft)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)

                TextField("Or type it yourself…", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .foregroundStyle(Lab.ink)
                    .padding(12)
                    .background(Lab.bg, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Lab.line, lineWidth: 1))
                    .keyboardDoneButton()

                HStack(spacing: 10) {
                    Button("Add to list") {
                        store.addLabItem(text)
                        text = ""
                        expanded = false
                        Haptics.gentle()
                        whisper.show("noted.")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Lab.bg)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Lab.accent, in: Capsule())
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
