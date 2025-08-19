import SwiftUI

struct FilmPackColors {
    
    // Helper per convertire colori hex in RGBColor
    static func hexToRGB(_ hex: String) -> RGBColor {
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

        return RGBColor(
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0
        )
    }
    
    // Configurazione gradienti per ogni tipo di pacco
    static func gradientePerTipo(_ tipo: String, modello: String, modelliDisponibili: [FilmPackModel] = []) -> FilmPackGradient? {
        // Cerca il gradiente direttamente per nome del modello (più semplice e diretto)
        if let modelloFilm = modelliDisponibili.first(where: { $0.name.lowercased() == modello.lowercased() }) {
            return modelloFilm.gradient
        }
        
        // Se non troviamo il modello, restituiamo nil
        print("⚠️ Modello non trovato: '\(modello)'")
        print("📋 Modelli disponibili: \(modelliDisponibili.map { $0.name })")
        return nil
    }
    

}

// Vista per visualizzare i gradienti dei film pack
struct FilmPackColorIndicator: View {
    let tipo: String
    let modello: String
    let modelliDisponibili: [FilmPackModel]
    let size: CGFloat
    
    init(tipo: String, modello: String, modelliDisponibili: [FilmPackModel] = [], size: CGFloat = 32) {
        self.tipo = tipo
        self.modello = modello
        self.modelliDisponibili = modelliDisponibili
        self.size = size
    }
    
    var body: some View {
        let gradient = FilmPackColors.gradientePerTipo(tipo, modello: modello, modelliDisponibili: modelliDisponibili)
        
        // Debug: stampa informazioni per capire cosa sta succedendo
        let _ = print("🔍 FilmPackColorIndicator - Tipo: \(tipo), Modello: \(modello)")
        let _ = print("🔍 Modelli disponibili count: \(modelliDisponibili.count)")
        let _ = print("🔍 Modelli disponibili IDs: \(modelliDisponibili.map { $0.id })")
        let _ = print("🔍 Gradiente trovato: \(gradient != nil)")
        
        ColorWheelView(gradient: gradient, size: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Indicatori Colori Pacchi Film")
            .font(.title)
            .padding()
        
        HStack(spacing: 20) {
            VStack {
                Text("600 Color")
                FilmPackColorIndicator(tipo: "600", modello: "color")
            }
            
            VStack {
                Text("600 BW")
                FilmPackColorIndicator(tipo: "600", modello: "bw")
            }
            
            VStack {
                Text("i-Type Color")
                FilmPackColorIndicator(tipo: "i-Type", modello: "color")
            }
        }
    }
    .padding()
}
