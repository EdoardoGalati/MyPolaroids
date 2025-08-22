import SwiftUI
import Combine

struct TipologiePacchiFilmView: View {
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var selectedTab: Int
    @State private var mostraAggiungi = false
    @State private var mostraImpostazioni = false
    
    var body: some View {
        ZStack {
            // Sfondo principale
            AppColors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header personalizzato
                HStack {
                    Text("Film Packs")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { mostraImpostazioni = true }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Button(action: {
                        mostraAggiungi = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                .background(AppColors.backgroundPrimary)
                
                // Lista tipologie che arriva fino a fine pagina
                ScrollView {
                    LazyVStack(spacing: 1) {
                        if viewModel.tipologieRaggruppate.isEmpty {
                            VStack(spacing: 16) {
                                Image("polaroid.film.symbols")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No film packs")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Text("Add your first film pack to start.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: { mostraAggiungi = true }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add First Film Pack")
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
                            ForEach(viewModel.tipologieRaggruppate, id: \.id) { tipologia in
                                NavigationLink(destination: DettagliTipologiaView(tipologia: tipologia, viewModel: viewModel, selectedTab: $selectedTab)) {
                                    TipologiaRowView(tipologia: tipologia, modelliDisponibili: viewModel.modelliFilm)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Spazio extra alla fine della lista
                            Spacer(minLength: 0)
                                .frame(height: 80)
                        }
                    }
                }
            }
            .navigationBarHidden(true) // Nasconde la navigation bar predefinita
            .sheet(isPresented: $mostraAggiungi) {
                AggiungiPaccoFilmView(viewModel: viewModel, fotocamera: nil)
            }
            .sheet(isPresented: $mostraImpostazioni) {
                ImpostazioniView()
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                // Forza l'aggiornamento quando cambiano le impostazioni di ordinamento
                DispatchQueue.main.async {
                    viewModel.objectWillChange.send()
                }
            }
        }
    }
    
    struct TipologiaRowView: View {
        let tipologia: TipologiaPaccoFilm
        let modelliDisponibili: [FilmPackModel]
        
        var body: some View {
            HStack(spacing: 16) {
                // LATO SINISTRO: Indicatore colori e informazioni tipologia
                HStack(spacing: 8) {
                    // Indicatore colori del pacco film
                    FilmPackColorIndicator(tipo: tipologia.tipo, modello: tipologia.modello, modelliDisponibili: modelliDisponibili, size: 24)
                    
                    // Tipo e modello
                    HStack(spacing: 4) {
                        Text(tipologia.tipo)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("·")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text(tipologia.modello)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // LATO DESTRO: Numero di pacchi
                                        Text("\(tipologia.conteggioTotale)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(16)
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
    
}
#Preview {
    TipologiePacchiFilmView(viewModel: FilmPackViewModel(), selectedTab: .constant(0))
}
