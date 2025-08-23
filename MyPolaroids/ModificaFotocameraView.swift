import SwiftUI

struct ModificaFotocameraView: View {
    @Binding var fotocamera: Camera
    @ObservedObject var viewModel: CameraViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var nickname: String
    @State private var modelloSelezionato: String
    @State private var coloreSelezionato: String
    @State private var mostraSelezioneModello: Bool = false
    @State private var colorePersonalizzato: Color = .blue

    
    init(fotocamera: Binding<Camera>, viewModel: CameraViewModel) {
        self._fotocamera = fotocamera
        self.viewModel = viewModel
        
        // Inizializza gli stati con i valori correnti
        self._nickname = State(initialValue: fotocamera.wrappedValue.nickname.isEmpty ? "" : fotocamera.wrappedValue.nickname)
        self._modelloSelezionato = State(initialValue: fotocamera.wrappedValue.modello)
        self._coloreSelezionato = State(initialValue: fotocamera.wrappedValue.coloreIcona)
        
        // Inizializza il colore personalizzato se la fotocamera ne ha già uno
        if fotocamera.wrappedValue.coloreIcona == Camera.colorPickerIdentifier {
            self._colorePersonalizzato = State(initialValue: Camera.ottieniColorePersonalizzato(per: fotocamera.wrappedValue.id) ?? .blue)
        } else {
            self._colorePersonalizzato = State(initialValue: .blue)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 1) {
                        // Header con icona e modello
                        headerSection
                        
                        // Sezione Nickname
                        HStack {
                            Text("Nickname")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            TextField("Enter camera nickname", text: $nickname)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.body)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Sezione Modello
                        HStack {
                            Text("Camera Model")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: { mostraSelezioneModello = true }) {
                                HStack {
                                    Text(modelloSelezionato)
                                        .foregroundColor(.primary)
                                        .font(.body)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Sezione Colore Icona
                        HStack {
                            Text("Icon Color")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                ForEach(Camera.coloriDisponibili, id: \.self) { colore in
                                    Button(action: {
                                        coloreSelezionato = colore
                                    }) {
                                        ColorWheelView(gradient: FilmPackGradient(
                                            stops: [GradientStop(color: FilmPackColors.hexToRGB(colore), location: 0.0)],
                                            type: nil,
                                            startPoint: GradientPoint(x: 0.0, y: 0.0),
                                            endPoint: GradientPoint(x: 1.0, y: 1.0),
                                            center: nil
                                        ), size: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: coloreSelezionato == colore ? 3 : 0)
                                            )
                                            .scaleEffect(coloreSelezionato == colore ? 1.1 : 1.0)
                                            .animation(.easeInOut(duration: 0.2), value: coloreSelezionato)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Color Picker Personalizzato
                                ColorPicker("", selection: $colorePersonalizzato, supportsOpacity: false)
                                    .onChange(of: colorePersonalizzato) { newColor in
                                        // Salva il nuovo colore e seleziona il color picker
                                        Camera.salvaColorePersonalizzato(newColor, per: fotocamera.id)
                                        coloreSelezionato = Camera.colorPickerIdentifier
                                        
                                        // Debug: verifica che il colore sia stato salvato
                                        print("🎨 [EDIT] Colore personalizzato salvato: \(newColor)")
                                        print("🎨 [EDIT] ID fotocamera: \(fotocamera.id)")
                                        if let savedColor = Camera.ottieniColorePersonalizzato(per: fotocamera.id) {
                                            print("🎨 [EDIT] Colore verificato in UserDefaults: \(savedColor)")
                                        } else {
                                            print("❌ [EDIT] ERRORE: Colore non trovato in UserDefaults!")
                                        }
                                    }
                                .labelsHidden()
                                .scaleEffect(1.2)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: coloreSelezionato == Camera.colorPickerIdentifier ? 3 : 0)
                                )
                                .scaleEffect(coloreSelezionato == Camera.colorPickerIdentifier ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: coloreSelezionato)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Edit Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.navigationButton)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        salvaModifiche()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.navigationButton)
                }
            }
        }
        .presentationDetents([.large])
        .sheet(isPresented: $mostraSelezioneModello) {
            SelezioneModelloView(
                modelloSelezionato: $modelloSelezionato,
                modelliDisponibili: viewModel.modelliDisponibili
            )
        }
    }
    
    private var headerSection: some View {
        VStack {
            Spacer(minLength: 0)
            VStack(spacing: 12) {
                // Icona fotocamera
                let iconaModello = viewModel.modelliDisponibili.first(where: { $0.name == modelloSelezionato })?.default_icon ?? "camera.fill"
                
                Image(iconaModello)
                    .font(.system(size: 80))
                    .foregroundColor(
                        coloreSelezionato == Camera.colorPickerIdentifier 
                        ? colorePersonalizzato
                        : Camera.coloreDaNome(coloreSelezionato, fotocameraId: fotocamera.id)
                    )
                
                // Nome modello
                Text(modelloSelezionato)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
    }
    
    private func salvaModifiche() {
        print("🔧 [EDIT] ===== INIZIO SALVAMODIFICHE =====")
        print("🔧 [EDIT] Valori negli stati:")
        print("   - nickname: '\(nickname)'")
        print("   - modelloSelezionato: '\(modelloSelezionato)'")
        print("   - coloreSelezionato: '\(coloreSelezionato)'")
        
        print("🔧 [EDIT] Fotocamera ORIGINALE:")
        print("   - id: \(fotocamera.id)")
        print("   - nickname: '\(fotocamera.nickname)'")
        print("   - modello: '\(fotocamera.modello)'")
        print("   - coloreIcona: '\(fotocamera.coloreIcona)'")
        
        // Creo una NUOVA fotocamera con i valori aggiornati
        print("🔧 [EDIT] Creazione fotocamera aggiornata...")
        var fotocameraAggiornata = fotocamera
        fotocameraAggiornata.nickname = nickname.isEmpty ? "" : nickname
        fotocameraAggiornata.modello = modelloSelezionato
        // Gestisci il colore personalizzato
        if coloreSelezionato == Camera.colorPickerIdentifier {
            // Se è il color picker personalizzato, mantieni l'identificatore
            fotocameraAggiornata.coloreIcona = Camera.colorPickerIdentifier
            // Assicurati che il colore personalizzato sia salvato
            Camera.salvaColorePersonalizzato(colorePersonalizzato, per: fotocamera.id)
            
            // Debug: verifica finale del colore personalizzato
            print("🎨 [EDIT] Colore personalizzato salvato nella fotocamera:")
            print("   - coloreIcona: \(fotocameraAggiornata.coloreIcona)")
            print("   - colorePersonalizzato: \(colorePersonalizzato)")
            if let savedColor = Camera.ottieniColorePersonalizzato(per: fotocamera.id) {
                print("   - Colore verificato in UserDefaults: \(savedColor)")
            } else {
                print("   - ❌ ERRORE: Colore non trovato in UserDefaults!")
            }
        } else {
            // Altrimenti usa il colore normale
            fotocameraAggiornata.coloreIcona = coloreSelezionato
        }
        fotocameraAggiornata.brand = Camera.brandDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
        fotocameraAggiornata.annoProduzione = Camera.annoProduzioneDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
        
        print("🔧 [EDIT] Fotocamera AGGIORNATA:")
        print("   - nickname: '\(fotocameraAggiornata.nickname)'")
        print("   - modello: '\(fotocameraAggiornata.modello)'")
        print("   - brand: '\(fotocameraAggiornata.brand)'")
        print("   - annoProduzione: \(fotocameraAggiornata.annoProduzione)")
        print("   - coloreIcona: '\(fotocameraAggiornata.coloreIcona)'")
        
        print("🔧 [EDIT] Chiamata viewModel.aggiornaFotocamera()")
        viewModel.aggiornaFotocamera(fotocameraAggiornata)
        print("🔧 [EDIT] viewModel.aggiornaFotocamera() completata")
        
        print("🔧 [EDIT] Chiusura vista")
        dismiss()
        print("🔧 [EDIT] ===== FINE SALVAMODIFICHE =====")
    }
}


// MARK: - Vista Selezione Modello
struct SelezioneModelloView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var modelloSelezionato: String
    let modelliDisponibili: [CameraModel]
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barra di ricerca
                searchBar
                
                // Lista modelli
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(modelliFiltrati, id: \.id) { modello in
                            Button(action: {
                                modelloSelezionato = modello.name
                                dismiss()
                            }) {
                                bottoneModello(modello: modello)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Select Camera Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.navigationButton)
                }
            }
        }
    }
    
    // MARK: - Barra di Ricerca
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search models...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(26)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Bottone Modello
    private func bottoneModello(modello: CameraModel) -> some View {
        HStack {
            Image(modello.default_icon)
                .font(.title2)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(modello.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(modello.brand) • \(String(modello.year_introduced))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if modelloSelezionato == modello.name {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.textPrimary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
    }
    
    // MARK: - Computed Properties
    private var modelliFiltrati: [CameraModel] {
        if searchText.isEmpty {
            return modelliDisponibili
        } else {
            return modelliDisponibili.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.model.localizedCaseInsensitiveContains(searchText) ||
                $0.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    let viewModel = CameraViewModel()
    return ModificaFotocameraView(
        fotocamera: .constant(Camera(
            nickname: "My Polaroid",
            modello: "600",
            modelliDisponibili: viewModel.modelliDisponibili
        )),
        viewModel: viewModel
    )
}
