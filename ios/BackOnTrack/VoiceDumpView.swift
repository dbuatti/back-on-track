import SwiftUI
import AVFoundation
import Speech

private enum Dump {
    static let bg = Color(red: 0.141, green: 0.102, blue: 0.227)
    static let ink = Color(red: 0.969, green: 0.949, blue: 1.0)
    static let soft = Color(red: 0.796, green: 0.722, blue: 0.910)
    static let accent = Color(red: 0.749, green: 0.655, blue: 0.961)
    static let line = Color(red: 0.290, green: 0.227, blue: 0.463)
}

struct VoiceDumpView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    @Environment(\.dismiss) private var dismiss

    @State private var transcript = ""
    @State private var isRecording = false
    @State private var status = "Tap the microphone, then just talk."
    @State private var permissionDenied = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var audioEngine = AVAudioEngine()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text("BRAIN DUMP")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.4)
                        .foregroundStyle(Dump.accent)
                    Text("Say it out. We'll write it down.")
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(Dump.ink)
                    Text("For the mug in the drawer, the thing you meant to do, the small thing you forgot you could do. Nothing is saved until you review it.")
                        .font(.subheadline)
                        .foregroundStyle(Dump.soft)
                        .multilineTextAlignment(.center)

                    Button { isRecording ? stop() : start() } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [
                                    Color(red: 0.878, green: 0.478, blue: 0.408),
                                    Color(red: 0.784, green: 0.353, blue: 0.314),
                                    Color(red: 0.624, green: 0.247, blue: 0.235)
                                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 124, height: 124)
                    .shadow(color: Color(red: 0.624, green: 0.247, blue: 0.235).opacity(0.4), radius: 22, x: 0, y: 10)
                    .disabled(permissionDenied)

                    Text(status)
                        .font(.caption)
                        .foregroundStyle(Dump.soft)
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 32)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR WORDS — EDIT FREELY")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(Dump.accent)
                        TextEditor(text: $transcript)
                            .frame(minHeight: 120)
                            .padding(10)
                            .background(Dump.bg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Dump.line, lineWidth: 1))
                            .foregroundStyle(Dump.ink)
                            .keyboardDoneButton()
                        Button("Add to reminders") {
                            store.addCozyPossibility(transcript)
                            transcript = ""
                            Haptics.gentle()
                            whisper.show("noted.")
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Dump.accent)
                        .disabled(transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(Dump.bg.ignoresSafeArea())
            .navigationTitle("Brain dump")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { stop(); dismiss() } }
            }
        }
        .onAppear { requestPermission() }
        .onDisappear { stop() }
    }

    private func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized: status = "Tap the microphone, then just talk."
                default:
                    permissionDenied = true
                    status = "Speech access is off. You can still type your thought below."
                }
            }
        }
    }

    private func start() {
        guard let recognizer, recognizer.isAvailable else {
            status = "Speech recognition isn't available right now. Type instead."
            return
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do { try audioEngine.start() } catch {
            status = "Couldn't start the microphone. Type instead."
            return
        }
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { result, error in
            if let result {
                DispatchQueue.main.async { transcript = result.bestTranscription.formattedString }
            }
            if error != nil {
                DispatchQueue.main.async { stop() }
            }
        }
        isRecording = true
        status = "Listening. Nothing is saved until you tap Add."
        Haptics.gentle()
    }

    private func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        if !transcript.isEmpty { status = "Review the words above, then add them when you're happy." }
    }
}
