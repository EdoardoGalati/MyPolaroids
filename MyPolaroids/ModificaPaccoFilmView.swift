import SwiftUI

struct ModificaPaccoFilmView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var pacco: FilmPack
    
    @State private var tipoSelezionato: String
    @State private var modelloSelezionato: String
    @State private var scattiTotali: String
    @State private var scattiRimanenti: String
    @State private var dataAcquisto: Date
    @State private var dataScadenza: Date?
    @State private var note: String
    @State private var mostraScadenza: Bool
    @State private var fotocameraSelezionata: UUID?
    
    init(pacco: Binding<FilmPack>, viewModel: FilmPackViewModel) {
        self._pacco = pacco
        self.viewModel = viewModel
        self._tipoSelezionato = State(initialValue: pacco.wrappedValue.tipo)
        self._modelloSelezionato = State(initialValue: pacco.wrappedValue.modello)
        self._scattiTotali = State(initialValue: String(pacco.wrappedValue.scattiTotali))
        self._scattiRimanenti = State(initialValue: String(pacco.wrappedValue.scattiRimanenti))
        self._dataAcquisto = State(initialValue: pacco.wrappedValue.dataAcquisto)
        self._dataScadenza = State(initialValue: pacco.wrappedValue.dataScadenza)
        self._note = State(initialValue: pacco.wrappedValue.note ?? "")
        self._mostraScadenza = State(initialValue: pacco.wrappedValue.dataScadenza != nil)
        self._fotocameraSelezionata = State(initialValue: pacco.wrappedValue.fotocameraAssociata)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informazioni Pacco Film")) {
                    Picker("Tipo di film", selection: $tipoSelezionato) {
                        ForEach(viewModel.tipiDisponibili, id: \.self) { tipo in
                            Text(tipo).tag(tipo)
                        }
                    }
                    
                    Picker("Modello", selection: $modelloSelezionato) {
                        ForEach(viewModel.modelliPerTipo(tipoSelezionato), id: \.self) { modello in
                            Text(modello).tag(modello)
                        }
                    }
                    
                    TextField("Scatti totali", text: $scattiTotali)
                        .keyboardType(.numberPad)
                    
                    TextField("Scatti rimanenti", text: $scattiRimanenti)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Data acquisto", selection: $dataAcquisto, displayedComponents: .date)
                    
                    Toggle("Imposta scadenza", isOn: $mostraScadenza)
                    
                    if mostraScadenza {
                        DatePicker("Data scadenza", selection: Binding(
                            get: { dataScadenza ?? FilmPack.calcolaScadenzaDefault(dataAcquisto: dataAcquisto) },
                            set: { dataScadenza = $0 }
                        ), displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Associazione Fotocamera")) {
                    if let fotocameraId = fotocameraSelezionata,
                       let fotocamera = viewModel.fotocamere.first(where: { $0.id == fotocameraId }) {
                        HStack {
                            Text("Associato a:")
                            Spacer()
                            Text(fotocamera.nickname)
                                .foregroundColor(.green)
                        }
                        
                        Button("Disassocia") {
                            fotocameraSelezionata = nil
                        }
                        .foregroundColor(.red)
                    } else {
                        Text("Nessuna fotocamera associata")
                            .foregroundColor(.secondary)
                        
                        if !viewModel.fotocamere.isEmpty {
                            Picker("Associa a fotocamera", selection: $fotocameraSelezionata) {
                                Text("Nessuna").tag(nil as UUID?)
                                ForEach(viewModel.fotocamere) { fotocamera in
                                    Text(fotocamera.nickname).tag(fotocamera.id as UUID?)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Note")) {
                    TextField("Note (opzionale)", text: $note)
                }
                
                Section(header: Text("Stato Pacco")) {
                    HStack {
                        Text("Percentuale utilizzo:")
                        Spacer()
                        Text("\(Int(pacco.percentualeUtilizzo))%")
                            .foregroundColor(.blue)
                    }
                    
                    if let giorni = pacco.giorniAllaScadenza {
                        HStack {
                            Text("Giorni alla scadenza:")
                            Spacer()
                            if pacco.isScaduto {
                                Text("Scaduto")
                                    .foregroundColor(.red)
                            } else if pacco.isInScadenza {
                                Text("\(giorni) giorni")
                                    .foregroundColor(.orange)
                            } else {
                                Text("\(giorni) giorni")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Modifica Pacco Film")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        salvaModifiche()
                    }
                    .disabled(tipoSelezionato.isEmpty || modelloSelezionato.isEmpty || scattiTotali.isEmpty || scattiRimanenti.isEmpty)
                }
            }
        }
    }
    
    private func salvaModifiche() {
        guard let scattiTotaliInt = Int(scattiTotali),
              let scattiRimanentiInt = Int(scattiRimanenti) else { return }
        
        pacco.tipo = tipoSelezionato
        pacco.modello = modelloSelezionato
        pacco.scattiTotali = scattiTotaliInt
        pacco.scattiRimanenti = scattiRimanentiInt
        pacco.dataAcquisto = dataAcquisto
        pacco.dataScadenza = mostraScadenza ? dataScadenza : nil
        pacco.note = note.isEmpty ? nil : note
        pacco.fotocameraAssociata = fotocameraSelezionata
        
        viewModel.aggiornaPaccoFilm(pacco)
        dismiss()
    }
}

#Preview {
    ModificaPaccoFilmView(
        pacco: .constant(FilmPack(
            tipo: "600",
            modello: "Color",
            scattiTotali: 8
        )),
        viewModel: FilmPackViewModel()
    )
}
