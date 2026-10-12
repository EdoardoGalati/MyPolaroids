import SwiftUI
import Combine

/// Root of the Film tab: the film groups ("tipologie", one per format + variant),
/// sectioned by format.
struct TipologiePacchiFilmView: View {
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var selectedTab: Int
    @State private var mostraAggiungi = false
    @State private var mostraImpostazioni = false

    private struct SezioneFormato: Identifiable {
        let tipo: String
        let tipologie: [TipologiaPaccoFilm]
        var id: String { tipo }
    }

    /// Groups `tipologieRaggruppate` (already sorted by the user's sorting setting)
    /// by format, keeping the order of first appearance.
    private var sezioni: [SezioneFormato] {
        var ordine: [String] = []
        var gruppi: [String: [TipologiaPaccoFilm]] = [:]
        for tipologia in viewModel.tipologieRaggruppate {
            if gruppi[tipologia.tipo] == nil {
                ordine.append(tipologia.tipo)
                gruppi[tipologia.tipo] = []
            }
            gruppi[tipologia.tipo]?.append(tipologia)
        }
        return ordine.map { SezioneFormato(tipo: $0, tipologie: gruppi[$0] ?? []) }
    }

    var body: some View {
            Group {
                if viewModel.tipologieRaggruppate.isEmpty {
                    EmptyState(
                        title: "No film",
                        message: "Add a film pack to keep track of your shots.",
                        image: "polaroid.film.symbols",
                        isAsset: true,
                        actionTitle: "Add Film",
                        action: { mostraAggiungi = true }
                    )
                } else {
                    listaTipologie
                }
            }
            .navigationTitle("Film")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        mostraImpostazioni = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostraAggiungi = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Film")
                }
            }
            .sheet(isPresented: $mostraAggiungi) {
                AggiungiPaccoFilmView(viewModel: viewModel, fotocamera: nil)
            }
            .sheet(isPresented: $mostraImpostazioni) {
                ImpostazioniView()
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                // Refresh when the sorting setting changes.
                DispatchQueue.main.async {
                    viewModel.objectWillChange.send()
                }
            }
        .tint(.primary)
    }

    private var listaTipologie: some View {
        List {
            ForEach(sezioni) { sezione in
                Section(sezione.tipo) {
                    ForEach(sezione.tipologie) { tipologia in
                        NavigationLink {
                            DettagliTipologiaView(tipologia: tipologia, viewModel: viewModel, selectedTab: $selectedTab)
                        } label: {
                            TipologiaRow(tipologia: tipologia, modelliDisponibili: viewModel.modelliFilm)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.snappy, value: viewModel.pacchiFilm.count)
    }
}

private struct TipologiaRow: View {
    let tipologia: TipologiaPaccoFilm
    let modelliDisponibili: [FilmPackModel]

    private var gradiente: FilmPackGradient? {
        FilmPackColors.gradientePerTipo(tipologia.tipo, modello: tipologia.modello, modelliDisponibili: modelliDisponibili)
    }

    var body: some View {
        HStack(spacing: 12) {
            ColorWheelView(gradient: gradiente, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(tipologia.modello)
                    .font(.headline)
                Text("\(conta(tipologia.conteggioTotale, "pack")) · \(conta(tipologia.scattiDisponibili, "shot")) available")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            Spacer(minLength: 8)

            if tipologia.pacchiScaduti > 0 {
                Chip(text: "Expired", prominent: true)
            } else if tipologia.pacchiInScadenza > 0 {
                Chip(text: "Expiring")
            }
        }
        .padding(.vertical, 4)
    }

    private func conta(_ n: Int, _ parola: String) -> String {
        n == 1 ? "\(n) \(parola)" : "\(n) \(parola)s"
    }
}
