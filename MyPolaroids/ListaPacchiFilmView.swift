import SwiftUI

struct ListaPacchiFilmView: View {
    @ObservedObject var viewModel: FilmPackViewModel
    @State private var mostraAggiungiPacco = false
    @State private var mostraModificaPacco = false
    @State private var paccoDaModificare: FilmPack?
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.pacchiFilm.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "film")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Nessun pacco film")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Aggiungi il tuo primo pacco film per iniziare l'inventario!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Pacchi in scadenza
                    if !viewModel.pacchiInScadenza.isEmpty {
                        Section("⚠️ In Scadenza") {
                            ForEach(viewModel.pacchiInScadenza) { pacco in
                                PaccoFilmRowView(pacco: pacco)
                            }
                        }
                    }
                    
                    // Pacchi disponibili
                    if !viewModel.pacchiDisponibili.isEmpty {
                        Section("📦 Disponibili") {
                            ForEach(viewModel.pacchiDisponibili) { pacco in
                                PaccoFilmRowView(pacco: pacco)
                            }
                        }
                    }
                    
                    // Pacchi associati
                    let pacchiAssociati = viewModel.pacchiFilm.filter { $0.fotocameraAssociata != nil && !$0.isFinito }
                    if !pacchiAssociati.isEmpty {
                        Section("📷 In Uso") {
                            ForEach(pacchiAssociati) { pacco in
                                PaccoFilmRowView(pacco: pacco)
                            }
                        }
                    }
                    
                    // Pacchi finiti
                    if !viewModel.pacchiFiniti.isEmpty {
                        Section("✅ Completati") {
                            ForEach(viewModel.pacchiFiniti) { pacco in
                                PaccoFilmRowView(pacco: pacco)
                            }
                        }
                    }
                    
                    // Pacchi scaduti
                    if !viewModel.pacchiScaduti.isEmpty {
                        Section("❌ Scaduti") {
                            ForEach(viewModel.pacchiScaduti) { pacco in
                                PaccoFilmRowView(pacco: pacco)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Inventario Film")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostraAggiungiPacco = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostraAggiungiPacco) {
                AggiungiPaccoFilmView(viewModel: viewModel)
            }
            .sheet(isPresented: $mostraModificaPacco) {
                if let pacco = paccoDaModificare {
                    ModificaPaccoFilmView(
                        pacco: Binding(
                            get: { pacco },
                            set: { newValue in
                                viewModel.aggiornaPaccoFilm(newValue)
                            }
                        ),
                        viewModel: viewModel
                    )
                }
            }
        }
    }
}

struct PaccoFilmRowView: View {
    let pacco: FilmPack
    
    var body: some View {
        HStack(spacing: 16) {
            // Icona del pacco film
            VStack {
                Image(systemName: "film")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("\(pacco.scattiRimanenti)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .frame(width: 50, height: 50)
            .background(Color(.white))
            .cornerRadius(16)
            
            // Informazioni principali
            VStack(alignment: .leading, spacing: 4) {
                Text(pacco.tipo)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(pacco.modello)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text("\(pacco.scattiTotali) scatti totali")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if pacco.fotocameraAssociata != nil {
                    Text("In uso")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if let giorni = pacco.giorniAllaScadenza {
                    if pacco.isScaduto {
                        Text("Scaduto")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if pacco.isInScadenza {
                        Text("Scade in \(giorni) giorni")
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text("Scade in \(giorni) giorni")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Barra di progresso
            VStack(alignment: .trailing, spacing: 2) {
                ProgressView(value: pacco.percentualeUtilizzo, total: 100)
                    .frame(width: 60)
                    .scaleEffect(0.8)
                
                Text("\(Int(pacco.percentualeUtilizzo))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button("Visualizza dettagli") {
                // Azione per visualizzare dettagli
            }
        }
    }
}

#Preview {
    ListaPacchiFilmView(viewModel: FilmPackViewModel())
}
