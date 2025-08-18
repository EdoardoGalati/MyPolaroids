import Foundation
import SwiftUI

struct Camera: Identifiable, Codable {
    let id: UUID
    var nickname: String
    var modello: String
    var descrizione: String?
    var capienza: Int
    var immagine: String
    var icona: String
    var coloreIcona: String
    var fotoPersonalizzata: Data?
    var paccoFilmCaricato: FilmPack?
    
    init(nickname: String, modello: String, descrizione: String? = nil, immagine: String? = nil, coloreIcona: String? = nil, modelliDisponibili: [CameraModel] = []) {
        self.id = UUID()
        self.nickname = nickname
        self.modello = modello
        self.descrizione = descrizione
        self.capienza = Camera.calcolaCapienza(modello: modello, modelliDisponibili: modelliDisponibili)
        self.immagine = immagine ?? Camera.immagineDefault(modello: modello, modelliDisponibili: modelliDisponibili)
        self.icona = Camera.iconaDefault(modello: modello, modelliDisponibili: modelliDisponibili)
        self.coloreIcona = coloreIcona ?? Camera.coloreIconaRandom()
        self.fotoPersonalizzata = nil
        self.paccoFilmCaricato = nil
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
    
    // Colori disponibili per le icone (ridotti a 6)
    static let coloriDisponibili = [
        "red", "blue", "green", "purple", "orange", "teal"
    ]
    
    // Genera un colore casuale per l'icona
    static func coloreIconaRandom() -> String {
        return coloriDisponibili.randomElement() ?? "blue"
    }
    
    // Converte il nome del colore in Color di SwiftUI
    static func coloreDaNome(_ nomeColore: String) -> Color {
        switch nomeColore.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "indigo": return .indigo
        case "teal": return .teal
        case "mint": return .mint
        case "cyan": return .cyan
        case "brown": return .brown
        case "gray": return .gray
        default: return .blue
        }
    }
}
