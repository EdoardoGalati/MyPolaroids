import Foundation

struct DataConfig {
    // URL per i file JSON online
    // Per test, usa i file locali. Cambia questi URL quando i file sono online
    static let cameraModelsURL = "https://edoardogalati.github.io/MyPolaroids/camera_models.json"
    static let filmPackModelsURL = "https://edoardogalati.github.io/MyPolaroids/film_pack_models.json"
    
    // URL di test locali (commenta quando i file sono online)
    // static let cameraModelsURL = "file:///Users/edoardogalati/Documents/Xcode/MyPolaroids/MyPolaroids/test_camera_models.json"
    // static let filmPackModelsURL = "file:///Users/edoardogalati/Documents/Xcode/MyPolaroids/MyPolaroids/test_film_pack_models.json"
    
    // Configurazione per il download
    static let downloadTimeout: TimeInterval = 30.0
    static let cacheExpirationDays: Int = 7
    
    // Chiavi per UserDefaults
    struct UserDefaultsKeys {
        static let cameraModelsCache = "cached_camera_models"
        static let filmPackModelsCache = "cached_film_pack_models"
        static let filmPackTypesCache = "cached_film_pack_types"
        static let lastUpdateDate = "last_data_update"
        static let cacheExpirationDate = "cache_expiration_date"
    }
    
    // Controlla se la cache è scaduta
    static func isCacheExpired() -> Bool {
        guard let expirationDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.cacheExpirationDate) as? Date else {
            return true
        }
        return Date() > expirationDate
    }
    
    // Imposta la data di scadenza della cache
    static func setCacheExpiration() {
        let expirationDate = Calendar.current.date(byAdding: .day, value: cacheExpirationDays, to: Date()) ?? Date()
        UserDefaults.standard.set(expirationDate, forKey: UserDefaultsKeys.cacheExpirationDate)
    }
    
    // Controlla se è necessario scaricare i dati
    static func shouldDownloadData() -> Bool {
        // Scarica se non ci sono dati in cache o se la cache è scaduta
        let hasCameraModels = UserDefaults.standard.data(forKey: UserDefaultsKeys.cameraModelsCache) != nil
        let hasFilmPackModels = UserDefaults.standard.data(forKey: UserDefaultsKeys.filmPackModelsCache) != nil
        
        return !hasCameraModels || !hasFilmPackModels || isCacheExpired()
    }
}
