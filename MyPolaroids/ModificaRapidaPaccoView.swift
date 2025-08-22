import SwiftUI

struct ModificaRapidaPaccoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var pacco: FilmPack
    @Binding var selectedTab: Int
    
    @State private var dataScadenza: Date?
    @State private var mostraScadenza: Bool
    @State private var mostraDeleteAlert = false
    
    init(pacco: Binding<FilmPack>, viewModel: FilmPackViewModel, selectedTab: Binding<Int>) {
        self._pacco = pacco
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        self._dataScadenza = State(initialValue: pacco.wrappedValue.dataScadenza)
        self._mostraScadenza = State(initialValue: pacco.wrappedValue.dataScadenza != nil)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // Pack Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pack Information")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 1) {
                            HStack {
                                Text("Type:")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(pacco.tipo)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(16)
                            
                            HStack {
                                Text("Model:")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(pacco.modello)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(16)
                            
                            HStack {
                                Text("Remaining shots:")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(pacco.scattiRimanenti)/\(pacco.scattiTotali)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.backgroundSecondary)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 0)
                    }
                    .padding(.horizontal, 0)
                    .padding(.vertical, 20)
                    .background(AppColors.backgroundPrimary)
                    .cornerRadius(16)
                    
                    // Expiration Date Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Expiration Date")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
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
                    }
                    .padding(.horizontal, 0)
                    .padding(.vertical, 20)
                    .background(AppColors.backgroundPrimary)
                    .cornerRadius(16)
                    
                    // Delete Pack Section
                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: {
                            mostraDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 18))
                                Text("Delete Pack")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(AppColors.buttonText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 0)
                    .padding(.vertical, 20)
                    .background(AppColors.backgroundPrimary)
                    .cornerRadius(16)
                }
                .padding(.top, 20)
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Edit Pack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.navigationButton)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        salvaModifiche()
                    }
                    .foregroundColor(AppColors.navigationButton)
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
        }
    }
    
    private func salvaModifiche() {
        print("🔧 [EDIT] ===== INIZIO SALVAMODIFICHE PACCO =====")
        print("🔧 [EDIT] Valori negli stati:")
        print("   - mostraScadenza: \(mostraScadenza)")
        print("   - dataScadenza: \(dataScadenza?.description ?? "nil")")
        
        print("🔧 [EDIT] Pacco ORIGINALE:")
        print("   - id: \(pacco.id)")
        print("   - dataScadenza: \(pacco.dataScadenza?.description ?? "nil")")
        
        // Creo una NUOVA istanza del pacco con i valori aggiornati
        print("🔧 [EDIT] Creazione pacco aggiornato...")
        var paccoAggiornato = pacco
        paccoAggiornato.dataScadenza = mostraScadenza ? dataScadenza : nil
        
        print("🔧 [EDIT] Pacco AGGIORNATO:")
        print("   - id: \(paccoAggiornato.id)")
        print("   - dataScadenza: \(paccoAggiornato.dataScadenza?.description ?? "nil")")
        
        print("🔧 [EDIT] Chiamata viewModel.aggiornaPaccoFilm()")
        viewModel.aggiornaPaccoFilm(paccoAggiornato)
        print("🔧 [EDIT] viewModel.aggiornaPaccoFilm() completata")
        
        print("🔧 [EDIT] Chiusura vista")
        dismiss()
        print("🔧 [EDIT] ===== FINE SALVAMODIFICHE PACCO =====")
    }
    
    private func eliminaPacco() {
        // Salva le informazioni del tipo prima di eliminarlo
        let tipoPacco = pacco.tipo
        let modelliPacco = pacco.modello
        
        // Elimina il pacco
        viewModel.rimuoviPaccoFilm(pacco)
        
        // Controlla se ci sono ancora pacchi dello stesso tipo e modello
        let pacchiRimanenti = viewModel.pacchiFilm.filter { 
            $0.tipo == tipoPacco && $0.modello == modelliPacco 
        }
        
        // Se non ci sono più pacchi di questo tipo, torna alla home dei film pack
        if pacchiRimanenti.isEmpty {
            selectedTab = 1
        }
        
        dismiss()
    }
}

#Preview {
    ModificaRapidaPaccoView(
        pacco: .constant(FilmPack(
            tipo: "600",
            modello: "Color",
            scattiTotali: 8
        )),
        viewModel: FilmPackViewModel(),
        selectedTab: .constant(0)
    )
}

