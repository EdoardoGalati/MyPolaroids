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
            let compatibile = viewModel.isCompatibile(pacco.tipo, con: fotocamera.modello)
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header fotocamera
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text(fotocamera.nickname)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(fotocamera.modello)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if filmCompatibili.isEmpty {
                    // Nessun film compatibile
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("Nessun film compatibile disponibile")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Text("Tutti i film compatibili sono in uso, finiti o scaduti")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            mostraAggiungiFilm = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Aggiungi Nuovo Film")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                } else {
                    // Lista film compatibili
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Film Compatibili Disponibili")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        List(filmCompatibili) { pacco in
                            FilmPackRowView(pacco: pacco, modelliDisponibili: viewModel.modelliFilm)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    filmSelezionato = pacco
                                    mostraAlert = true
                                }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Carica Film")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            .alert("Carica Film", isPresented: $mostraAlert) {
                Button("Annulla", role: .cancel) { }
                Button("Carica") {
                    if let pacco = filmSelezionato {
                        viewModel.caricaFilm(pacco, in: fotocamera)
                        dismiss()
                    }
                }
            } message: {
                if let pacco = filmSelezionato {
                    Text("Vuoi caricare il film \(pacco.tipo) \(pacco.modello) con \(pacco.scattiRimanenti) scatti rimanenti in \(fotocamera.nickname)?")
                } else {
                    Text("Seleziona un film da caricare")
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
    }
}

struct FilmPackRowView: View {
    let pacco: FilmPack
    let modelliDisponibili: [FilmPackModel]
    
    var body: some View {
        HStack(spacing: 16) {
            // Indicatore colori del pacco
            FilmPackColorIndicator(tipo: pacco.tipo, modello: pacco.modello, modelliDisponibili: modelliDisponibili, size: 40)
            
            // Informazioni film
            VStack(alignment: .leading, spacing: 4) {
                Text("\(pacco.tipo) • \(pacco.modello)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(pacco.scattiRimanenti) scatti rimanenti")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
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
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CaricaFilmView(
        fotocamera: Camera(
            nickname: "Polaroid 600",
            modello: "Polaroid 600",
            descrizione: "Fotocamera vintage"
        ),
        viewModel: FilmPackViewModel()
    )
}
