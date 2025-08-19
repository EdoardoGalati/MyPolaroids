import SwiftUI
import Combine

struct DettagliFotocameraView: View {
    @Environment(\.dismiss) private var dismiss
    let fotocamera: Camera
    @ObservedObject var viewModel: CameraViewModel
    @Binding var selectedTab: Int
    @State private var mostraModifica = false
    @State private var mostraDeleteAlert = false
    @State private var mostraCaricaFilm = false
    @State private var mostraConsumoScatti = false
    @State private var mostraRimuoviFilm = false
    @State private var mostraFilmFinito = false
    @State private var refreshTrigger = false
    @State private var mostraScartaPacco = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            // Header con icona e informazioni base
            headerSection
            
            // Contenuto principale in base allo stato
            if let pacco = viewModel.filmPackViewModel?.filmCaricato(in: fotocamera) {
                // Camera LOADED
                loadedContentSection(pacco: pacco)
            } else {
                // Camera UNLOADED
                unloadedContentSection
            }
        }
        .background(AppColors.backgroundPrimary)
        .navigationTitle("Camera Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { mostraModifica = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: { mostraDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .sheet(isPresented: $mostraModifica) {
            ModificaFotocameraView(
                fotocamera: Binding(
                    get: { fotocamera },
                    set: { newValue in
                        // Aggiorna la fotocamera nell'array del viewModel
                        if let index = viewModel.fotocamere.firstIndex(where: { $0.id == fotocamera.id }) {
                            viewModel.fotocamere[index] = newValue
                        }
                    }
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
                viewModel: viewModel.filmPackViewModel!,
                selectedTab: $selectedTab
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
        .alert("Delete Camera", isPresented: $mostraDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.rimuoviFotocamera(fotocamera)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete '\(fotocamera.nickname)'? This action cannot be undone.")
        }
        .alert("Remove Film", isPresented: $mostraRimuoviFilm) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                // Controlla se questo è l'ultimo film del tipo
                if let pacco = viewModel.filmPackViewModel?.filmCaricato(in: fotocamera) {
                    let tipoPacco = pacco.tipo
                    let modelliPacco = pacco.modello
                    
                    // Rimuovi il film
                    viewModel.filmPackViewModel?.rimuoviFilmDaFotocamera(fotocamera)
                    
                    // Controlla se ci sono ancora pacchi dello stesso tipo e modello
                    let pacchiRimanenti = viewModel.filmPackViewModel?.pacchiFilm.filter { 
                        $0.tipo == tipoPacco && $0.modello == modelliPacco 
                    } ?? []
                    
                    // Se non ci sono più pacchi di questo tipo, torna alla home
                    if pacchiRimanenti.isEmpty {
                        selectedTab = 0
                    }
                }
            }
        } message: {
            Text("Do you want to remove the film from '\(fotocamera.nickname)'?")
        }
        .alert("Film Completed", isPresented: $mostraFilmFinito) {
            Button("Load New Film") {
                mostraCaricaFilm = true
            }
            Button("Leave Empty", role: .cancel) { }
        } message: {
            Text("The film is finished! Do you want to load a new film or leave the camera empty?")
        }
        .alert("Discard Film Pack", isPresented: $mostraScartaPacco) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                // Controlla se questo è l'ultimo film del tipo
                if let pacco = viewModel.filmPackViewModel?.filmCaricato(in: fotocamera) {
                    let tipoPacco = pacco.tipo
                    let modelliPacco = pacco.modello
                    
                    // Rimuovi il film
                    viewModel.filmPackViewModel?.rimuoviFilmDaFotocamera(fotocamera)
                    
                    // Controlla se ci sono ancora pacchi dello stesso tipo e modello
                    let pacchiRimanenti = viewModel.filmPackViewModel?.pacchiFilm.filter { 
                        $0.tipo == tipoPacco && $0.modello == modelliPacco 
                    } ?? []
                    
                    // Se non ci sono più pacchi di questo tipo, torna alla home
                    if pacchiRimanenti.isEmpty {
                        selectedTab = 0
                    }
                }
            }
        } message: {
            Text("Do you want to discard the film pack from '\(fotocamera.nickname)'?")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack {
            Spacer(minLength: 0)
            VStack(spacing: 12) {
                // Icona fotocamera
                Image(fotocamera.icona)
                    .font(.system(size: 96))
                    .foregroundColor(Camera.coloreDaNome(fotocamera.coloreIcona))
                // Nome e nickname
                if fotocamera.nickname.isEmpty || fotocamera.nickname == fotocamera.modello {
                    Text(fotocamera.modello)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                } else {
                    VStack(spacing: 4) {
                        Text(fotocamera.nickname)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text(fotocamera.modello)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
    }
    
    // MARK: - Content Section (Loaded)
    private func loadedContentSection(pacco: FilmPack) -> some View {
        VStack(spacing: 1) {
            // Brand
            HStack {
                Text("Brand:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(fotocamera.brand)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Anno
            HStack {
                Text("Year:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(fotocamera.annoProduzione))
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Compatibilità
            HStack {
                Text("Compatibility:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(fotocamera.filmType ?? "Unknown")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Tipo film e pulsante discard
            HStack {
                HStack(spacing: 12) {
                    Text("Status:")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(pacco.tipo) • \(pacco.modello)")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    // Pallino del colore del film
                    FilmPackColorIndicator(
                        tipo: pacco.tipo,
                        modello: pacco.modello,
                        modelliDisponibili: viewModel.filmPackViewModel?.modelliFilm ?? [],
                        size: 20
                    )
                }
                
                Spacer()
                
                Button(action: { mostraScartaPacco = true }) {
                    Text("Discard")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Foto rimaste
            HStack {
                Text("Photos Left:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Numero scatti rimanenti in rettangolo stile home
                Text("\(pacco.scattiRimanenti)")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.separator, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Pulsante I Took a Photo
            Button(action: { scattaFoto() }) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18))
                    Text("I Took a Photo")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(AppColors.buttonText)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(AppColors.buttonPrimary)
                .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Content Section (Unloaded)
    private var unloadedContentSection: some View {
        VStack(spacing: 1) {
            // Brand
            HStack {
                Text("Brand:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(fotocamera.brand)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Anno
            HStack {
                Text("Year:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(fotocamera.annoProduzione))
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Compatibilità
            HStack {
                Text("Compatibility:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(fotocamera.filmType ?? "Unknown")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Tipo film e pulsante load
            HStack {
                HStack(spacing: 8) {
                    Text("Status:")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("No film loaded")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { mostraCaricaFilm = true }) {
                    Text("Load")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.buttonText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.buttonPrimary)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            
            // Pulsante I Took a Photo (disabilitato)
            Button(action: {}) {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18))
                    Text("I Took a Photo")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(16)
            }
            .disabled(true)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Actions
    private func scattaFoto() {
        guard let pacco = viewModel.filmPackViewModel?.filmCaricato(in: fotocamera),
              pacco.scattiRimanenti > 0 else { return }
        // Mostra alert di conferma (ConsumoScattiView)
        mostraConsumoScatti = true
    }
    
    private func rimuoviFilm() {
        // Controlla se questo è l'ultimo film del tipo
        if let pacco = viewModel.filmPackViewModel?.filmCaricato(in: fotocamera) {
            let tipoPacco = pacco.tipo
            let modelliPacco = pacco.modello
            
            // Rimuovi il film
            viewModel.filmPackViewModel?.rimuoviFilmDaFotocamera(fotocamera)
            
            // Controlla se ci sono ancora pacchi dello stesso tipo e modello
            let pacchiRimanenti = viewModel.filmPackViewModel?.pacchiFilm.filter { 
                $0.tipo == tipoPacco && $0.modello == modelliPacco 
            } ?? []
            
            // Se non ci sono più pacchi di questo tipo, torna alla home
            if pacchiRimanenti.isEmpty {
                selectedTab = 0
            }
        }
    }
}

#Preview {
    DettagliFotocameraView(
        fotocamera: Camera(
            nickname: "My Camera",
            modello: "Polaroid 600",
            coloreIcona: "000"
        ),
        viewModel: CameraViewModel(),
        selectedTab: .constant(0)
    )
}

