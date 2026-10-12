import SwiftUI

/// Sheet that adds a film pack in two steps: pick the format, then customise the pack.
struct AggiungiPaccoFilmView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FilmPackViewModel
    let fotocamera: Camera?

    @State private var searchText = ""

    /// Formats, restricted to the ones compatible with `fotocamera` when one is given.
    private var tipiFiltrati: [FilmPackType] {
        var tipi = viewModel.tipiFilm
        if let fotocamera {
            tipi = tipi.filter { viewModel.isCompatibile($0.name, con: fotocamera) }
        }
        if !searchText.isEmpty {
            tipi = tipi.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return tipi
    }

    var body: some View {
        NavigationStack {
            Group {
                if tipiFiltrati.isEmpty {
                    EmptyState(
                        title: "No formats",
                        message: searchText.isEmpty
                            ? "No film formats are available right now."
                            : "No formats match “\(searchText)”.",
                        image: "polaroid.film.symbols",
                        isAsset: true
                    )
                } else {
                    List {
                        ForEach(tipiFiltrati) { tipo in
                            NavigationLink(value: tipo.name) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tipo.name)
                                        .font(.headline)
                                    Text(tipo.default_capacity == 1 ? "1 shot" : "\(tipo.default_capacity) shots")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Search formats")
            .navigationTitle("Add Film")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { tipo in
                PersonalizzazionePaccoView(tipo: tipo, viewModel: viewModel) {
                    dismiss()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .tint(.primary)
    }
}

// MARK: - Step 2

/// Customises and saves one pack of the chosen format.
struct PersonalizzazionePaccoView: View {
    let tipo: String
    @ObservedObject var viewModel: FilmPackViewModel
    let onSave: () -> Void

    @State private var modelloSelezionato = ""
    @State private var scattiTotali = 8
    @State private var dataAcquisto = Date()
    @State private var dataScadenza: Date?
    @State private var mostraScadenza = false
    @State private var fotocameraSelezionata: UUID?
    @State private var note = ""
    @State private var inizializzato = false
    @State private var salvato = false

    private var modelli: [String] {
        viewModel.modelliPerTipo(tipo)
    }

    private var fotocamereCompatibili: [Camera] {
        viewModel.fotocamere.filter { viewModel.isCompatibile(tipo, con: $0) }
    }

    private func gradiente(per modello: String) -> FilmPackGradient? {
        FilmPackColors.gradientePerTipo(tipo, modello: modello, modelliDisponibili: viewModel.modelliFilm)
    }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    ColorWheelView(gradient: gradiente(per: modelloSelezionato), size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tipo)
                            .font(.headline)
                        Text(modelloSelezionato.isEmpty ? "Choose a variant" : modelloSelezionato)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Variant") {
                if modelli.isEmpty {
                    Text("No variants available")
                        .foregroundStyle(.secondary)
                }
                ForEach(modelli, id: \.self) { modello in
                    Button {
                        modelloSelezionato = modello
                    } label: {
                        HStack(spacing: 12) {
                            ColorWheelView(gradient: gradiente(per: modello), size: 28)
                            Text(modello)
                                .foregroundStyle(.primary)
                            Spacer()
                            if modello == modelloSelezionato {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .accessibilityAddTraits(modello == modelloSelezionato ? .isSelected : [])
                }
            }

            Section("Shots") {
                Stepper(value: $scattiTotali, in: 1...99) {
                    HStack {
                        Text("Total")
                        Spacer()
                        Text("\(scattiTotali)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                    }
                }
            }

            Section("Dates") {
                DatePicker("Purchase date", selection: $dataAcquisto, displayedComponents: .date)

                Toggle("Has expiry date", isOn: $mostraScadenza)

                if mostraScadenza {
                    DatePicker(
                        "Expiry date",
                        selection: Binding(
                            get: { dataScadenza ?? FilmPack.calcolaScadenzaDefault(dataAcquisto: dataAcquisto) },
                            set: { dataScadenza = $0 }
                        ),
                        displayedComponents: .date
                    )
                }
            }

            if !fotocamereCompatibili.isEmpty {
                Section("Camera") {
                    Picker("Load into", selection: $fotocameraSelezionata) {
                        Text("None").tag(nil as UUID?)
                        ForEach(fotocamereCompatibili) { camera in
                            Text(camera.displayName).tag(camera.id as UUID?)
                        }
                    }
                }
            }

            Section("Notes") {
                TextField("Notes", text: $note, axis: .vertical)
            }
        }
        .navigationTitle(tipo)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    salva()
                }
                .disabled(modelloSelezionato.isEmpty)
            }
        }
        .onAppear {
            guard !inizializzato else { return }
            inizializzato = true
            scattiTotali = viewModel.capacitaDefaultPerTipo(tipo)
            modelloSelezionato = modelli.first ?? ""
        }
        .onChange(of: viewModel.modelliFilm.count) {
            // Models may finish downloading while this screen is open.
            if modelloSelezionato.isEmpty || !modelli.contains(modelloSelezionato) {
                modelloSelezionato = modelli.first ?? ""
            }
        }
        .onChange(of: mostraScadenza) { _, attiva in
            if attiva && dataScadenza == nil {
                dataScadenza = FilmPack.calcolaScadenzaDefault(dataAcquisto: dataAcquisto)
            }
        }
        .sensoryFeedback(.success, trigger: salvato)
    }

    private func salva() {
        let noteRipulite = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let pacco = FilmPack(
            tipo: tipo,
            modello: modelloSelezionato,
            colore: nil,
            scattiTotali: scattiTotali,
            dataAcquisto: dataAcquisto,
            dataScadenza: mostraScadenza ? dataScadenza : nil,
            note: noteRipulite.isEmpty ? nil : noteRipulite
        )

        viewModel.aggiungiPaccoFilm(pacco)

        if let id = fotocameraSelezionata,
           let camera = viewModel.fotocamere.first(where: { $0.id == id }) {
            viewModel.caricaFilm(pacco, in: camera)
        }

        salvato.toggle()
        onSave()
    }
}
