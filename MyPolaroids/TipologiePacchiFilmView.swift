import SwiftUI

struct TipologiePacchiFilmView: View {
    @ObservedObject var viewModel: FilmPackViewModel
    @State private var mostraAggiungi = false
    
    var body: some View {
        ZStack {
            // Sfondo principale
            Color(red: 244/255, green: 244/255, blue: 244/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header personalizzato
                HStack {
                    Text("Film Packs")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        mostraAggiungi = true
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
                
                // Lista tipologie
                ScrollView {
                    LazyVStack(spacing: 1) {
                        if viewModel.tipologieRaggruppate.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "film.stack")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("Nessun pacco film")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Text("Aggiungi il tuo primo pacco film per iniziare la tua collezione")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(viewModel.tipologieRaggruppate.indices, id: \.self) { index in
                                let tipologia = viewModel.tipologieRaggruppate[index]
                                NavigationLink(destination: DettagliTipologiaView(tipologia: tipologia, viewModel: viewModel)) {
                                    TipologiaRowView(tipologia: tipologia, modelliDisponibili: viewModel.modelliFilm)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true) // Nasconde la navigation bar predefinita
            .sheet(isPresented: $mostraAggiungi) {
                AggiungiPaccoFilmView(viewModel: viewModel)
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
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
            .background(Color.white)
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
    TipologiePacchiFilmView(viewModel: FilmPackViewModel())
}
