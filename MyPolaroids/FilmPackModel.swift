import Foundation

// Strutture per i gradienti configurabili
struct FilmPackGradient: Codable {
    let stops: [GradientStop]
    let type: String?
    let startPoint: GradientPoint?
    let endPoint: GradientPoint?
    let center: GradientPoint?
    
    // Computed properties per compatibilità
    var isElliptical: Bool {
        return type == "elliptical"
    }
    
    var isLinear: Bool {
        return type != "elliptical"
    }
}

struct GradientStop: Codable {
    let color: RGBColor
    let location: Double
}

struct RGBColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
}

struct GradientPoint: Codable {
    let x: Double
    let y: Double
}

struct FilmPackType: Codable, Identifiable {
    let id: String
    let name: String
    let default_capacity: Int
    let description: String
}

struct FilmPackModel: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let category: String
    let gradient: FilmPackGradient?
}

struct FilmPackModelsData: Codable {
    let film_pack_types: [FilmPackType]
    let film_pack_models: [FilmPackModel]
}
