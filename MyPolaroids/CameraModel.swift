import Foundation

struct CameraModel: Codable, Identifiable {
    let id: String
    let name: String
    let capacity: Int
    let default_image: String
    let default_icon: String
    let description: String
    let year_introduced: Int
    let film_type: String
}

struct CameraModelsData: Codable {
    let camera_models: [CameraModel]
}
