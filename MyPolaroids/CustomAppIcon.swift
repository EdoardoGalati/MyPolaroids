import Foundation
import SwiftUI
import Combine

struct CustomAppIcon: Identifiable {
    let id = UUID()
    let name: String
    let displayIconName: String  // Nome per visualizzare l'icona
    let alternateIconName: String  // Nome per il cambio icona dell'app
    let isPremium: Bool
    let isUnlocked: Bool
    
    init(name: String, displayIconName: String, alternateIconName: String, isPremium: Bool = false, isUnlocked: Bool = false) {
        self.name = name
        self.displayIconName = displayIconName
        self.alternateIconName = alternateIconName
        self.isPremium = isPremium
        self.isUnlocked = isUnlocked
    }
}

class CustomAppIconManager: ObservableObject {
    static let shared = CustomAppIconManager()
    
    @Published var customIcons: [CustomAppIcon] = []
    @Published var selectedIconName: String?
    
    init() {
        print("🚀 [CustomAppIcon] Inizializzazione CustomAppIconManager")
        loadCustomIcons()
        selectedIconName = UserDefaults.standard.string(forKey: "selectedCustomAppIcon")
        
        // Debug: verifica stato iniziale
        print("📱 [CustomAppIcon] Icone caricate: \(customIcons.count)")
        print("📱 [CustomAppIcon] Icona selezionata: \(selectedIconName ?? "default")")
        
        if let savedIcon = UserDefaults.standard.string(forKey: "selectedCustomAppIcon") {
            print("💾 [CustomAppIcon] Icona salvata trovata: \(savedIcon)")
        } else {
            print("💾 [CustomAppIcon] Nessuna icona salvata trovata")
        }
    }
    
    private func loadCustomIcons() {
        // Tutte le icone disponibili
        // displayIconName: nome del file per visualizzare l'icona
        // alternateIconName: nome per il cambio icona dell'app
        let allIcons = [
            CustomAppIcon(name: "600", displayIconName: "600-Light", alternateIconName: "600", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "1000", displayIconName: "1000-Light", alternateIconName: "1000", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "1200", displayIconName: "1200-Light", alternateIconName: "1200", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Amigo", displayIconName: "amigo-Light", alternateIconName: "amigo", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Flip", displayIconName: "flip-Light", alternateIconName: "flip", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Go", displayIconName: "go-Light", alternateIconName: "go", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "I-1", displayIconName: "i1-Light", alternateIconName: "i1", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "I-2", displayIconName: "i2-Light", alternateIconName: "i2", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Joycom", displayIconName: "joycom-Light", alternateIconName: "joycom", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Macro", displayIconName: "macro-Light", alternateIconName: "macro", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Now", displayIconName: "now-Light", alternateIconName: "now", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Old", displayIconName: "old-Light", alternateIconName: "old", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "One 600", displayIconName: "one600-Light", alternateIconName: "one600", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Procam", displayIconName: "Procam-Light", alternateIconName: "procam", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "SLR", displayIconName: "slr-Light", alternateIconName: "slr", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "Spectra", displayIconName: "spectra-Light", alternateIconName: "spectra", isPremium: false, isUnlocked: true),
            CustomAppIcon(name: "SX-70", displayIconName: "sx70-Light", alternateIconName: "sx70", isPremium: false, isUnlocked: true)
        ]
        
        customIcons = allIcons
        
        // Debug: verifica che le icone siano caricate
        print("📱 [CustomAppIcon] Icone caricate:")
        for icon in allIcons {
            print("   - \(icon.name): display=\(icon.displayIconName), alternate=\(icon.alternateIconName)")
        }
    }
    
    func changeAppIcon(to iconName: String?) {
        print("🔄 [CustomAppIcon] Cambio icona in corso: \(iconName ?? "default")")
        
        // 1. VERIFICA SUPPORTO DISPOSITIVO
        guard UIApplication.shared.supportsAlternateIcons else {
            print("❌ [CustomAppIcon] Dispositivo non supporta icone alternative")
            return
        }
        
        // 2. VERIFICA AUTORIZZAZIONE CORRENTE
        let currentIcon = UIApplication.shared.alternateIconName
        print("🔄 [CustomAppIcon] Icona corrente: \(currentIcon ?? "default")")
        
        // 3. SE È LA PRIMA VOLTA, FORZA LA RICHIESTA
        if iconName != nil && currentIcon == nil {
            print("🔐 [CustomAppIcon] Prima volta - forzo richiesta autorizzazione...")
            
            // Prima richiedi un'icona diversa per forzare il popup
            UIApplication.shared.setAlternateIconName("600") { [weak self] error in
                if let error = error {
                    print("❌ [CustomAppIcon] Errore autorizzazione: \(error)")
                } else {
                    print("✅ [CustomAppIcon] Autorizzazione concessa!")
                    // Ora cambia all'icona desiderata
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.performIconChange(to: iconName)
                    }
                }
            }
            return
        }
        
        // 4. CAMBIO ICONA NORMALE
        performIconChange(to: iconName)
    }
    
    private func performIconChange(to iconName: String?) {
        print("🎨 [CustomAppIcon] Esecuzione cambio icona: \(iconName ?? "default")")
        
        // DEBUG: Verifica bundle e icone
        if let iconName = iconName {
            let bundle = Bundle.main
            print("📦 [CustomAppIcon] Bundle path: \(bundle.bundlePath)")
            
            // Verifica se l'icona esiste nel bundle
            let iconPath = bundle.path(forResource: iconName, ofType: "png")
            print("🖼️ [CustomAppIcon] Icona \(iconName) nel bundle: \(iconPath != nil)")
            
            if let iconPath = iconPath {
                print("🖼️ [CustomAppIcon] Percorso icona: \(iconPath)")
            }
            
            // Verifica anche se l'icona è accessibile
            if let iconImage = UIImage(named: iconName) {
                print("🖼️ [CustomAppIcon] Icona \(iconName) caricabile: SI")
                print("🖼️ [CustomAppIcon] Dimensioni icona: \(iconImage.size)")
            } else {
                print("❌ [CustomAppIcon] Icona \(iconName) caricabile: NO")
            }
        }
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("❌ [CustomAppIcon] Errore cambio icona: \(error)")
                print("❌ [CustomAppIcon] Dettagli errore: \(error.localizedDescription)")
                print("❌ [CustomAppIcon] Codice errore: \((error as NSError).code)")
                
                // Gestione errori specifici
                if let nsError = error as NSError? {
                    switch nsError.code {
                    case 1001:
                        print("❌ [CustomAppIcon] Errore: Icona non supportata")
                    case 1002:
                        print("❌ [CustomAppIcon] Errore: Icona non trovata")
                    default:
                        print("❌ [CustomAppIcon] Errore sconosciuto: \(nsError.code)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.selectedIconName = iconName
                    UserDefaults.standard.set(iconName, forKey: "selectedCustomAppIcon")
                    UserDefaults.standard.synchronize() // Forza il salvataggio
                    print("✅ [CustomAppIcon] Icona cambiata con successo: \(iconName ?? "default")")
                    
                    // Debug: verifica che sia stata salvata
                    if let savedIcon = UserDefaults.standard.string(forKey: "selectedCustomAppIcon") {
                        print("✅ [CustomAppIcon] Icona salvata in UserDefaults: \(savedIcon)")
                    } else {
                        print("⚠️ [CustomAppIcon] Icona non trovata in UserDefaults")
                    }
                }
            }
        }
    }
    
    func resetToDefaultIcon() {
        changeAppIcon(to: nil)
    }
    
    // Funzione per ottenere l'icona corrente
    func getCurrentIcon() -> CustomAppIcon? {
        if let selectedName = selectedIconName {
            return customIcons.first { $0.alternateIconName == selectedName }
        }
        return nil
    }
}
