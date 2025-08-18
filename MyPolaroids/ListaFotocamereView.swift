import SwiftUI
import Combine

struct ListaFotocamereView: View {
    @ObservedObject var viewModel: CameraViewModel
    @State private var mostraAggiungiFotocamera = false
    @State private var mostraModificaFotocamera = false
    @State private var fotocameraDaModificare: Camera?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header personalizzato
            HStack {
                Text("My Polaroids")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    mostraAggiungiFotocamera = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 24)
            .background(Color(red: 244/255, green: 244/255, blue: 244/255))
                
                // Lista fotocamere
                ScrollView {

                    LazyVStack(spacing: 1) {
                        if viewModel.fotocamere.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("Nessuna fotocamera")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Text("Aggiungi la tua prima fotocamera Polaroid per iniziare la collezione!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                                                                            ForEach(viewModel.fotocamere) { fotocamera in
                            NavigationLink(destination: DettagliFotocameraView(fotocamera: fotocamera, viewModel: viewModel)) {
                                FotocameraRowView(fotocamera: fotocamera, filmPackViewModel: viewModel.filmPackViewModel!)
                            }
                            .onTapGesture {
                                print("🔵 TAP su NavigationLink: \(fotocamera.nickname)")
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture {
            print("🟡 TAP su VStack principale")
        }
        .navigationBarHidden(true) // Nasconde la navigation bar predefinita
            .sheet(isPresented: $mostraAggiungiFotocamera) {
                AggiungiFotocameraView(viewModel: viewModel)
            }
            .onReceive(viewModel.filmPackViewModel?.$pacchiFilm.eraseToAnyPublisher() ?? Just([FilmPack]()).eraseToAnyPublisher()) { _ in
                // Forza l'aggiornamento quando i pacchi film cambiano
                DispatchQueue.main.async {
                    // Forza la ricostruzione della vista
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
    }
    
    struct FotocameraRowView: View {
        let fotocamera: Camera
        @ObservedObject var filmPackViewModel: FilmPackViewModel
        
        var body: some View {
            HStack(spacing: 16) {
                // LATO SINISTRO: Icona e informazioni fotocamera
                HStack(spacing: 8) {
                    // Icona SF Symbol senza sfondo
                    Image(systemName: fotocamera.icona)
                        .font(.system(size: 16))
                        .foregroundColor(Camera.coloreDaNome(fotocamera.coloreIcona))
                        .frame(width: 24, height: 24)
                    
                    // Nome e modello
                    HStack(spacing: 4) {
                        if !fotocamera.nickname.isEmpty && fotocamera.nickname != fotocamera.modello {
                            // Con nickname custom: nickname nero + modello grigio
                            Text(fotocamera.nickname)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("·")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Text(fotocamera.modello)
                                .font(.body)
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
                                    .foregroundColor(.black)
                                
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
            .background(Color.white)
            .cornerRadius(16)
            .padding(.vertical, 0.5)
        }
    }


#Preview {
    ListaFotocamereView(viewModel: CameraViewModel())
}
