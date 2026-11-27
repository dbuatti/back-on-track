import SwiftUI

struct ShelvesView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        Image(systemName: "tray.full")
                            .font(.title2)
                            .foregroundStyle(BotTheme.sage)
                            .frame(width: 46, height: 46)
                            .background(BotTheme.sageSoft, in: Circle())
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Shelves").font(BotTheme.titleFont).foregroundStyle(BotTheme.ink)
                            Text("A quiet library, not a to-do list.").font(.subheadline).foregroundStyle(BotTheme.soft)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)

                    if store.state.settings.shelves.isEmpty {
                        Text("No shelves yet.")
                            .foregroundStyle(BotTheme.soft)
                            .botCard()
                    } else {
                        ForEach(store.state.settings.shelves) { shelf in
                            shelfCard(shelf)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .botBackground()
            .navigationTitle("Shelves")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func shelfCard(_ shelf: Shelf) -> some View {
        let tone = toneColor(shelf.tone)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "tray.full")
                    .foregroundStyle(tone)
                Text(shelf.name).font(.headline).foregroundStyle(BotTheme.ink)
                Spacer()
                Text("\(shelf.items.count)")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tone.opacity(0.14), in: Capsule())
                    .foregroundStyle(tone)
            }
            if shelf.items.isEmpty {
                Text("Nothing here yet.").font(.caption).foregroundStyle(BotTheme.soft)
            } else {
                ForEach(shelf.items) { item in
                    let loan = store.state.settings.loans.first(where: { $0.itemId == item.id })
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.text)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(loan == nil ? BotTheme.ink : BotTheme.soft)
                            if let note = item.note, !note.isEmpty {
                                Text(note).font(.caption).foregroundStyle(BotTheme.soft)
                            }
                            if let small = item.small, !small.isEmpty {
                                Text("Even smaller: \(small)")
                                    .font(.caption2).foregroundStyle(BotTheme.soft)
                            }
                        }
                        Spacer()
                        if let loan {
                            Text(loan.list == "morning" ? "On Home" : "In Anchors")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(BotTheme.soft.opacity(0.12), in: Capsule())
                                .foregroundStyle(BotTheme.soft)
                        } else {
                            Menu {
                                Button("Borrow into Morning") { store.borrow(shelfId: shelf.id, itemId: item.id, into: "morning") }
                                Button("Borrow into Daily anchors") { store.borrow(shelfId: shelf.id, itemId: item.id, into: "anchors") }
                            } label: {
                                Text("Borrow")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 7)
                                    .background(tone.opacity(0.14), in: Capsule())
                                    .foregroundStyle(tone)
                            }
                        }
                    }
                    .padding(.vertical, 7)
                    .opacity(loan == nil ? 1 : 0.72)
                    if item.id != shelf.items.last?.id {
                        Divider()
                    }
                }
            }
        }
        .botCard()
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(tone.opacity(0.22), lineWidth: 1)
        )
    }

    private func toneColor(_ tone: String) -> Color {
        switch tone {
        case "slate": return Color(red: 0.333, green: 0.467, blue: 0.604)
        case "green": return Color(red: 0.435, green: 0.561, blue: 0.463)
        case "amber": return Color(red: 0.725, green: 0.486, blue: 0.239)
        default: return Color(red: 0.643, green: 0.388, blue: 0.388)
        }
    }
}