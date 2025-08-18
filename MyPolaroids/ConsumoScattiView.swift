import SwiftUI

struct ConsumoScattiView: View {
    let fotocamera: Camera
    @ObservedObject var viewModel: FilmPackViewModel
    @State private var numeroScatti = 1
    @Environment(\.dismiss) private var dismiss
    
    var scattiDisponibili: Int {
        viewModel.filmCaricato(in: fotocamera)?.scattiRimanenti ?? 0
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header con informazioni fotocamera e film
                VStack(spacing: 16) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text(fotocamera.nickname)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let pacco = viewModel.filmCaricato(in: fotocamera) {
                        VStack(spacing: 8) {
                            Text("\(pacco.tipo) • \(pacco.modello)")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text("\(pacco.scattiRimanenti) scatti rimanenti")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Selezione numero scatti
                VStack(spacing: 16) {
                    Text("Quante foto hai scattato?")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Picker("Numero scatti", selection: $numeroScatti) {
                        ForEach(1...scattiDisponibili, id: \.self) { numero in
                            Text("\(numero)").tag(numero)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    
                    Text("Hai selezionato \(numeroScatti) scatto\(numeroScatti == 1 ? "" : "i")")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Pulsante conferma
                Button(action: {
                    let filmFinito = viewModel.consumaScatti(numeroScatti, da: fotocamera)
                    if filmFinito {
                        // Film finito - mostra alert
                        // Questo verrà gestito dalla vista padre
                    }
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Conferma \(numeroScatti) Scatto\(numeroScatti == 1 ? "" : "i")")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(scattiDisponibili == 0)
            }
            .padding()
            .navigationTitle("Consumo Scatti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ConsumoScattiView(
        fotocamera: Camera(
            nickname: "Polaroid 600",
            modello: "Polaroid 600",
            descrizione: "Fotocamera vintage"
        ),
        viewModel: FilmPackViewModel()
    )
}
