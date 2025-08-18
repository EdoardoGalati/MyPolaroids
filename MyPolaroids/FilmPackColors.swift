import SwiftUI

struct FilmPackColors {
    
    // Colori standard per i pacchi film
    static let coloriPolaroid: [String: Color] = [
        "bianco": Color.white,
        "nero": Color.black,
        "grigio": Color.gray,
        "grigioScuro": Color(red: 0.3, green: 0.3, blue: 0.3),
        "rosso": Color.red,
        "blu": Color.blue,
        "verde": Color.green,
        "giallo": Color.yellow,
        "arancione": Color.orange,
        "rosa": Color.pink,
        "viola": Color.purple,
        "marrone": Color.brown,
        "ciano": Color.cyan,
        "magenta": Color.pink,
        "beige": Color(red: 0.96, green: 0.96, blue: 0.86),
        "crema": Color(red: 1.0, green: 0.99, blue: 0.82),
        "argento": Color(red: 0.75, green: 0.75, blue: 0.75),
        "oro": Color(red: 1.0, green: 0.84, blue: 0.0)
    ]
    
    // Configurazione colori per ogni tipo di pacco
    static func coloriPerTipo(_ tipo: String, modello: String, modelliDisponibili: [FilmPackModel] = []) -> [Color] {
        // Se abbiamo i modelli disponibili, cerca il colore nel JSON
        if let modelloFilm = modelliDisponibili.first(where: { $0.id.lowercased() == modello.lowercased() }) {
            return modelloFilm.colors.compactMap { coloreNome in
                coloriPolaroid[coloreNome.lowercased()]
            }
        }
        
        // Fallback ai colori hardcoded se non troviamo il modello
        switch tipo {
        case "600":
            return coloriPerModello600(modello)
        case "i-Type":
            return coloriPerModelloIType(modello)
        case "SX-70":
            return coloriPerModelloSX70(modello)
        case "Go":
            return coloriPerModelloGo(modello)
        case "Spectra":
            return coloriPerModelloSpectra(modello)
        case "8x10":
            return coloriPerModello8x10(modello)
        case "4x5":
            return coloriPerModello4x5(modello)
        default:
            return [coloriPolaroid["grigio"]!]
        }
    }
    
    // Colori per pacco 600
    private static func coloriPerModello600(_ modello: String) -> [Color] {
        switch modello.lowercased() {
        case "color":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["blu"]!, coloriPolaroid["giallo"]!]
        case "bw", "black & white":
            return [coloriPolaroid["grigioScuro"]!, coloriPolaroid["nero"]!]
        case "duochrome":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["giallo"]!]
        case "metallic":
            return [coloriPolaroid["argento"]!, coloriPolaroid["oro"]!]
        case "round":
            return [coloriPolaroid["blu"]!, coloriPolaroid["verde"]!, coloriPolaroid["giallo"]!]
        default:
            return [coloriPolaroid["grigio"]!, coloriPolaroid["nero"]!]
        }
    }
    
    // Colori per pacco i-Type
    private static func coloriPerModelloIType(_ modello: String) -> [Color] {
        switch modello.lowercased() {
        case "color":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["blu"]!, coloriPolaroid["giallo"]!, coloriPolaroid["verde"]!]
        case "bw", "black & white":
            return [coloriPolaroid["grigioScuro"]!, coloriPolaroid["nero"]!]
        case "duochrome":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["giallo"]!]
        case "metallic":
            return [coloriPolaroid["argento"]!, coloriPolaroid["oro"]!]
        default:
            return [coloriPolaroid["grigio"]!, coloriPolaroid["nero"]!]
        }
    }
    
    // Colori per pacco SX-70
    private static func coloriPerModelloSX70(_ modello: String) -> [Color] {
        switch modello.lowercased() {
        case "color":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["blu"]!, coloriPolaroid["giallo"]!]
        case "bw", "black & white":
            return [coloriPolaroid["grigioScuro"]!, coloriPolaroid["nero"]!]
        case "time zero":
            return [coloriPolaroid["grigio"]!, coloriPolaroid["beige"]!]
        default:
            return [coloriPolaroid["grigio"]!, coloriPolaroid["nero"]!]
        }
    }
    
    // Colori per pacco Go
    private static func coloriPerModelloGo(_ modello: String) -> [Color] {
        switch modello.lowercased() {
        case "color":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["blu"]!, coloriPolaroid["giallo"]!]
        case "bw", "black & white":
            return [coloriPolaroid["grigioScuro"]!, coloriPolaroid["nero"]!]
        case "duochrome":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["giallo"]!]
        default:
            return [coloriPolaroid["grigio"]!, coloriPolaroid["nero"]!]
        }
    }
    
    // Colori per pacco Spectra
    private static func coloriPerModelloSpectra(_ modello: String) -> [Color] {
        switch modello.lowercased() {
        case "color":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["blu"]!, coloriPolaroid["giallo"]!, coloriPolaroid["verde"]!]
        case "bw", "black & white":
            return [coloriPolaroid["grigioScuro"]!, coloriPolaroid["nero"]!]
        case "metallic":
            return [coloriPolaroid["argento"]!, coloriPolaroid["oro"]!]
        default:
            return [coloriPolaroid["grigio"]!, coloriPolaroid["nero"]!]
        }
    }
    
    // Colori per pacco 8x10
    private static func coloriPerModello8x10(_ modello: String) -> [Color] {
        switch modello.lowercased() {
        case "color":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["blu"]!, coloriPolaroid["giallo"]!, coloriPolaroid["verde"]!, coloriPolaroid["magenta"]!]
        case "bw", "black & white":
            return [coloriPolaroid["grigioScuro"]!, coloriPolaroid["nero"]!]
        default:
            return [coloriPolaroid["grigio"]!, coloriPolaroid["nero"]!]
        }
    }
    
    // Colori per pacco 4x5
    private static func coloriPerModello4x5(_ modello: String) -> [Color] {
        switch modello.lowercased() {
        case "color":
            return [coloriPolaroid["rosso"]!, coloriPolaroid["blu"]!, coloriPolaroid["giallo"]!, coloriPolaroid["verde"]!]
        case "bw", "black & white":
            return [coloriPolaroid["grigioScuro"]!, coloriPolaroid["nero"]!]
        default:
            return [coloriPolaroid["grigio"]!, coloriPolaroid["nero"]!]
        }
    }
}

// Vista per visualizzare i pallini colorati identificativi
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
        let colori = FilmPackColors.coloriPerTipo(tipo, modello: modello, modelliDisponibili: modelliDisponibili)
        
        ZStack {
            // Cerchio di sfondo
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Pallini colorati
            if colori.count == 1 {
                // Un solo colore: cerchio pieno
                Circle()
                    .fill(colori[0])
                    .frame(width: size * 0.6, height: size * 0.6)
            } else if colori.count == 2 {
                // Due colori: divisi verticalmente
                HStack(spacing: 0) {
                    Circle()
                        .fill(colori[0])
                        .frame(width: size * 0.4, height: size * 0.4)
                    Circle()
                        .fill(colori[1])
                        .frame(width: size * 0.4, height: size * 0.4)
                }
            } else if colori.count == 3 {
                // Tre colori: triangolo
                ZStack {
                    Circle()
                        .fill(colori[0])
                        .frame(width: size * 0.4, height: size * 0.4)
                        .offset(y: -size * 0.15)
                    
                    Circle()
                        .fill(colori[1])
                        .frame(width: size * 0.4, height: size * 0.4)
                        .offset(x: -size * 0.15, y: size * 0.15)
                    
                    Circle()
                        .fill(colori[2])
                        .frame(width: size * 0.4, height: size * 0.4)
                        .offset(x: size * 0.15, y: size * 0.15)
                }
            } else if colori.count == 4 {
                // Quattro colori: quadrato
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(colori[0])
                            .frame(width: size * 0.25, height: size * 0.25)
                        Circle()
                            .fill(colori[1])
                            .frame(width: size * 0.25, height: size * 0.25)
                    }
                    HStack(spacing: 2) {
                        Circle()
                            .fill(colori[2])
                            .frame(width: size * 0.25, height: size * 0.25)
                        Circle()
                            .fill(colori[3])
                            .frame(width: size * 0.25, height: size * 0.25)
                    }
                }
            } else if colori.count >= 5 {
                // Cinque o più colori: cerchio centrale + satelliti
                ZStack {
                    // Colore centrale
                    Circle()
                        .fill(colori[0])
                        .frame(width: size * 0.3, height: size * 0.3)
                    
                    // Colori satelliti
                    ForEach(1..<min(6, colori.count), id: \.self) { index in
                        let angle = Double(index - 1) * (2 * .pi / Double(min(5, colori.count - 1)))
                        let radius = size * 0.35
                        
                        Circle()
                            .fill(colori[index])
                            .frame(width: size * 0.2, height: size * 0.2)
                            .offset(
                                x: cos(angle) * radius,
                                y: sin(angle) * radius
                            )
                    }
                }
            }
        }
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
        
        HStack(spacing: 20) {
            VStack {
                Text("SX-70 BW")
                FilmPackColorIndicator(tipo: "SX-70", modello: "bw")
            }
            
            VStack {
                Text("Go Color")
                FilmPackColorIndicator(tipo: "Go", modello: "color")
            }
            
            VStack {
                Text("8x10 Color")
                FilmPackColorIndicator(tipo: "8x10", modello: "color")
            }
        }
    }
    .padding()
}
