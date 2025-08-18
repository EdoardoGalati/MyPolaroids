import SwiftUI
import PhotosUI

struct ModificaFotocameraView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CameraViewModel
    @Binding var fotocamera: Camera
    @StateObject private var permissionManager = PermissionManager()
    
    @State private var nickname: String
    @State private var modelloSelezionato: String
    @State private var descrizione: String
    @State private var mostraSelezioneModello = false
    @State private var coloreSelezionato: String
    
    init(fotocamera: Binding<Camera>, viewModel: CameraViewModel) {
        self._fotocamera = fotocamera
        self.viewModel = viewModel
        self._nickname = State(initialValue: fotocamera.wrappedValue.nickname)
        self._modelloSelezionato = State(initialValue: fotocamera.wrappedValue.modello)
        self._descrizione = State(initialValue: fotocamera.wrappedValue.descrizione ?? "")
        self._coloreSelezionato = State(initialValue: fotocamera.wrappedValue.coloreIcona)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informazioni Fotocamera")) {
                    TextField("Nickname (opzionale, usa il modello se vuoto)", text: $nickname)
                    
                    HStack {
                        Text("Modello")
                        Spacer()
                        Button(action: {
                            mostraSelezioneModello = true
                        }) {
                            HStack {
                                Text(modelloSelezionato.isEmpty ? "Seleziona un modello" : modelloSelezionato)
                                    .foregroundColor(modelloSelezionato.isEmpty ? .secondary : .primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    .contentShape(Rectangle())
                    
                    TextField("Descrizione (opzionale)", text: $descrizione)
                }
                
                Section(header: Text("Colore Icona")) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(Camera.coloriDisponibili, id: \.self) { colore in
                            Button(action: {
                                coloreSelezionato = colore
                            }) {
                                Circle()
                                    .fill(Camera.coloreDaNome(colore))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: coloreSelezionato == colore ? 3 : 1)
                                    )
                                    .scaleEffect(coloreSelezionato == colore ? 1.1 : 1.0)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Capienza")) {
                    HStack {
                        Text("Scatti disponibili:")
                        Spacer()
                        Text("\(Camera.calcolaCapienza(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili))")
                            .foregroundColor(.secondary)
                    }
                }
                

            }
            .navigationTitle("Modifica Fotocamera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        salvaModifiche()
                    }
                    .disabled(modelloSelezionato.isEmpty)
                }
            }

            .sheet(isPresented: $mostraSelezioneModello) {
                selezioneModelloSheet
            }
        }
    }
    
    private var selezioneModelloSheet: some View {
        NavigationView {
            List {
                Section(header: Text("Seleziona Modello")) {
                    ForEach(viewModel.modelliDisponibili, id: \.id) { modello in
                        Button(action: {
                            modelloSelezionato = modello.name
                            mostraSelezioneModello = false
                        }) {
                            HStack {
                                Text(modello.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if modelloSelezionato == modello.name {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Modello Fotocamera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fatto") {
                        mostraSelezioneModello = false
                    }
                }
            }
        }
    }
    
    private func salvaModifiche() {
        // Usa il nickname se specificato, altrimenti usa il modello
        let nicknameFinale = nickname.isEmpty ? modelloSelezionato : nickname
        
        fotocamera.nickname = nicknameFinale
        fotocamera.modello = modelloSelezionato
        fotocamera.descrizione = descrizione.isEmpty ? nil : descrizione
        fotocamera.capienza = Camera.calcolaCapienza(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
        fotocamera.immagine = Camera.immagineDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
        fotocamera.icona = Camera.iconaDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
        fotocamera.coloreIcona = coloreSelezionato
        
        viewModel.aggiornaFotocamera(fotocamera)
        dismiss()
    }
}

#Preview {
    ModificaFotocameraView(
        fotocamera: .constant(Camera(
            nickname: "La Mia Polaroid",
            modello: "Polaroid 600",
            descrizione: "La mia prima fotocamera Polaroid!",
            modelliDisponibili: []
        )),
        viewModel: CameraViewModel()
    )
}
