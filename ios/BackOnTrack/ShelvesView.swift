import SwiftUI

struct ShelvesView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.state.settings.shelves) { shelf in
                    Section(shelf.name) {
                        ForEach(shelf.items) { item in
                            VStack(alignment: .leading) {
                                Text(item.text)
                                if let note = item.note { Text(note).font(.caption).foregroundStyle(.secondary) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shelves")
        }
    }
}