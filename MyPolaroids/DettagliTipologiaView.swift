import SwiftUI

struct DettagliTipologiaView: View {
    let tipologia: TipologiaPaccoFilm
    @ObservedObject var viewModel: FilmPackViewModel
    @State private var mostraModifica = false
    @State private var paccoDaModificare: FilmPack?
    @State private var mostraDeleteAlert = false
    @State private var paccoDaEliminare: FilmPack?
    
    var body: some View {
        List {
            // Header con informazioni della tipologia
            Section {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: iconaPerTipo(tipologia.tipo))
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(tipologia.tipo) • \(tipologia.modello)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(tipologia.conteggioTotale) pacchi totali")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            if tipologia.scattiDisponibili > 0 {
                                Text("\(tipologia.scattiDisponibili) scatti disponibili")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Statistiche rapide
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(tipologia.pacchiDisponibili)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Disponibili")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(tipologia.pacchiInScadenza)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("In Scadenza")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(tipologia.pacchiScaduti)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("Scaduti")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(tipologia.pacchiCompletati)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            Text("Completati")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            
            // Pacchi disponibili
            if tipologia.pacchiDisponibili > 0 {
                Section(header: Text("Disponibili (\(tipologia.pacchiDisponibili))")) {
                    ForEach(pacchiDisponibili, id: \.id) { pacco in
                        PaccoFilmRowView(pacco: pacco)
                            .contextMenu {
                                Button("Modifica") {
                                    paccoDaModificare = pacco
                                    mostraModifica = true
                                }
                                
                                Button("Elimina", role: .destructive) {
                                    paccoDaEliminare = pacco
                                    mostraDeleteAlert = true
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Elimina", role: .destructive) {
                                    paccoDaEliminare = pacco
                                    mostraDeleteAlert = true
                                }
                            }
                    }
                }
            }
            
            // Pacchi in scadenza
            if tipologia.pacchiInScadenza > 0 {
                Section(header: Text("In Scadenza (\(tipologia.pacchiInScadenza))")) {
                    ForEach(pacchiInScadenza, id: \.id) { pacco in
                        PaccoFilmRowView(pacco: pacco)
                            .contextMenu {
                                Button("Modifica") {
                                    paccoDaModificare = pacco
                                    mostraModifica = true
                                }
                                
                                Button("Elimina", role: .destructive) {
                                    paccoDaEliminare = pacco
                                    mostraDeleteAlert = true
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Elimina", role: .destructive) {
                                    paccoDaEliminare = pacco
                                    mostraDeleteAlert = true
                                }
                            }
                    }
                }
            }
            
            // Pacchi scaduti
            if tipologia.pacchiScaduti > 0 {
                Section(header: Text("Scaduti (\(tipologia.pacchiScaduti))")) {
                    ForEach(pacchiScaduti, id: \.id) { pacco in
                        PaccoFilmRowView(pacco: pacco)
                            .contextMenu {
                                Button("Modifica") {
                                    paccoDaModificare = pacco
                                    mostraModifica = true
                                }
                                
                                Button("Elimina", role: .destructive) {
                                    paccoDaEliminare = pacco
                                    mostraDeleteAlert = true
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Elimina", role: .destructive) {
                                    paccoDaEliminare = pacco
                                    mostraDeleteAlert = true
                                }
                            }
                    }
                }
            }
            
            // Pacchi completati
            if tipologia.pacchiCompletati > 0 {
                Section(header: Text("Completati (\(tipologia.pacchiCompletati))")) {
                    ForEach(pacchiCompletati, id: \.id) { pacco in
                        PaccoFilmRowView(pacco: pacco)
                            .contextMenu {
                                Button("Modifica") {
                                    paccoDaModificare = pacco
                                    mostraModifica = true
                                }
                                
                                Button("Elimina", role: .destructive) {
                                    paccoDaEliminare = pacco
                                    mostraDeleteAlert = true
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Elimina", role: .destructive) {
                                    paccoDaEliminare = pacco
                                    mostraDeleteAlert = true
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("Dettagli \(tipologia.tipo)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $mostraModifica) {
            if let pacco = paccoDaModificare {
                ModificaPaccoFilmView(pacco: Binding(
                    get: { pacco },
                    set: { newValue in
                        viewModel.aggiornaPaccoFilm(newValue)
                    }
                ), viewModel: viewModel)
            }
        }
        .alert("Elimina Pacco Film", isPresented: $mostraDeleteAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Elimina", role: .destructive) {
                if let pacco = paccoDaEliminare {
c                     viewModel.rimuoviPaccoFilm(pacco)
                }
            }
        } message: {
            Text("Sei sicuro di voler eliminare questo pacco film? L'azione non può essere annullata.")
        }
    }
    
    // Filtri per i pacchi della tipologia
    private var pacchiDisponibili: [FilmPack] {
        return viewModel.pacchiFilm.filter { pacco in
            pacco.tipo == tipologia.tipo && 
            pacco.modello == tipologia.modello && 
            pacco.scattiRimanenti > 0 && 
            (pacco.dataScadenza == nil || pacco.dataScadenza! > Date())
        }
    }
    
    private var pacchiInScadenza: [FilmPack] {
        return viewModel.pacchiFilm.filter { pacco in
            pacco.tipo == tipologia.tipo && 
            pacco.modello == tipologia.modello && 
            pacco.scattiRimanenti > 0 && 
            pacco.dataScadenza != nil && 
            pacco.dataScadenza! <= Date().addingTimeInterval(30 * 24 * 3600) && // 30 giorni
            pacco.dataScadenza! > Date()
        }
    }
    
    private var pacchiScaduti: [FilmPack] {
        return viewModel.pacchiFilm.filter { pacco in
            pacco.tipo == tipologia.tipo && 
            pacco.modello == tipologia.modello && 
            pacco.scattiRimanenti > 0 && 
            pacco.dataScadenza != nil && 
            pacco.dataScadenza! <= Date()
        }
    }
    
    private var pacchiCompletati: [FilmPack] {
        return viewModel.pacchiFilm.filter { pacco in
            pacco.tipo == tipologia.tipo && 
            pacco.modello == tipologia.modello && 
            pacco.scattiRimanenti == 0
        }
    }
    
    private func iconaPerTipo(_ tipo: String) -> String {
        switch tipo {
        case "600":
            return "camera.fill"
        case "i-Type":
            return "camera"
        case "SX-70":
            return "camera.viewfinder"
        case "Go":
            return "camera.circle"
        case "Spectra":
            return "camera.badge.ellipsis"
        case "8x10":
            return "camera.aperture"
        case "4x5":
            return "camera.metering.center"
        default:
            return "camera"
        }
    }
}

#Preview {
    NavigationView {
        DettagliTipologiaView(
            tipologia: TipologiaPaccoFilm(
                tipo: "600",
                modello: "Color",
                pacchi: []
            ),
            viewModel: FilmPackViewModel()
        )
    }
}
