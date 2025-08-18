import Foundation

struct ModelNameHelper {
    
    // Mappa i nomi UI ai nomi normalizzati
    static let uiToNormalizedMap: [String: String] = [
        "Color": "color",
        "Black & White": "black_white",
        "Color Frame": "color_frame",
        "Black Frame B&W": "black_frame_bw",
        "Duochrome (Blue)": "duochrome_blue",
        "Duochrome (Green)": "duochrome_green",
        "Duochrome (Yellow)": "duochrome_yellow",
        "Duochrome (Red)": "duochrome_red",
        "Duochrome (Orange)": "duochrome_orange",
        "Metallic": "metallic",
        "Gold Frame": "gold_frame",
        "Silver Frame": "silver_frame",
        "Round Frame": "round_frame",
        "Retro": "retro",
        "Vintage": "vintage",
        "Multicolor 600": "multicolor_600",
        "Rounded": "rounded"
    ]
    
    // Mappa inversa: dai nomi normalizzati ai nomi UI
    static let normalizedToUIMap: [String: String] = {
        var map: [String: String] = [:]
        for (ui, normalized) in uiToNormalizedMap {
            map[normalized] = ui
        }
        return map
    }()
    
    // Normalizza un nome UI (es: "Color" -> "color")
    static func normalize(_ uiName: String) -> String {
        return uiToNormalizedMap[uiName] ?? uiName.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    // Converte un nome normalizzato in nome UI (es: "color" -> "Color")
    static func toUIName(_ normalizedName: String) -> String {
        return normalizedToUIMap[normalizedName] ?? normalizedName.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    // Trova un modello per nome UI
    static func findModel(uiName: String, in models: [FilmPackModel]) -> FilmPackModel? {
        let normalizedName = normalize(uiName)
        return models.first { $0.id == normalizedName || $0.name.lowercased() == normalizedName.lowercased() }
    }
    
    // Ottiene tutti i nomi UI disponibili
    static var availableUINames: [String] {
        return Array(uiToNormalizedMap.keys).sorted()
    }
    
    // Verifica se un nome UI è valido
    static func isValidUIName(_ name: String) -> Bool {
        return uiToNormalizedMap.keys.contains(name)
    }
}
