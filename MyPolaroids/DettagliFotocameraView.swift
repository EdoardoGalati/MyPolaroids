import SwiftUI
import Combine

struct DettagliFotocameraView: View {
    @Environment(\.dismiss) private var dismiss
    let fotocamera: Camera
    @ObservedObject var viewModel: CameraViewModel
    @State private var mostraModifica = false
    @State private var mostraDeleteAlert = false
    @State private var mostraCaricaFilm = false
    @State private var mostraConsumoScatti = false
    @State private var mostraRimuoviFilm = false
    @State private var mostraFilmFinito = false
    @State private var refreshTrigger = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Immagine della fotocamera
                cameraImageSection
                
                // Informazioni principali
                cameraInfoSection
                
                // Statistiche
                cameraStatsSection
                
                // Azioni film
                filmActionsSection
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Dettagli")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { mostraModifica = true }) {
                        Image(systemName: "pencil")
                    }
                    
                    Button(action: { mostraDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $mostraModifica) {
            ModificaFotocameraView(
                fotocamera: Binding(
                    get: { fotocamera },
                    set: { viewModel.aggiornaFotocamera($0) }
                ),
                viewModel: viewModel
            )
        }
        .sheet(isPresented: $mostraCaricaFilm) {
            CaricaFilmView(
                fotocamera: fotocamera, 
                viewModel: viewModel.filmPackViewModel!
            )
            .onDisappear {
                refreshTrigger.toggle()
            }
        }
        .sheet(isPresented: $mostraConsumoScatti) {
            ConsumoScattiView(
                fotocamera: fotocamera, 
                viewModel: viewModel.filmPackViewModel!
            )
            .onDisappear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let pacco = viewModel.filmPackViewModel?.filmCaricato(in: fotocamera),
                       pacco.scattiRimanenti == 0 {
                        mostraFilmFinito = true
                    }
                }
            }
        }
        .alert("Elimina Fotocamera", isPresented: $mostraDeleteAlert) {
            Button("Elimina", role: .destructive) {
                viewModel.rimuoviFotocamera(fotocamera)
                dismiss()
            }
            Button("Annulla", role: .cancel) { }
        } message: {
            Text("Sei sicuro di voler eliminare '\(fotocamera.nickname)'? Questa azione non può essere annullata.")
        }
        .alert("Rimuovi Film", isPresented: $mostraRimuoviFilm) {
            Button("Annulla", role: .cancel) { }
            Button("Rimuovi", role: .destructive) {
                viewModel.filmPackViewModel?.rimuoviFilmDaFotocamera(fotocamera)
            }
        } message: {
            Text("Vuoi rimuovere il film da '\(fotocamera.nickname)'?")
        }
        .alert("Film Completato", isPresented: $mostraFilmFinito) {
            Button("Carica Nuovo Film") {
                mostraCaricaFilm = true
            }
            Button("Lascia Vuota", role: .cancel) { }
        } message: {
            Text("Il film è finito! Vuoi caricare un nuovo film o lasciare la fotocamera vuota?")
        }
        .onReceive(viewModel.filmPackViewModel?.$pacchiFilm.eraseToAnyPublisher() ?? Just([FilmPack]()).eraseToAnyPublisher()) { _ in
            // Forza l'aggiornamento quando i pacchi film cambiano
        }
    }
    
    // MARK: - Sezioni della vista
    
    private var cameraImageSection: some View {
        Group {
            if let fotoData = fotocamera.fotoPersonalizzata {
                if let uiImage = UIImage(data: fotoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                } else {
                    defaultCameraIcon
                }
            } else {
                defaultCameraIcon
            }
        }
    }
    
    private var defaultCameraIcon: some View {
        Image(systemName: fotocamera.icona)
            .font(.system(size: 80))
            .foregroundColor(Camera.coloreDaNome(fotocamera.coloreIcona))
            .padding()
    }
    
    private var cameraInfoSection: some View {
        VStack(spacing: 16) {
            Text(fotocamera.nickname)
                .font(.title)
                .fontWeight(.bold)
            
            Text(fotocamera.modello)
                .font(.title2)
                .foregroundColor(.secondary)
            
            if let descrizione = fotocamera.descrizione, !descrizione.isEmpty {
                Text(descrizione)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
    
    private var cameraStatsSection: some View {
        VStack(spacing: 12) {
            // Capienza fotocamera
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(.blue)
                Text("Capienza:")
                Spacer()
                Text("\(fotocamera.capienza) scatti")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            // Statistiche film se caricato
            if let pacco = viewModel.filmPackViewModel?.filmCaricato(in: fotocamera) {
                filmStatsContent(pacco: pacco)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func filmStatsContent(pacco: FilmPack) -> some View {
        VStack(spacing: 12) {
            // Film caricato
            HStack {
                HStack(spacing: 8) {
                    // Indicatore colori del pacco
                    FilmPackColorIndicator(tipo: pacco.tipo, modello: pacco.modello, modelliDisponibili: viewModel.filmPackViewModel?.modelliFilm ?? [], size: 24)
                    
                    Text("Film caricato:")
                }
                Spacer()
                Text("\(pacco.tipo) • \(pacco.modello)")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            // Scatti rimanenti
            HStack {
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(.orange)
                Text("Scatti rimanenti:")
                Spacer()
                Text(AttributedString("\(pacco.scattiRimanenti)", attributes: AttributeContainer().font(.system(size: 16, weight: .bold))) + AttributedString("/\(pacco.scattiTotali)"))
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            // Data acquisto
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text("Data acquisto:")
                Spacer()
                Text(pacco.dataAcquisto, style: .date)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            // Data scadenza se presente
            if let scadenza = pacco.dataScadenza {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(pacco.isScaduto ? .red : (pacco.isInScadenza ? .orange : .secondary))
                    Text("Scade il:")
                    Spacer()
                    Text(scadenza, style: .date)
                        .fontWeight(.semibold)
                        .foregroundColor(pacco.isScaduto ? .red : (pacco.isInScadenza ? .orange : .secondary))
                }
                .padding(.horizontal)
            }
            
            // Note se presenti
            if let note = pacco.note, !note.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.gray)
                    Text("Note:")
                    Spacer()
                    Text(note)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal)
            }
            
            // Barra di progresso utilizzo
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                    Text("Utilizzo film:")
                    Spacer()
                    Text("\(Int(pacco.percentualeUtilizzo))%")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                ProgressView(value: pacco.percentualeUtilizzo, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.horizontal)
            }
            
            // Compatibilità
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("Compatibilità:")
                Spacer()
                Text("✅ \(fotocamera.modello)")
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
        }
    }
    

    
    private var filmActionsSection: some View {
        Group {
            if viewModel.filmPackViewModel?.filmCaricato(in: fotocamera) != nil {
                // Film caricato - mostra azioni per scattare e rimuovere
                VStack(spacing: 12) {
                    Button(action: { mostraConsumoScatti = true }) {
                        HStack {
                            Image(systemName: "camera.shutter.button")
                            Text("Ho Scattato Foto")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: { mostraRimuoviFilm = true }) {
                        HStack {
                            Image(systemName: "eject")
                            Text("Rimuovi Film")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            } else {
                // Nessun film - mostra azione per caricare
                VStack(spacing: 12) {
                    Button(action: { mostraCaricaFilm = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Carica Film")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

