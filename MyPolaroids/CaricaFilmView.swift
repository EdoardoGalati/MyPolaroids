import SwiftUI

struct CaricaFilmView: View {
    let fotocamera: Camera
    @ObservedObject var viewModel: FilmPackViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var filmSelezionato: FilmPack?
    @State private var mostraAggiungiFilm = false
    @State private var loadFeedback = false

    /// Packs that can be loaded: compatible with the camera (or compatibility
    /// ignored in Settings), not in use, not empty, not expired.
    var filmCompatibili: [FilmPack] {
        viewModel.pacchiFilm.filter { pacco in
            let compatibile = viewModel.isCompatibile(pacco.tipo, con: fotocamera)
            let nonInUso = !pacco.isInUso
            let haScatti = pacco.scattiRimanenti > 0
            let nonScaduto = !pacco.isScaduto
            let nonInQuestaFotocamera = pacco.fotocameraAssociata != fotocamera.id
            return compatibile && nonInUso && haScatti && nonScaduto && nonInQuestaFotocamera
        }
    }

    private struct GruppoFormato: Identifiable {
        let formato: String
        let pacchi: [FilmPack]
        var id: String { formato }
    }

    /// Compatible packs grouped by format, formats sorted alphabetically.
    private var gruppiPerFormato: [GruppoFormato] {
        let gruppi = Dictionary(grouping: filmCompatibili, by: { $0.tipo })
        return gruppi.keys.sorted().map { formato in
            let pacchi = (gruppi[formato] ?? []).sorted { first, second in
                if first.modello == second.modello {
                    return first.dataAcquisto < second.dataAcquisto
                }
                return first.modello < second.modello
            }
            return GruppoFormato(formato: formato, pacchi: pacchi)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filmCompatibili.isEmpty {
                    EmptyState(
                        title: "No compatible film",
                        message: "All compatible film packs are in use, finished or expired.",
                        image: "polaroid.film.symbols",
                        isAsset: true,
                        actionTitle: "Add Film Pack",
                        action: { mostraAggiungiFilm = true }
                    )
                } else {
                    List {
                        ForEach(gruppiPerFormato) { gruppo in
                            Section(gruppo.formato) {
                                ForEach(gruppo.pacchi) { pacco in
                                    Button {
                                        filmSelezionato = pacco
                                    } label: {
                                        FilmPackRowView(
                                            pacco: pacco,
                                            modelliDisponibili: viewModel.modelliFilm
                                        )
                                    }
                                    .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Load Film")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostraAggiungiFilm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Film Pack")
                }
            }
            .alert(
                "Load Film",
                isPresented: Binding(
                    get: { filmSelezionato != nil },
                    set: { if !$0 { filmSelezionato = nil } }
                ),
                presenting: filmSelezionato
            ) { pacco in
                Button("Cancel", role: .cancel) { }
                Button("Load") {
                    viewModel.caricaFilm(pacco, in: fotocamera)
                    loadFeedback.toggle()
                    dismiss()
                }
            } message: { pacco in
                Text("Load \(pacco.tipo) \(pacco.modello) into '\(fotocamera.displayName)'?")
            }
            .sheet(isPresented: $mostraAggiungiFilm) {
                AggiungiPaccoFilmView(viewModel: viewModel, fotocamera: fotocamera)
            }
        }
        .tint(.primary)
        .presentationDetents([.medium, .large])
        .sensoryFeedback(.success, trigger: loadFeedback)
    }
}

struct FilmPackRowView: View {
    let pacco: FilmPack
    let modelliDisponibili: [FilmPackModel]

    private var detail: String {
        var parts = ["\(pacco.scattiRimanenti) shot\(pacco.scattiRimanenti == 1 ? "" : "s")"]
        if let scadenza = pacco.dataScadenza {
            parts.append("expires \(scadenza.shortDisplay)")
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 12) {
            ColorWheelView(
                gradient: FilmPackColors.gradientePerTipo(
                    pacco.tipo,
                    modello: pacco.modello,
                    modelliDisponibili: modelliDisponibili
                ),
                size: 36
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(pacco.modello)
                    .font(.headline)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    let fotocamera = Camera(
        nickname: "My Camera",
        modello: "Polaroid 600",
        coloreIcona: "000"
    )
    return CaricaFilmView(
        fotocamera: fotocamera,
        viewModel: FilmPackViewModel()
    )
}
