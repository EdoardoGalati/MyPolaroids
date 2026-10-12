import SwiftUI

/// Full edit sheet for one film pack.
struct ModificaPaccoFilmView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var pacco: FilmPack

    @State private var tipoSelezionato: String
    @State private var modelloSelezionato: String
    @State private var scattiTotali: Int
    @State private var scattiRimanenti: Int
    @State private var dataAcquisto: Date
    @State private var dataScadenza: Date?
    @State private var note: String
    @State private var mostraScadenza: Bool
    @State private var fotocameraSelezionata: UUID?
    @State private var salvato = false

    init(pacco: Binding<FilmPack>, viewModel: FilmPackViewModel) {
        self._pacco = pacco
        self.viewModel = viewModel
        self._tipoSelezionato = State(initialValue: pacco.wrappedValue.tipo)
        self._modelloSelezionato = State(initialValue: pacco.wrappedValue.modello)
        self._scattiTotali = State(initialValue: max(pacco.wrappedValue.scattiTotali, 1))
        self._scattiRimanenti = State(initialValue: max(pacco.wrappedValue.scattiRimanenti, 0))
        self._dataAcquisto = State(initialValue: pacco.wrappedValue.dataAcquisto)
        self._dataScadenza = State(initialValue: pacco.wrappedValue.dataScadenza)
        self._note = State(initialValue: pacco.wrappedValue.note ?? "")
        self._mostraScadenza = State(initialValue: pacco.wrappedValue.dataScadenza != nil)
        self._fotocameraSelezionata = State(initialValue: pacco.wrappedValue.fotocameraAssociata)
    }

    private var modelli: [String] {
        viewModel.modelliPerTipo(tipoSelezionato)
    }

    /// The pack as it would be after saving, used for the status rows.
    private var anteprima: FilmPack {
        var copia = pacco
        copia.tipo = tipoSelezionato
        copia.modello = modelloSelezionato
        copia.scattiTotali = scattiTotali
        copia.scattiRimanenti = scattiRimanenti
        copia.dataAcquisto = dataAcquisto
        copia.dataScadenza = mostraScadenza ? dataScadenza : nil
        return copia
    }

    private var stato: String {
        let p = anteprima
        if p.isFinito { return "Finished" }
        if p.isScaduto { return "Expired" }
        if p.isInScadenza { return "Expiring" }
        return "Available"
    }

    private var scadenzaDescrizione: String? {
        guard let giorni = anteprima.giorniAllaScadenza else { return nil }
        if giorni < 0 { return "Expired \(giorniTesto(-giorni)) ago" }
        if giorni == 0 { return "Expires today" }
        return "In \(giorniTesto(giorni))"
    }

    private func giorniTesto(_ n: Int) -> String {
        n == 1 ? "1 day" : "\(n) days"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Pack") {
                    Picker("Format", selection: $tipoSelezionato) {
                        ForEach(viewModel.tipiDisponibili, id: \.self) { tipo in
                            Text(tipo).tag(tipo)
                        }
                    }

                    Picker("Variant", selection: $modelloSelezionato) {
                        ForEach(modelli, id: \.self) { modello in
                            Text(modello).tag(modello)
                        }
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

                    Stepper(value: $scattiRimanenti, in: 0...scattiTotali) {
                        HStack {
                            Text("Remaining")
                            Spacer()
                            Text("\(scattiRimanenti)")
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

                Section("Camera") {
                    if viewModel.fotocamere.isEmpty {
                        Text("No cameras yet")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Camera", selection: $fotocameraSelezionata) {
                            Text("None").tag(nil as UUID?)
                            ForEach(viewModel.fotocamere) { fotocamera in
                                Text(fotocamera.displayName).tag(fotocamera.id as UUID?)
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $note, axis: .vertical)
                }

                Section("Status") {
                    LabeledContent("Status", value: stato)
                    LabeledContent("Used", value: "\(Int(anteprima.percentualeUtilizzo))%")
                    if let scadenzaDescrizione {
                        LabeledContent("Expiry", value: scadenzaDescrizione)
                    }
                }
            }
            .navigationTitle("Edit Film Pack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        salvaModifiche()
                    }
                    .disabled(tipoSelezionato.isEmpty || modelloSelezionato.isEmpty)
                }
            }
            .onChange(of: tipoSelezionato) {
                // Keep the variant valid for the newly chosen format.
                if !modelli.contains(modelloSelezionato) {
                    modelloSelezionato = modelli.first ?? ""
                }
            }
            .onChange(of: scattiTotali) { _, nuovo in
                if scattiRimanenti > nuovo {
                    scattiRimanenti = nuovo
                }
            }
            .onChange(of: mostraScadenza) { _, attiva in
                if attiva && dataScadenza == nil {
                    dataScadenza = FilmPack.calcolaScadenzaDefault(dataAcquisto: dataAcquisto)
                }
            }
        }
        .tint(.primary)
        .sensoryFeedback(.success, trigger: salvato)
    }

    private func salvaModifiche() {
        let noteRipulite = note.trimmingCharacters(in: .whitespacesAndNewlines)

        var aggiornato = pacco
        aggiornato.tipo = tipoSelezionato
        aggiornato.modello = modelloSelezionato
        aggiornato.scattiTotali = scattiTotali
        aggiornato.scattiRimanenti = min(scattiRimanenti, scattiTotali)
        aggiornato.dataAcquisto = dataAcquisto
        aggiornato.dataScadenza = mostraScadenza ? dataScadenza : nil
        aggiornato.note = noteRipulite.isEmpty ? nil : noteRipulite
        aggiornato.fotocameraAssociata = fotocameraSelezionata

        pacco = aggiornato
        viewModel.aggiornaPaccoFilm(aggiornato)
        salvato.toggle()
        dismiss()
    }
}
