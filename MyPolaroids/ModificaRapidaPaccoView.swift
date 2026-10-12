import SwiftUI

/// Half-height sheet to adjust the remaining shots and the expiry date of one pack.
struct ModificaRapidaPaccoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var pacco: FilmPack
    @Binding var selectedTab: Int

    @State private var scattiRimanenti: Int
    @State private var dataScadenza: Date?
    @State private var mostraScadenza: Bool
    @State private var mostraDeleteAlert = false
    @State private var salvato = false

    init(pacco: Binding<FilmPack>, viewModel: FilmPackViewModel, selectedTab: Binding<Int>) {
        self._pacco = pacco
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        self._scattiRimanenti = State(initialValue: max(pacco.wrappedValue.scattiRimanenti, 0))
        self._dataScadenza = State(initialValue: pacco.wrappedValue.dataScadenza)
        self._mostraScadenza = State(initialValue: pacco.wrappedValue.dataScadenza != nil)
    }

    private var gradiente: FilmPackGradient? {
        FilmPackColors.gradientePerTipo(pacco.tipo, modello: pacco.modello, modelliDisponibili: viewModel.modelliFilm)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        ColorWheelView(gradient: gradiente, size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pacco.modello)
                                .font(.headline)
                            Text(pacco.tipo)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    VStack(spacing: 16) {
                        ShotFrames(remaining: scattiRimanenti, total: pacco.scattiTotali, frameSize: 14)

                        HStack(spacing: 24) {
                            Button {
                                withAnimation(.snappy) { scattiRimanenti -= 1 }
                            } label: {
                                Image(systemName: "minus")
                                    .glassCircleButton()
                            }
                            .buttonStyle(.plain)
                            .disabled(scattiRimanenti <= 0)
                            .accessibilityLabel("One shot less")

                            VStack(spacing: 2) {
                                Text("\(scattiRimanenti)")
                                    .font(.largeTitle.weight(.bold))
                                    .fontDesign(.rounded)
                                    .monospacedDigit()
                                    .contentTransition(.numericText())
                                Text("of \(pacco.scattiTotali) shots left")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(minWidth: 110)

                            Button {
                                withAnimation(.snappy) { scattiRimanenti += 1 }
                            } label: {
                                Image(systemName: "plus")
                                    .glassCircleButton()
                            }
                            .buttonStyle(.plain)
                            .disabled(scattiRimanenti >= pacco.scattiTotali)
                            .accessibilityLabel("One shot more")
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Card {
                        Toggle("Has expiry date", isOn: $mostraScadenza)

                        if mostraScadenza {
                            DatePicker(
                                "Expiry date",
                                selection: Binding(
                                    get: { dataScadenza ?? FilmPack.calcolaScadenzaDefault(dataAcquisto: pacco.dataAcquisto) },
                                    set: { dataScadenza = $0 }
                                ),
                                displayedComponents: .date
                            )
                        }
                    }

                    Button(role: .destructive) {
                        mostraDeleteAlert = true
                    } label: {
                        Label("Delete Pack", systemImage: "trash")
                    }
                    .buttonStyle(.secondaryBox)
                }
                .padding(.horizontal, DS.margin)
                .padding(.vertical, 16)
            }
            .groupedScreenBackground()
            .navigationTitle("Edit Pack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        salvaModifiche()
                    }
                }
            }
            .alert("Delete Pack", isPresented: $mostraDeleteAlert) {
                Button("Delete", role: .destructive) {
                    eliminaPacco()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this pack? This action cannot be undone.")
            }
            .onChange(of: mostraScadenza) { _, attiva in
                if attiva && dataScadenza == nil {
                    dataScadenza = FilmPack.calcolaScadenzaDefault(dataAcquisto: pacco.dataAcquisto)
                }
            }
        }
        .tint(.primary)
        .presentationDetents([.medium])
        .sensoryFeedback(.impact, trigger: scattiRimanenti)
        .sensoryFeedback(.success, trigger: salvato)
    }

    private func salvaModifiche() {
        var paccoAggiornato = pacco
        paccoAggiornato.scattiRimanenti = min(max(scattiRimanenti, 0), pacco.scattiTotali)
        paccoAggiornato.dataScadenza = mostraScadenza ? dataScadenza : nil

        viewModel.aggiornaPaccoFilm(paccoAggiornato)
        salvato.toggle()
        dismiss()
    }

    private func eliminaPacco() {
        let tipoPacco = pacco.tipo
        let modelloPacco = pacco.modello

        viewModel.rimuoviPaccoFilm(pacco)

        let pacchiRimanenti = viewModel.pacchiFilm.filter {
            $0.tipo == tipoPacco && $0.modello == modelloPacco
        }
        if pacchiRimanenti.isEmpty {
            selectedTab = 1
        }

        dismiss()
    }
}
