import SwiftUI

struct FocusView: View {
    @State private var index: Int = 0
    private let sections = ["Morning", "Anchors", "Instead of gaming"]

    var body: some View {
        NavigationStack {
            VStack {
                Text(sections[index]).font(.title).bold()
                Spacer()
                HStack {
                    Button("‹") { if index > 0 { index -= 1 } }
                    Spacer()
                    Button("Done") { }
                    Spacer()
                    Button("›") { if index < sections.count - 1 { index += 1 } }
                }
                .padding()
            }
            .navigationTitle("Focus")
        }
    }
}