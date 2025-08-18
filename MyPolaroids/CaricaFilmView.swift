import SwiftUI

struct CaricaFilmView: View {
    let fotocamera: Camera
    @ObservedObject var viewModel: FilmPackViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var filmSelezionato: FilmPack?
    @State private var mostraAlert = false
    @State private var alertMessage = ""
    @State private var mostraAggiungiFilm = false
    @State private var filmCompatibiliCache: [FilmPack] = []
    
    var filmCompatibili: [FilmPack] {
        // Usa la cache se disponibile, altrimenti calcola
        if !filmCompatibiliCache.isEmpty {
            return filmCompatibiliCache
        }
        
        let filmFiltrati = viewModel.pacchiFilm.filter { pacco in
            // Verifica compatibilità con cache intelligente
            let compatibile = viewModel.isCompatibile(pacco.tipo, con: fotocamera)
            // Verifica che non sia già in uso
            let nonInUso = !pacco.isInUso
            // Verifica che abbia scatti disponibili
            let haScatti = pacco.scattiRimanenti > 0
            // Verifica che non sia scaduto
            let nonScaduto = !pacco.isScaduto
            // Verifica che non sia già caricato in questa fotocamera
            let nonInQuestaFotocamera = pacco.fotocameraAssociata != fotocamera.id
            
            return compatibile && nonInUso && haScatti && nonScaduto && nonInQuestaFotocamera
        }
        
        // Aggiorna la cache
        DispatchQueue.main.async {
            self.filmCompatibiliCache = filmFiltrati
        }
        
        return filmFiltrati
    }
    
    // Aggrega i pacchi per tipo e modello
    var filmCompatibiliAggregati: [FilmPackAggregato] {
        var aggregati: [String: FilmPackAggregato] = [:]
        
        for pacco in filmCompatibili {
            let chiave = "\(pacco.tipo)_\(pacco.modello)"
            
            if let esistente = aggregati[chiave] {
                // Aggiorna il pacco esistente
                aggregati[chiave] = FilmPackAggregato(
                    tipo: esistente.tipo,
                    modello: esistente.modello,
                    conteggio: esistente.conteggio + 1,
                    scattiTotali: esistente.scattiTotali + pacco.scattiRimanenti,
                    modelliDisponibili: esistente.modelliDisponibili
                )
            } else {
                // Crea un nuovo aggregato
                aggregati[chiave] = FilmPackAggregato(
                    tipo: pacco.tipo,
                    modello: pacco.modello,
                    conteggio: 1,
                    scattiTotali: pacco.scattiRimanenti,
                    modelliDisponibili: viewModel.modelliFilm
                )
            }
        }
        
        // Ordina per tipo e poi per modello
        return aggregati.values.sorted { first, second in
            if first.tipo == second.tipo {
                return first.modello < second.modello
            }
            return first.tipo < second.modello
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if filmCompatibiliAggregati.isEmpty {
                    // Nessun film compatibile
                    VStack(spacing: 1) {
                        // Cella con icona e testo
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            
                            Text("No compatible film available")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text("All compatible films are in use, finished or expired")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 32)
                        
                        // Cella con pulsante (senza background)
                        Button(action: {
                            mostraAggiungiFilm = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add New Film")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                } else {
                    // Lista film compatibili
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(filmCompatibiliAggregati) { pacco in
                                FilmPackRowView(pacco: pacco)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // Trova un pacco disponibile di questo tipo
                                        if let paccoDisponibile = filmCompatibili.first(where: { 
                                            $0.tipo == pacco.tipo && $0.modello == pacco.modello 
                                        }) {
                                            filmSelezionato = paccoDisponibile
                                            mostraAlert = true
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Load \(fotocamera.nickname.isEmpty ? fotocamera.modello : fotocamera.nickname)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Load Film", isPresented: $mostraAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Load") {
                    if let pacco = filmSelezionato {
                        viewModel.caricaFilm(pacco, in: fotocamera)
                        dismiss()
                    }
                }
            } message: {
                if let pacco = filmSelezionato {
                    // Trova l'aggregato corrispondente per mostrare il conteggio
                    let aggregato = filmCompatibiliAggregati.first { 
                        $0.tipo == pacco.tipo && $0.modello == pacco.modello 
                    }
                    
                    if let agg = aggregato {
                        Text("Do you want to load a \(pacco.tipo) \(pacco.modello) film pack? You have \(agg.conteggio) pack\(agg.conteggio == 1 ? "" : "s") available.")
                    } else {
                        Text("Do you want to load the film \(pacco.tipo) \(pacco.modello)?")
                    }
                } else {
                    Text("Select a film to load")
                }
            }
            .sheet(isPresented: $mostraAggiungiFilm) {
                AggiungiPaccoFilmView(viewModel: viewModel)
            }
            .onReceive(viewModel.$pacchiFilm) { _ in
                // Pulisce la cache quando cambiano i pacchi film
                filmCompatibiliCache.removeAll()
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Struct per pacchi aggregati
struct FilmPackAggregato: Identifiable {
    let id: String
    let tipo: String
    let modello: String
    let conteggio: Int
    let scattiTotali: Int
    let modelliDisponibili: [FilmPackModel]
    
    init(tipo: String, modello: String, conteggio: Int, scattiTotali: Int, modelliDisponibili: [FilmPackModel]) {
        self.id = "\(tipo)_\(modello)"
        self.tipo = tipo
        self.modello = modello
        self.conteggio = conteggio
        self.scattiTotali = scattiTotali
        self.modelliDisponibili = modelliDisponibili
    }
}

struct FilmPackRowView: View {
    let pacco: FilmPackAggregato
    
    var body: some View {
        HStack(spacing: 16) {
            // Indicatore colori del pacco
            FilmPackColorIndicator(tipo: pacco.tipo, modello: pacco.modello, modelliDisponibili: pacco.modelliDisponibili, size: 40)
            
            // Informazioni film
            VStack(alignment: .leading, spacing: 4) {
                Text("\(pacco.tipo) • \(pacco.modello)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(pacco.conteggio) pack\(pacco.conteggio == 1 ? "" : "s") available")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    let fotocamera = Camera(
        nickname: "Fotocamera temporanea",
        modello: "Polaroid 600",
        coloreIcona: "000"
    )
    return CaricaFilmView(
        fotocamera: fotocamera,
        viewModel: FilmPackViewModel()
    )
}
