import SwiftUI

enum Lab {
    static let bg = Color(red: 0.094, green: 0.067, blue: 0.165)
    static let card = Color(red: 0.153, green: 0.114, blue: 0.259)
    static let card2 = Color(red: 0.212, green: 0.165, blue: 0.353)
    static let ink = Color.white
    static let soft = Color(red: 0.894, green: 0.854, blue: 0.976)
    static let accent = Color(red: 0.855, green: 0.776, blue: 1.0)
    static let line = Color(red: 0.353, green: 0.294, blue: 0.529)
    static let micGradient = LinearGradient(
        colors: [Color(red: 0.925, green: 0.494, blue: 0.435), Color(red: 0.706, green: 0.259, blue: 0.251)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let micShadow = Color(red: 0.706, green: 0.259, blue: 0.251).opacity(0.45)
}

struct LaboratoryView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    @Environment(\.dismiss) private var dismiss

    @State private var dumpExpanded = false
    @State private var filter: Filter = .all
    @State private var newItem = ""
    @State private var editing = false

    private enum Filter: String, CaseIterable { case all = "All", small = "Small", big = "Bigger", archived = "Archived" }

    private var items: [LabItem] {
        let all = store.state.settings.labItems ?? []
        switch filter {
        case .all: return all.filter { !$0.archived }
        case .small: return all.filter { !$0.archived && $0.effort == "small" }
        case .big: return all.filter { !$0.archived && $0.effort == "big" }
        case .archived: return all.filter { $0.archived }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Lab.bg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        InlineDumpComposer(expanded: $dumpExpanded)
                        energyCard
                        filterRow
                        listCard
                    }
                    .padding(18)
                    .padding(.bottom, 40)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Laboratory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundStyle(Lab.accent)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LABORATORY")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Lab.accent)
            Text("A place for everything on your mind.")
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Lab.ink)
            Text("Say it all, then sort it when you feel ready. Nothing here has to be finished.")
                .font(.subheadline)
                .foregroundStyle(Lab.soft)
        }
    }

    private var energyCard: some View {
        let count = items.filter { !$0.archived }.count
        return VStack(alignment: .leading, spacing: 8) {
            Text("ENERGY")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Lab.accent)
            Text(count <= 3 ? "A light day — only a few things held here."
                : count <= 8 ? "A steady day — there is room to sort a little."
                : "A full list today. You don't have to work through it.")
                .font(.subheadline)
                .foregroundStyle(Lab.ink)
            Text("This is not a count of what you should do. Just a read on how full the shelf feels.")
                .font(.caption)
                .foregroundStyle(Lab.soft)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Lab.card2, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Filter.allCases, id: \.self) { f in
                    Button {
                        filter = f
                        Haptics.tap()
                    } label: {
                        Text(f.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(filter == f ? Lab.bg : Lab.soft)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(filter == f ? Lab.accent : Lab.card, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var listCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Your things")
                    .font(.headline)
                    .foregroundStyle(Lab.ink)
                Spacer()
                Button(editing ? "Done" : "Manage") { editing.toggle() }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Lab.accent)
            }

            if items.isEmpty {
                Text(filter == .archived ? "Nothing archived yet." : "Nothing here yet. Brain dump a thought whenever you like.")
                    .font(.subheadline)
                    .foregroundStyle(Lab.soft)
                    .frame(maxWidth: .infinity, minHeight: 90)
            } else {
                ForEach(items) { item in
                    labRow(item)
                }
            }

            if filter != .archived {
                HStack(spacing: 8) {
                    TextField("Add a small thing…", text: $newItem)
                        .textFieldStyle(.plain)
                        .foregroundStyle(Lab.ink)
                        .padding(12)
                        .background(Lab.bg, in: RoundedRectangle(cornerRadius: 14))
                        .keyboardDoneButton()
                    Button("Add") {
                        store.addLabItem(newItem)
                        newItem = ""
                        Haptics.tap()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Lab.accent)
                    .disabled(newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.top, 6)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Lab.card, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Lab.line, lineWidth: 1))
    }

    private func labRow(_ item: LabItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(item.text)
                    .font(.subheadline)
                    .foregroundStyle(item.archived ? Lab.soft : Lab.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if editing {
                    Menu {
                        Button(item.effort == "big" ? "Mark small" : "Mark bigger") {
                            store.setLabEffort(item.id, effort: item.effort == "big" ? "small" : "big")
                        }
                        Button(item.archived ? "Bring back" : "Archive") {
                            store.setLabArchived(item.id, archived: !item.archived)
                        }
                        Button("Delete", role: .destructive) { store.deleteLabItem(item.id) }
                    } label: {
                        Image(systemName: "ellipsis.circle").foregroundStyle(Lab.accent)
                    }
                }
            }
            if !item.archived {
                HStack(spacing: 8) {
                    Text(item.effort == "big" ? "Bigger" : "Small")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(item.effort == "big" ? Lab.card2 : Lab.bg, in: Capsule())
                        .foregroundStyle(Lab.soft)
                    if editing {
                        Button("Archive") { store.setLabArchived(item.id, archived: true) }
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Lab.accent)
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Lab.line).frame(height: 1)
        }
    }
}
