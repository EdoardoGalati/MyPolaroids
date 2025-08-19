import SwiftUI

struct AggiungiPaccoFilmView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FilmPackViewModel
    
    @State private var tipoSelezionato = ""
    @State private var modelloSelezionatoStep1 = "Color"
    @State private var dataAcquisto = Date()
    @State private var dataScadenza: Date? = nil
    @State private var searchText = ""
    @State private var mostraPersonalizzazione = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 1) {
                // STEP 1: Selezione Film
                stepSelezioneFilm
                
                // NavigationLink rimosso - ora usiamo una modale
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("New Film Pack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $mostraPersonalizzazione) {
                PersonalizzazionePaccoView(
                    tipo: tipoSelezionato,
                    viewModel: viewModel,
                    onSave: {
                        mostraPersonalizzazione = false
                        dismiss()
                    }
                )
            }
        }
        .onAppear {
            print("🔍 [AggiungiPaccoFilmView] Vista principale è apparsa")
        }
    }
    
    // MARK: - STEP 1: Selezione Film
    private var stepSelezioneFilm: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Barra di ricerca in cima senza background
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search film types...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .frame(height: 52)
            .padding(.horizontal, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(26)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            // Lista tipi di film
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(tipiFilmFiltrati, id: \.self) { tipo in
                            bottoneTipoFilm(tipo: tipo)
                        }
                    }
                }
            }
            .background(Color.clear)
        }
    }
    
    // MARK: - Bottone Tipo Film
    private func bottoneTipoFilm(tipo: String) -> some View {
        Button(action: {
            print("🔍 [AggiungiPaccoFilmView] Tap su tipo: \(tipo)")
            tipoSelezionato = tipo
            print("🔍 [AggiungiPaccoFilmView] tipoSelezionato: \(tipoSelezionato)")
            
            // Seleziona sempre il primo modello disponibile come default
            let modelli = viewModel.modelliPerTipo(tipo)
            print("🔍 [AggiungiPaccoFilmView] Modelli disponibili per \(tipo): \(modelli)")
            
            if modelli.count > 0 {
                modelloSelezionatoStep1 = modelli[0]
                print("🔍 [AggiungiPaccoFilmView] Modello default selezionato: '\(modelloSelezionatoStep1)' per tipo '\(tipo)'")
            } else {
                print("⚠️ [AggiungiPaccoFilmView] Nessun modello disponibile per tipo '\(tipo)'")
            }
            
            mostraPersonalizzazione = true
        }) {
            HStack(spacing: 16) {
                // Info film
                VStack(alignment: .leading, spacing: 4) {
                    Text(tipo)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            print("🔍 [AggiungiPaccoFilmView] Bottone per tipo '\(tipo)' è apparso")
        }
    }
    
    // MARK: - Computed Properties
    private var tipiFilmFiltrati: [String] {
        if searchText.isEmpty {
            return viewModel.tipiDisponibili
        } else {
            return viewModel.tipiDisponibili.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var modelliDisponibili: [String] {
        // Se è stato selezionato un tipo, mostra i modelli disponibili per quel tipo
        if !tipoSelezionato.isEmpty {
            return viewModel.modelliPerTipo(tipoSelezionato)
        }
        // Altrimenti mostra i modelli base
        return ["Color", "Black & White", "Color Frame", "Black Frame B&W"]
    }
    
    // La funzione salvaPaccoFilm è stata spostata in PersonalizzazionePaccoView
}

// MARK: - Personalizzazione Pacco View
struct PersonalizzazionePaccoView: View {
    @Environment(\.dismiss) private var dismiss
    let tipo: String
    @ObservedObject var viewModel: FilmPackViewModel
    let onSave: () -> Void
    
    @State private var modelliDisponibili: [String] = []
    @State private var modelloSelezionato: String = ""
    @State private var dataAcquisto = Date()
    @State private var dataScadenza: Date?
    @State private var mostraScadenza = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.modelliFilm.isEmpty {
                VStack {
                    Spacer()
                    ProgressView("Caricamento modelli...")
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        // Info film selezionato
                        VStack(spacing: 1) {
                            VStack(spacing: 20) {
                                // Indicatore colore del tipo di film con gradienti reali
                                FilmPackColorIndicator(
                                    tipo: tipo,
                                    modello: modelloSelezionato,
                                    modelliDisponibili: viewModel.modelliFilm,
                                    size: 40
                                )
                                
                                VStack(alignment: .center, spacing: 8) {
                                    Text(tipo)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(modelloSelezionato)
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 32)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 0.5)
                        .background(AppColors.backgroundPrimary)
                        .cornerRadius(16)
                        
                        // Film Model Selection
                        VStack(spacing: 1) {
                            HStack {
                                Text("Film Model")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                                Menu {
                                    ForEach(modelliDisponibili, id: \.self) { modello in
                                        Button(modello) {
                                            modelloSelezionato = modello
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(modelloSelezionato)
                                            .foregroundColor(.primary)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 0.5)
                        .background(AppColors.backgroundPrimary)
                        .cornerRadius(16)
                        
                        // Date
                        VStack(spacing: 1) {
                            DatePicker("Purchase date", selection: $dataAcquisto, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.backgroundSecondary)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 0.5)
                        .background(AppColors.backgroundPrimary)
                        .cornerRadius(16)
                        
                        // Expiry Date
                        VStack(spacing: 1) {
                            Toggle("Set expiration date", isOn: $mostraScadenza)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.backgroundSecondary)
                                .cornerRadius(16)
                                .onChange(of: mostraScadenza) { newValue in
                                    if newValue && dataScadenza == nil {
                                        // Se attivo il toggle e non c'è data, imposta oggi come default
                                        dataScadenza = Date()
                                    }
                                }
                            
                            if mostraScadenza {
                                DatePicker("Expiration date", selection: Binding(
                                    get: { dataScadenza ?? Date() },
                                    set: { dataScadenza = $0 }
                                ), displayedComponents: .date)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.backgroundSecondary)
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 0)
                        .padding(.vertical, 0.5)
                        .background(AppColors.backgroundPrimary)
                        .cornerRadius(16)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 0)
                }
                .background(AppColors.backgroundPrimary)
                .navigationTitle("Customize Film Pack")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            salvaPaccoFilm()
                        }
                        .fontWeight(.semibold)
                    }
                }
                                 .onAppear {
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                         modelliDisponibili = viewModel.modelliPerTipo(tipo)
                         modelloSelezionato = modelliDisponibili.first ?? ""
                         print("🔍 [PersonalizzazionePaccoView] modelliDisponibili: \(modelliDisponibili)")
                         print("🔍 [PersonalizzazionePaccoView] modelloSelezionato: \(modelloSelezionato)")
                     }
                     print("🔍 [PersonalizzazionePaccoView] Vista modale è apparsa")
                     print("🔍 [PersonalizzazionePaccoView] tipo: \(tipo)")
                 }
            }
        }
    }
    
    private func salvaPaccoFilm() {
        let scatti = viewModel.capacitaDefaultPerTipo(tipo)
        
        let pacco = FilmPack(
            tipo: tipo,
            modello: modelloSelezionato,
            colore: nil,
            scattiTotali: scatti,
            dataAcquisto: dataAcquisto,
            dataScadenza: mostraScadenza ? dataScadenza : nil,
            note: nil
        )
        
        viewModel.aggiungiPaccoFilm(pacco)
        onSave()
    }
}



#Preview {
    AggiungiPaccoFilmView(viewModel: FilmPackViewModel())
}
