import SwiftUI

struct ShelvesView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var whisper: WhisperManager
    @State private var showingDump = false
    @State private var showingLab = false
    @State private var activeShelfId: String = ""

    private var shelves: [Shelf] { store.state.settings.shelves }

    private var selectedShelf: Shelf? {
        if let id = shelves.first(where: { $0.id == activeShelfId }) { return id }
        return shelves.first
    }

    private var closeAtHand: [(String, String)] {
        var rows: [(String, String)] = []
        for loan in store.state.settings.loans {
            let item = shelves.flatMap({ $0.items }).first(where: { $0.id == loan.itemId })
            if let item {
                rows.append((item.text, loan.list == "morning" ? "On Home" : "In Anchors"))
            }
        }
        if let selfReg = shelves.first(where: { $0.id == "sh_selfreg" })?.items.first {
            rows.append((selfReg.text, "Ways to settle"))
        }
        if let small = shelves.first(where: { $0.id == "sh_smallstarts" })?.items.first {
            rows.append((small.text, "Small start"))
        }
        return Array(rows.prefix(5))
    }

    var body: some View {
        ZStack {
            BotTheme.backgroundGradient.ignoresSafeArea()
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

                    Button { showingLab = true } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "flask")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    LinearGradient(colors: [
                                        Color(red: 0.561, green: 0.435, blue: 0.816),
                                        Color(red: 0.310, green: 0.239, blue: 0.529)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Laboratory").font(BotTheme.headingFont).foregroundStyle(BotTheme.ink)
                                Text("One place for everything on your mind.").font(.caption).foregroundStyle(BotTheme.soft)
                            }
                            Spacer()
                            Image(systemName: "arrow.right").foregroundStyle(BotTheme.soft)
                        }
                        .padding(16)
                        .background(BotTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(BotTheme.line.opacity(0.4), lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 8) {
                        BotSectionHeader(title: "Brain dump", systemImage: "mic", tint: Color(red: 0.784, green: 0.353, blue: 0.314))
                        Text("Say the small things out loud. They become reminders, never tasks.")
                            .font(.subheadline).foregroundStyle(BotTheme.soft)
                        Button("Open brain dump") { showingDump = true }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.784, green: 0.353, blue: 0.314), in: Capsule())
                            .buttonStyle(.plain)
                    }
                    .botCard()

                    if !closeAtHand.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            BotSectionHeader(title: "Close at hand", systemImage: "hand.raised", tint: BotTheme.accent)
                            ForEach(closeAtHand, id: \.0) { item in
                                HStack(spacing: 8) {
                                    Text(item.0)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(BotTheme.ink)
                                    Spacer()
                                    Text(item.1)
                                        .font(.caption2)
                                        .foregroundStyle(BotTheme.soft)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .botCard()
                    }

                    if shelves.isEmpty {
                        Text("No shelves yet.")
                            .foregroundStyle(BotTheme.soft)
                            .botCard()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(shelves) { shelf in
                                    Button {
                                        activeShelfId = shelf.id
                                        Haptics.tap()
                                    } label: {
                                        Text(shelf.name)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(activeShelfId == shelf.id || (activeShelfId.isEmpty && shelf.id == shelves.first?.id) ? .white : BotTheme.soft)
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 9)
                                            .background(
                                                (activeShelfId == shelf.id || (activeShelfId.isEmpty && shelf.id == shelves.first?.id))
                                                    ? BotTheme.accent : BotTheme.card,
                                                in: Capsule()
                                            )
                                            .overlay(Capsule().stroke(BotTheme.line.opacity(0.4), lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 2)
                        }

                        if let shelf = selectedShelf {
                            shelfCard(shelf)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $showingLab) {
                LaboratoryView()
                    .environmentObject(store)
                    .environmentObject(whisper)
            }
            .fullScreenCover(isPresented: $showingDump) {
                VoiceDumpView()
                    .environmentObject(store)
                    .environmentObject(whisper)
            }
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
            Text(shelf.note)
                .font(.caption)
                .foregroundStyle(BotTheme.soft)
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
                }
            }
        }
        .botCard()
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
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
