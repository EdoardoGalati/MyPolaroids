import SwiftUI

struct ConsumoScattiView: View {
    let fotocamera: Camera
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var selectedTab: Int
    @State private var numeroScatti: Int
    @Environment(\.dismiss) private var dismiss
    
    init(fotocamera: Camera, viewModel: FilmPackViewModel, selectedTab: Binding<Int>) {
        self.fotocamera = fotocamera
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        
        // Inizializza numeroScatti sempre a 1 indipendentemente da scatti
        self._numeroScatti = State(initialValue: 1)
    }
    
    var scattiDisponibili: Int {
        viewModel.filmCaricato(in: fotocamera)?.scattiRimanenti ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Selezione numero scatti
            VStack(spacing: 0) {
                if scattiDisponibili > 0 {
                    Picker("Number of photos", selection: $numeroScatti) {
                        ForEach(1...scattiDisponibili, id: \.self) { numero in
                            Text("\(numero)")
                                .font(.system(size: 24, weight: .medium))
                                .frame(height: 44)
                                .tag(numero)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: .infinity)
                    .clipped()
                } else {
                    // Nessuno scatto disponibile
                    VStack {
                        Text("No photos available")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .frame(maxHeight: .infinity)
            
            // Pulsante conferma
            Button(action: {
                guard scattiDisponibili > 0 else { return }
                
                // Salva le informazioni del pacco prima di consumarlo
                let paccoPrima = viewModel.filmCaricato(in: fotocamera)
                let tipoPacco = paccoPrima?.tipo ?? ""
                let modelliPacco = paccoPrima?.modello ?? ""
                
                let filmFinito = viewModel.consumaScatti(numeroScatti, da: fotocamera)
                if filmFinito {
                    // Film finito - controlla se ci sono ancora pacchi dello stesso tipo
                    let pacchiRimanenti = viewModel.pacchiFilm.filter { 
                        $0.tipo == tipoPacco && $0.modello == modelliPacco 
                    }
                    
                    // Se non ci sono più pacchi di questo tipo, torna alla home
                    if pacchiRimanenti.isEmpty {
                        selectedTab = 0
                    }
                }
                dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Confirm \(numeroScatti) Photo\(numeroScatti == 1 ? "" : "s")")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.black)
                .cornerRadius(16)
            }
            .disabled(scattiDisponibili == 0)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Pulsante annulla
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxHeight: .infinity)
        .background(Color(hex: "f4f4f4"))
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
    }
}

#Preview {
    ConsumoScattiView(
        fotocamera: Camera(
            nickname: "Fotocamera temporanea",
            modello: "Polaroid 600"
        ),
        viewModel: FilmPackViewModel(),
        selectedTab: .constant(0)
    )
}
