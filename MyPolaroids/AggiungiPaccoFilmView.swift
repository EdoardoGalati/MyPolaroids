import SwiftUI

struct AggiungiPaccoFilmView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FilmPackViewModel
    
    @State private var tipoSelezionato = ""
    @State private var modelloSelezionato = ""
    @State private var dataAcquisto = Date()
    @State private var dataScadenza: Date?
    @State private var note = ""
    @State private var mostraScadenza = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informazioni Pacco Film")) {
                    Picker("Tipo di film", selection: $tipoSelezionato) {
                        Text("Seleziona un tipo").tag("")
                        ForEach(viewModel.tipiDisponibili, id: \.self) { tipo in
                            Text(tipo).tag(tipo)
                        }
                    }
                    
                    if !tipoSelezionato.isEmpty {
                        Picker("Modello", selection: $modelloSelezionato) {
                            Text("Seleziona un modello").tag("")
                            ForEach(viewModel.modelliPerTipo(tipoSelezionato), id: \.self) { modello in
                                Text(modello).tag(modello)
                            }
                        }
                        
                        HStack {
                            Text("Capacità:")
                            Spacer()
                            Text("\(viewModel.capacitaDefaultPerTipo(tipoSelezionato)) scatti")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                    }
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
                
                Section(header: Text("Compatibilità")) {
                    if !tipoSelezionato.isEmpty {
                        let fotocamereCompatibili = viewModel.fotocamereCompatibiliPerTipo(tipoSelezionato)
                        if !fotocamereCompatibili.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fotocamere compatibili:")
                                    .font(.headline)
                                
                                ForEach(fotocamereCompatibili, id: \.self) { fotocamera in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(fotocamera)
                                    }
                                }
                            }
                        } else {
                            Text("Nessuna fotocamera compatibile trovata")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Seleziona un tipo di film per vedere la compatibilità")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Note")) {
                    TextField("Note (opzionale)", text: $note)
                }
                
                Section(header: Text("Scadenza Automatica")) {
                    HStack {
                        Text("Scadenza suggerita:")
                        Spacer()
                        Text(FilmPack.calcolaScadenzaDefault(dataAcquisto: dataAcquisto), style: .date)
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
            }
            .navigationTitle("Nuovo Pacco Film")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        salvaPaccoFilm()
                    }
                    .disabled(tipoSelezionato.isEmpty || modelloSelezionato.isEmpty)
                }
            }
        }
    }
    
    private func salvaPaccoFilm() {
        let scatti = viewModel.capacitaDefaultPerTipo(tipoSelezionato)
        
        let pacco = FilmPack(
            tipo: tipoSelezionato,
            modello: modelloSelezionato,
            scattiTotali: scatti,
            dataAcquisto: dataAcquisto,
            dataScadenza: mostraScadenza ? dataScadenza : nil,
            note: note.isEmpty ? nil : note
        )
        
        viewModel.aggiungiPaccoFilm(pacco)
        dismiss()
    }
}

#Preview {
    AggiungiPaccoFilmView(viewModel: FilmPackViewModel())
}
