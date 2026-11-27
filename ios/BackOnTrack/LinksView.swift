import SwiftUI

struct LinksView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        NavigationStack {
            List {
                Section("The Door") {
                    Link("Open The Door", destination: URL(string: "https://danieles-mac-mini.tailab1fd5.ts.net:8451/")!)
                }
                Section("My links") {
                    ForEach(store.state.settings.myLinks) { link in
                        Link(link.text, destination: URL(string: link.url ?? "") ?? URL(string: "https://example.com")!)
                    }
                }
            }
            .navigationTitle("Links")
        }
    }
}