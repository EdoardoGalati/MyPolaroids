import SwiftUI
import PhotosUI

struct AggiungiFotocameraView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CameraViewModel
    @StateObject private var permissionManager = PermissionManager()
    
    @State private var nickname = ""
    @State private var modelloSelezionato = ""
    @State private var descrizione = ""
    @State private var mostraSelezioneModello = false
    @State private var coloreSelezionato = "blue"
    
    var body: some View {
        NavigationView {
            Form {
                // Icona grande centrata in alto
                Section {
                    VStack(spacing: 16) {
                        if !modelloSelezionato.isEmpty {
                            let iconaModello = viewModel.modelliDisponibili.first(where: { $0.name == modelloSelezionato })?.default_icon ?? "camera.fill"
                            
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: iconaModello)
                                    .font(.system(size: 60))
                                    .foregroundColor(Camera.coloreDaNome(coloreSelezionato))
                            }
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Text("Anteprima Fotocamera")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                
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
                    ], spacing: 16) {
                        ForEach(Camera.coloriDisponibili, id: \.self) { colore in
                            Button(action: {
                                coloreSelezionato = colore
                            }) {
                                Circle()
                                    .fill(Camera.coloreDaNome(colore))
                                    .frame(width: 50, height: 50)
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
            .navigationTitle("Nuova Fotocamera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        salvaFotocamera()
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
                    Button("Seleziona un modello") {
                        modelloSelezionato = ""
                        mostraSelezioneModello = false
                    }
                    .foregroundColor(.secondary)
                    
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
    
    private func salvaFotocamera() {
        // Usa il nickname se specificato, altrimenti usa il modello
        let nicknameFinale = nickname.isEmpty ? modelloSelezionato : nickname
        
        let fotocamera = viewModel.creaFotocamera(
            nickname: nicknameFinale,
            modello: modelloSelezionato,
            descrizione: descrizione.isEmpty ? nil : descrizione,
            coloreIcona: coloreSelezionato
        )
        
        viewModel.aggiungiFotocamera(fotocamera)
        dismiss()
    }
}

#Preview {
    AggiungiFotocameraView(viewModel: CameraViewModel())
}
