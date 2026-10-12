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
    /// Returns the gradient of a film model by name. Names are normalised so that
    /// packs saved under older catalog names ("Black & White", "Color Black Frame",
    /// "Color i-Type Black Frame Film") still match the current ones ("B&W", "Black Frame").
    static func gradientePerTipo(_ tipo: String, modello: String, modelliDisponibili: [FilmPackModel] = []) -> FilmPackGradient? {
        let sameType = modelliDisponibili.filter { $0.film_type == nil || $0.film_type == tipo }
        let pool = sameType.isEmpty ? modelliDisponibili : sameType
        let wanted = normalised(modello)
        if let exact = pool.first(where: { $0.name.lowercased() == modello.lowercased() }) {
            return exact.gradient
        }
        if let loose = pool.first(where: { normalised($0.name) == wanted })
            ?? modelliDisponibili.first(where: { normalised($0.name) == wanted }) {
            return loose.gradient
        }
        return nil
    }

    private static func normalised(_ name: String) -> String {
        var s = name.lowercased()
        for token in ["polaroid", "film", "edition", "double pack", "i-type", "sx-70", "600", "go", "8x10", "4x5", "spectra"] {
            s = s.replacingOccurrences(of: token, with: " ")
        }
        s = s.replacingOccurrences(of: "black & white", with: "bw")
        s = s.replacingOccurrences(of: "black and white", with: "bw")
        s = s.replacingOccurrences(of: "b&w", with: "bw")
        s = s.replacingOccurrences(of: "colour", with: "color")
        let parts = s.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init)
        // "color" alone is the standard film; otherwise drop the "color" prefix of variants.
        if parts == ["color"] { return "color" }
        return parts.filter { $0 != "color" }.joined(separator: " ")
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
