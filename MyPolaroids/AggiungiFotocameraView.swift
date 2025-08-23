import SwiftUI

struct AggiungiFotocameraView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CameraViewModel
    
    @State private var nickname: String = ""
    @State private var coloreSelezionato: String = "000"
    @State private var searchText = ""
    @State private var mostraPersonalizzazione = false
    @State private var modelloSelezionato: CameraModel?
    
    // Colori disponibili per le icone
    private let coloriDisponibili = ["000", "D60027", "FF8200", "FFB503", "78BE1F", "198CD9"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Barra di ricerca
                searchBar
                
                // Lista fotocamere
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(fotocamereFiltrate, id: \.id) { modello in
                            Button(action: {
                                modelloSelezionato = modello
                                mostraPersonalizzazione = true
                            }) {
                                bottoneFotocamera(modello: modello)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Add Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.navigationButton)
                }
            }
            .navigationDestination(isPresented: $mostraPersonalizzazione) {
                if let modello = modelloSelezionato {
                    PersonalizzazioneView(
                        modello: modello,
                        viewModel: viewModel,
                        onSave: {
                            // Torna alla vista principale dopo aver salvato
                            mostraPersonalizzazione = false
                            dismiss()
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Barra di Ricerca
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search cameras...", text: $searchText)
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
    
    // MARK: - Bottone Fotocamera
    private func bottoneFotocamera(modello: CameraModel) -> some View {
        HStack {
            Image(modello.default_icon)
                .font(.title2)
                .foregroundColor(AppColors.textPrimary)
            
            Text(modello.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
    }
    
    // MARK: - Computed Properties
    private var fotocamereFiltrate: [CameraModel] {
        if searchText.isEmpty {
            return viewModel.modelliDisponibili
        } else {
            return viewModel.modelliDisponibili.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.model.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Vista Personalizzazione
struct PersonalizzazioneView: View {
    @Environment(\.dismiss) private var dismiss
    let modello: CameraModel
    let viewModel: CameraViewModel
    let onSave: () -> Void
    
    @State private var nickname: String = ""
    @State private var coloreSelezionato: String = "000"

    
    private let coloriDisponibili = ["000", "D60027", "FF8200", "FFB503", "78BE1F", "198CD9"]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 1) {
                    // Header con icona e nome
                    headerConIcona
                    
                    // Nickname
                    sezioneNickname
                    
                    // Icon Color
                    sezioneIconColor
                    
                    // Brand
                    sezioneBrand
                    
                    // Anno
                    sezioneAnno
                }
                .padding(.vertical, 16)
            }
        }
        .background(AppColors.backgroundPrimary)
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    salvaFotocamera()
                }
                .fontWeight(.semibold)
                .foregroundColor(AppColors.navigationButton)
            }
        }

    }
    
    // MARK: - Header con Icona
    private var headerConIcona: some View {
        VStack {
            Spacer(minLength: 0)
            VStack(spacing: 12) {
                // Icona fotocamera
                Image(modello.default_icon)
                    .font(.system(size: 80))
                    .foregroundColor(
                        coloreSelezionato == Camera.colorPickerIdentifier 
                        ? Camera.ottieniColorePersonalizzato(per: UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()) ?? .blue
                        : Camera.coloreDaNome(coloreSelezionato, fotocameraId: nil)
                    )
                
                // Nome modello
                Text(modello.name)
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
    
    private var sezioneNickname: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nickname")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                TextField("Your camera's nickname (optional)", text: $nickname)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
    }
    
    private var sezioneIconColor: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Icon Color")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(coloriDisponibili, id: \.self) { colore in
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
                                        .stroke(AppColors.accentPrimary, lineWidth: coloreSelezionato == colore ? 2 : 0)
                                )
                        }
                    }
                    
                    // Color Picker Personalizzato
                    ColorPicker("", selection: Binding(
                        get: {
                            // Se è selezionato il color picker, mostra il colore salvato o blu di default
                            if coloreSelezionato == Camera.colorPickerIdentifier {
                                // Per le nuove fotocamere, usa un ID temporaneo basato sul modello
                                let tempId = UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()
                                return Camera.ottieniColorePersonalizzato(per: tempId) ?? .blue
                            }
                            return .blue
                        },
                        set: { newColor in
                            // Salva il nuovo colore e seleziona il color picker
                            // Per le nuove fotocamere, usa un ID temporaneo basato sul modello
                            let tempId = UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()
                            Camera.salvaColorePersonalizzato(newColor, per: tempId)
                            coloreSelezionato = Camera.colorPickerIdentifier
                        }
                    ), supportsOpacity: false)
                    .labelsHidden()
                    .scaleEffect(1.2)
                    .overlay(
                        Circle()
                            .stroke(AppColors.accentPrimary, lineWidth: coloreSelezionato == Camera.colorPickerIdentifier ? 2 : 0)
                    )
                    .scaleEffect(coloreSelezionato == Camera.colorPickerIdentifier ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: coloreSelezionato)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
    }
    
    private var sezioneBrand: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Brand")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(modello.brand)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
    }
    
    private var sezioneAnno: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Year")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(modello.year_introduced))
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(AppColors.backgroundSecondary)
        .cornerRadius(16)
    }
    
    private func salvaFotocamera() {
        print("🔧 [PersonalizzazioneView] ===== INIZIO SALVAFOTOCAMERA =====")
        print("🔧 [PersonalizzazioneView] Modello: \(modello.name)")
        print("🔧 [PersonalizzazioneView] Nickname: '\(nickname)'")
        print("🔧 [PersonalizzazioneView] Colore: '\(coloreSelezionato)'")
        
        // Gestisci il colore personalizzato
        let coloreFinale: String
        if coloreSelezionato == Camera.colorPickerIdentifier {
            // Se è il color picker personalizzato, usa l'identificatore
            coloreFinale = Camera.colorPickerIdentifier
        } else {
            // Altrimenti usa il colore normale
            coloreFinale = coloreSelezionato
        }
        
        // Crea la fotocamera
        let fotocamera = Camera(
            nickname: nickname.isEmpty ? "" : nickname,
            modello: modello.name,
            coloreIcona: coloreFinale,
            modelliDisponibili: viewModel.modelliDisponibili
        )
        
        // Se è un colore personalizzato, trasferiscilo dalla chiave temporanea alla fotocamera finale
        if coloreSelezionato == Camera.colorPickerIdentifier {
            let tempId = UUID(uuidString: "00000000-0000-0000-0000-000000000000") ?? UUID()
            if let customColor = Camera.ottieniColorePersonalizzato(per: tempId) {
                Camera.salvaColorePersonalizzato(customColor, per: fotocamera.id)
                // Rimuovi la chiave temporanea
                UserDefaults.standard.removeObject(forKey: "customCameraColor_\(tempId.uuidString)")
            }
        }
        
        print("🔧 [PersonalizzazioneView] Fotocamera creata con ID: \(fotocamera.id)")
        
        // Aggiungi la fotocamera
        viewModel.aggiungiFotocamera(fotocamera)
        
        print("🔧 [PersonalizzazioneView] viewModel.aggiungiFotocamera() completata")
        
        // Torna alla vista principale usando onSave callback
        print("🔧 [PersonalizzazioneView] Chiamata onSave()")
        onSave()
        
        print("🔧 [PersonalizzazioneView] ===== FINE SALVAFOTOCAMERA =====")
    }
}

// MARK: - Preview
#Preview {
    AggiungiFotocameraView(viewModel: CameraViewModel())
}
