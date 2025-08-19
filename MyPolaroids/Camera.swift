import Foundation
import SwiftUI
import Combine

struct Camera: Identifiable, Codable {
    let id: UUID
    var nickname: String
    var modello: String
    var brand: String
    var annoProduzione: Int
    var capienza: Int
    var immagine: String
    var icona: String
    var coloreIcona: String
    var fotoPersonalizzata: Data?
    var paccoFilmCaricato: FilmPack?
    var filmType: String?
    var dataAggiunta: Date
    
    init(nickname: String, modello: String, immagine: String? = nil, coloreIcona: String? = nil, modelliDisponibili: [CameraModel] = []) {
        self.id = UUID()
        self.nickname = nickname
        self.modello = modello
        self.brand = Camera.brandDefault(modello: modello, modelliDisponibili: modelliDisponibili)
        self.annoProduzione = Camera.annoProduzioneDefault(modello: modello, modelliDisponibili: modelliDisponibili)
        self.capienza = Camera.calcolaCapienza(modello: modello, modelliDisponibili: modelliDisponibili)
        self.immagine = immagine ?? Camera.immagineDefault(modello: modello, modelliDisponibili: modelliDisponibili)
        self.icona = Camera.iconaDefault(modello: modello, modelliDisponibili: modelliDisponibili)
        self.coloreIcona = coloreIcona ?? Camera.coloreIconaRandom()
        self.fotoPersonalizzata = nil
        self.paccoFilmCaricato = nil
        self.filmType = Camera.filmTypeDefault(modello: modello, modelliDisponibili: modelliDisponibili)
        self.dataAggiunta = Date()
    }
    
    // Calcola la capienza in base al modello
    static func calcolaCapienza(modello: String, modelliDisponibili: [CameraModel]) -> Int {
        if let modelloTrovato = modelliDisponibili.first(where: { $0.name == modello }) {
            return modelloTrovato.capacity
        }
        return 8 // Default
    }
    
    // Restituisce l'immagine di default per il modello
    static func immagineDefault(modello: String, modelliDisponibili: [CameraModel]) -> String {
        if let modelloTrovato = modelliDisponibili.first(where: { $0.name == modello }) {
            return modelloTrovato.default_image
        }
        return "camera.fill" // Default
    }
    
    // Restituisce l'icona di default per il modello
    static func iconaDefault(modello: String, modelliDisponibili: [CameraModel]) -> String {
        if let modelloTrovato = modelliDisponibili.first(where: { $0.name == modello }) {
            return modelloTrovato.default_icon
        }
        return "camera.fill" // Default
    }
    
    // Restituisce il film_type di default per il modello
    static func filmTypeDefault(modello: String, modelliDisponibili: [CameraModel]) -> String? {
        if let modelloTrovato = modelliDisponibili.first(where: { $0.name == modello }) {
            return modelloTrovato.film_type
        }
        return nil
    }
    
    // Restituisce il brand di default per il modello
    static func brandDefault(modello: String, modelliDisponibili: [CameraModel]) -> String {
        if let modelloTrovato = modelliDisponibili.first(where: { $0.name == modello }) {
            return modelloTrovato.brand ?? "Polaroid"
        }
        return "Polaroid"
    }
    
    // Restituisce l'anno di produzione di default per il modello
    static func annoProduzioneDefault(modello: String, modelliDisponibili: [CameraModel]) -> Int {
        if let modelloTrovato = modelliDisponibili.first(where: { $0.name == modello }) {
            return modelloTrovato.year_introduced
        }
        return 1970
    }
    
    // Colori disponibili per le icone (formato hex)
    static let coloriDisponibili = [
        "000", "D60027", "FF8200", "FFB503", "78BE1F", "198CD9"
    ]
    
    // Genera un colore casuale per l'icona
    static func coloreIconaRandom() -> String {
        return coloriDisponibili.randomElement() ?? "000"
    }
    
    // Converte il nome del colore in Color di SwiftUI
    static func coloreDaNome(_ nomeColore: String) -> Color {
        switch nomeColore {
        case "000": 
            // In dark mode, il nero diventa bianco per il contrasto
            return Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.white
                default:
                    return UIColor.black
                }
            })
        case "D60027": return Color(hex: "D60027") // Rosso
        case "FF8200": return Color(hex: "FF8200") // Arancione
        case "FFB503": return Color(hex: "FFB503") // Giallo
        case "78BE1F": return Color(hex: "78BE1F") // Verde
        case "198CD9": return Color(hex: "198CD9") // Blu
        default: 
            // In dark mode, il nero di default diventa bianco per il contrasto
            return Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.white
                default:
                    return UIColor.black
                }
            })
        }
    }
}

// Estensione per creare Color da hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
