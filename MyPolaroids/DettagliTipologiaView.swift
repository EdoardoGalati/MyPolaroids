import SwiftUI

/// Pushed from the Film tab: every pack of one format + variant.
struct DettagliTipologiaView: View {
    let tipologia: TipologiaPaccoFilm
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var selectedTab: Int

    @Environment(\.dismiss) private var dismiss
    @State private var paccoDaModificare: FilmPack?
    @State private var paccoDaModificareRapido: FilmPack?
    @State private var paccoDaEliminare: FilmPack?
    @State private var mostraDeleteAlert = false
    @State private var aggiuntaTrigger = false
    @State private var eliminazioneTrigger = false

    private var gradiente: FilmPackGradient? {
        FilmPackColors.gradientePerTipo(tipologia.tipo, modello: tipologia.modello, modelliDisponibili: viewModel.modelliFilm)
    }

    /// Live packs of this group (most recent purchase first), so edits and
    /// additions show up without leaving the screen.
    private var pacchi: [FilmPack] {
        viewModel.pacchiFilm
            .filter { $0.tipo == tipologia.tipo && $0.modello == tipologia.modello }
            .sorted { $0.dataAcquisto > $1.dataAcquisto }
    }

    private var scattiDisponibili: Int {
        pacchi.reduce(0) { $0 + $1.scattiRimanenti }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero

                Card(title: "Packs") {
                    if pacchi.isEmpty {
                        Text("No packs left in this group.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(pacchi) { pacco in
                            VStack(spacing: 12) {
                                PaccoRow(
                                    pacco: pacco,
                                    nomeFotocamera: nomeFotocamera(per: pacco),
                                    onQuickEdit: { paccoDaModificareRapido = pacco },
                                    onEdit: { paccoDaModificare = pacco },
                                    onDelete: {
                                        paccoDaEliminare = pacco
                                        mostraDeleteAlert = true
                                    }
                                )
                                if pacco.id != pacchi.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }

                Button {
                    aggiungiPaccoIdentico()
                } label: {
                    Label("Add another pack", systemImage: "plus")
                }
                .buttonStyle(.secondaryBox)
            }
            .padding(.horizontal, DS.margin)
            .padding(.vertical, 16)
            .animation(.snappy, value: pacchi.count)
        }
        .groupedScreenBackground()
        .navigationTitle(tipologia.modello)
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .sheet(item: $paccoDaModificare) { pacco in
            ModificaPaccoFilmView(
                pacco: Binding(
                    get: { pacco },
                    set: { viewModel.aggiornaPaccoFilm($0) }
                ),
                viewModel: viewModel
            )
        }
        .sheet(item: $paccoDaModificareRapido) { pacco in
            ModificaRapidaPaccoView(
                pacco: Binding(
                    get: { pacco },
                    set: { viewModel.aggiornaPaccoFilm($0) }
                ),
                viewModel: viewModel,
                selectedTab: $selectedTab
            )
        }
        .alert("Delete Film Pack", isPresented: $mostraDeleteAlert, presenting: paccoDaEliminare) { pacco in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                elimina(pacco)
            }
        } message: { _ in
            Text("Are you sure you want to delete this film pack? This action cannot be undone.")
        }
        .onChange(of: pacchi.count) { _, nuovo in
            // The group no longer exists: go back to the Film list.
            if nuovo == 0 { dismiss() }
        }
        .sensoryFeedback(.success, trigger: aggiuntaTrigger)
        .sensoryFeedback(.impact, trigger: eliminazioneTrigger)
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 12) {
            ColorWheelView(gradient: gradiente, size: 120)

            Text(tipologia.modello)
                .font(.title2.weight(.bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)

            Chip(text: tipologia.tipo)

            Text("\(conta(pacchi.count, "pack")) · \(conta(scattiDisponibili, "shot"))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func nomeFotocamera(per pacco: FilmPack) -> String? {
        guard let id = pacco.fotocameraAssociata,
              let fotocamera = viewModel.fotocamere.first(where: { $0.id == id }) else { return nil }
        return fotocamera.displayName
    }

    private func conta(_ n: Int, _ parola: String) -> String {
        n == 1 ? "\(n) \(parola)" : "\(n) \(parola)s"
    }

    // MARK: - Actions

    private func aggiungiPaccoIdentico() {
        let nuovoPacco = FilmPack(
            tipo: tipologia.tipo,
            modello: tipologia.modello,
            scattiTotali: viewModel.capacitaDefaultPerTipo(tipologia.tipo),
            dataAcquisto: Date(),
            dataScadenza: nil,
            note: "Added from film pack details"
        )
        withAnimation(.snappy) {
            viewModel.aggiungiPaccoFilmInCima(nuovoPacco)
        }
        aggiuntaTrigger.toggle()
    }

    private func elimina(_ pacco: FilmPack) {
        let tipoPacco = pacco.tipo
        let modelloPacco = pacco.modello

        withAnimation(.snappy) {
            viewModel.rimuoviPaccoFilm(pacco)
        }
        eliminazioneTrigger.toggle()

        let pacchiRimanenti = viewModel.pacchiFilm.filter {
            $0.tipo == tipoPacco && $0.modello == modelloPacco
        }
        if pacchiRimanenti.isEmpty {
            selectedTab = 1
        }
    }
}

// MARK: - Pack row

private struct PaccoRow: View {
    let pacco: FilmPack
    let nomeFotocamera: String?
    let onQuickEdit: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                ShotFrames(remaining: pacco.scattiRimanenti, total: pacco.scattiTotali, frameSize: 10)

                Text("\(pacco.scattiRimanenti)/\(pacco.scattiTotali) shots")
                    .font(.subheadline.weight(.medium))
                    .monospacedDigit()
                    .contentTransition(.numericText())

                if let nomeFotocamera {
                    Label(nomeFotocamera, systemImage: "camera")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    if let scadenza = pacco.dataScadenza {
                        Text("Expires \(scadenza.shortDisplay)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Bought \(pacco.dataAcquisto.shortDisplay)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if pacco.isFinito {
                        Chip(text: "Finished")
                    } else if pacco.isScaduto {
                        Chip(text: "Expired", prominent: true)
                    } else if pacco.isInScadenza {
                        Chip(text: "Expiring")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: onQuickEdit)

            Menu {
                Button("Quick edit", systemImage: "slider.horizontal.3", action: onQuickEdit)
                Button("Edit", systemImage: "pencil", action: onEdit)
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Pack actions")
        }
        .contextMenu {
            Button("Quick edit", systemImage: "slider.horizontal.3", action: onQuickEdit)
            Button("Edit", systemImage: "pencil", action: onEdit)
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
    }
}
