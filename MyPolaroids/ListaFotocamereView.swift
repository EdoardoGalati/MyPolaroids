import SwiftUI
import Combine

struct ListaFotocamereView: View {
    @ObservedObject var viewModel: CameraViewModel
    @Binding var selectedTab: Int
    @State private var mostraAggiungiFotocamera = false
    @State private var mostraModificaFotocamera = false
    @State private var fotocameraDaModificare: Camera?
    @State private var mostraImpostazioni = false
    @State private var animationTrigger = false
    @State private var nuovaCameraId: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con titolo e pulsante aggiungi
            HStack {
                Text("My Cameras")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: { mostraImpostazioni = true }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Button(action: { mostraAggiungiFotocamera = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
                            .background(AppColors.backgroundPrimary)
            
            // Lista fotocamere
            ScrollView {
                
                LazyVStack(spacing: 1) {
                    if viewModel.fotocamere.isEmpty {
                        VStack(spacing: 16) {
                            Image("polaroid.600.fill.symbols")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No cameras")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("Add your first camera to start.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { mostraAggiungiFotocamera = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add First Camera")
                                }
                                .font(.headline)
                                .foregroundColor(AppColors.buttonText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppColors.buttonPrimary)
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 50)
                        .padding(.vertical, 40)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                    } else {
                        LazyVStack(spacing: 0.1) {
                            ForEach(viewModel.fotocamereOrdinate) { fotocamera in
                                NavigationLink(destination: DettagliFotocameraView(fotocamera: fotocamera, viewModel: viewModel, selectedTab: $selectedTab)) {
                                    FotocameraRowView(fotocamera: fotocamera, filmPackViewModel: viewModel.filmPackViewModel!)
                                }
                                .scaleEffect(fotocamera.id == nuovaCameraId && animationTrigger ? 1.02 : 1.0)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(fotocamera.id == nuovaCameraId && animationTrigger ? Color.gray.opacity(0.15) : Color.clear)
                                )
                                .onTapGesture {
                                    print("🔵 TAP su NavigationLink: \(fotocamera.nickname)")
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 80)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationTrigger)
            }
        }
        .onTapGesture {
            print("🟡 TAP su VStack principale")
        }
        .sheet(isPresented: $mostraAggiungiFotocamera) {
            AggiungiFotocameraView(viewModel: viewModel)
        }
        .sheet(isPresented: $mostraImpostazioni) {
            ImpostazioniView()
        }
        .onReceive(viewModel.filmPackViewModel?.$pacchiFilm.eraseToAnyPublisher() ?? Just([FilmPack]()).eraseToAnyPublisher()) { _ in
            // Forza l'aggiornamento quando i pacchi film cambiano
            DispatchQueue.main.async {
                // Forza la ricostruzione della vista
                viewModel.objectWillChange.send()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            // Forza l'aggiornamento quando cambiano le impostazioni di ordinamento
            DispatchQueue.main.async {
                viewModel.objectWillChange.send()
            }
        }
        .sheet(isPresented: $mostraModificaFotocamera) {
            if let fotocamera = fotocameraDaModificare {
                ModificaFotocameraView(
                    fotocamera: Binding(
                        get: { fotocamera },
                        set: { newValue in
                            if let index = viewModel.fotocamere.firstIndex(where: { $0.id == fotocamera.id }) {
                                viewModel.fotocamere[index] = newValue
                            }
                        }
                    ),
                    viewModel: viewModel
                )
            }
        }
    }
    
    struct FotocameraRowView: View {
        let fotocamera: Camera
        @ObservedObject var filmPackViewModel: FilmPackViewModel
        
        var body: some View {
            HStack(spacing: 16) {
                // LATO SINISTRO: Icona e informazioni fotocamera
                HStack(spacing: 8) {
                    // Icona SF Symbol senza sfondo
                    Image(fotocamera.icona)
                        .font(.system(size: 24))
                        .foregroundColor(Camera.coloreDaNome(fotocamera.coloreIcona))
                        .frame(width: 32, height: 32)
                    
                    // Nome e modello
                    VStack(alignment: .leading, spacing: 2) {
                        if !fotocamera.nickname.isEmpty && fotocamera.nickname != fotocamera.modello {
                            // Con nickname custom: nickname nero sopra, modello grigio sotto
                            Text(fotocamera.nickname)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(fotocamera.modello)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            // Senza nickname custom: solo modello in nero
                            Text(fotocamera.modello)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                Spacer()
                
                // LATO DESTRO: Stato fotocamera
                let scattiRimanenti = filmPackViewModel.filmCaricato(in: fotocamera)?.scattiRimanenti ?? 0
                
                // Contenitore con bordino per entrambi gli stati
                Group {
                    if scattiRimanenti == 0 {
                        // Fotocamera senza film
                        Text("Unloaded")
                            .font(.system(size:16))
                            .fontWeight(.regular)
                            .foregroundColor(.secondary)
                            .padding(.vertical,2)
                    } else {
                        // Fotocamera con film
                        if let pacco = filmPackViewModel.filmCaricato(in: fotocamera) {
                            HStack(spacing: 8) {
                                // Numero scatti rimanenti (stesso stile dei film packs)
                                Text("\(scattiRimanenti)")
                                    .font(.system(size:14))
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                // Indicatore colori del pacco
                                FilmPackColorIndicator(tipo: pacco.tipo, modello: pacco.modello, modelliDisponibili: filmPackViewModel.modelliFilm, size:24)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical,28)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
            .padding(.vertical, 0.5)
        }
    }
}

#Preview {
    ListaFotocamereView(viewModel: CameraViewModel(), selectedTab: .constant(0))
}
