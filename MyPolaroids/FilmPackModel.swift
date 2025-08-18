import Foundation

struct FilmPackType: Codable, Identifiable {
    let id: String
    let name: String
    let default_capacity: Int
    let compatible_cameras: [String]
    let description: String
}

struct FilmPackModel: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let category: String
    let colors: [String]
}

struct FilmPackModelsData: Codable {
    let film_pack_types: [FilmPackType]
    let film_pack_models: [FilmPackModel]
}
