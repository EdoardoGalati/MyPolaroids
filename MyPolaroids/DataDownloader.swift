import Foundation
import Combine

class DataDownloader: ObservableObject {
    static let shared = DataDownloader()
    
    @Published var isLoading = false
    @Published var lastUpdateDate: Date?
    
    private let cameraModelsURL = DataConfig.cameraModelsURL
    private let filmPackModelsURL = DataConfig.filmPackModelsURL
    
    // Cache locale per i dati
    private let userDefaults = UserDefaults.standard
    private let cameraModelsKey = DataConfig.UserDefaultsKeys.cameraModelsCache
    private let filmPackModelsKey = DataConfig.UserDefaultsKeys.filmPackModelsCache
    private let lastUpdateKey = DataConfig.UserDefaultsKeys.lastUpdateDate
    
    init() {
        loadLastUpdateDate()
    }
    
    // MARK: - Download Camera Models
    func downloadCameraModels() async throws -> [CameraModel] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Prova prima a scaricare la struttura completa del JSON
            let cameraData = try await performDownload(urlString: cameraModelsURL, type: CameraModelsData.self)
            
            // Estrai i modelli dal JSON completo
            let cameras = cameraData.camera_models
            
            // Salva in cache
            await saveToCache(cameras, forKey: cameraModelsKey)
            await updateLastUpdateDate()
            
            return cameras
        } catch {
            // Se il download fallisce, prova a caricare dalla cache
            if let cachedData = loadFromCache(forKey: cameraModelsKey, type: [CameraModel].self) {
                return cachedData
            }
            throw error
        }
    }
    
    // MARK: - Download Film Pack Models
    func downloadFilmPackModels() async throws -> [FilmPackModel] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Prova prima a scaricare la struttura completa del JSON
            let filmPackData = try await performDownload(urlString: filmPackModelsURL, type: FilmPackModelsData.self)
            
            // Estrai i modelli dal JSON completo
            let filmPacks = filmPackData.film_pack_models
            
            // Salva in cache
            await saveToCache(filmPacks, forKey: filmPackModelsKey)
            await updateLastUpdateDate()
            
            return filmPacks
        } catch {
            // Se il download fallisce, prova a caricare dalla cache
            if let cachedData = loadFromCache(forKey: filmPackModelsKey, type: [FilmPackModel].self) {
                return cachedData
            }
            throw error
        }
    }
    
    // MARK: - Download Film Pack Types
    func downloadFilmPackTypes() async throws -> [FilmPackType] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Prova prima a scaricare la struttura completa del JSON
            let filmPackData = try await performDownload(urlString: filmPackModelsURL, type: FilmPackModelsData.self)
            
            // Estrai i tipi dal JSON completo
            let types = filmPackData.film_pack_types
            
            // Salva in cache
            await saveToCache(types, forKey: DataConfig.UserDefaultsKeys.filmPackTypesCache)
            await updateLastUpdateDate()
            
            return types
        } catch {
            // Se il download fallisce, prova a caricare dalla cache
            if let cachedData = loadFromCache(forKey: DataConfig.UserDefaultsKeys.filmPackTypesCache, type: [FilmPackType].self) {
                return cachedData
            }
            throw error
        }
    }
    
    // MARK: - Download Generico
    private func performDownload<T: Codable>(urlString: String, type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        print("🌐 [DataDownloader] Download da: \(urlString)")
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ [DataDownloader] Errore HTTP: \(response)")
            throw URLError(.badServerResponse)
        }
        
        print("📊 [DataDownloader] Dati scaricati: \(data.count) bytes")
        
        // Debug: stampa la struttura del JSON
        if let jsonString = String(data: data, encoding: .utf8) {
            JSONTestHelper.printJSONStructure(jsonString)
        }
        
        do {
            let result = try JSONDecoder().decode(type, from: data)
            print("✅ [DataDownloader] Decodifica riuscita per \(type)")
            return result
        } catch {
            print("❌ [DataDownloader] Errore di decodifica: \(error)")
            throw error
        }
    }
    
    // MARK: - Cache Management
    private func saveToCache<T: Codable>(_ data: T, forKey key: String) async {
        do {
            let encodedData = try JSONEncoder().encode(data)
            userDefaults.set(encodedData, forKey: key)
        } catch {
            print("Errore nel salvataggio della cache: \(error)")
        }
    }
    
    func loadFromCache<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Errore nel caricamento dalla cache: \(error)")
            return nil
        }
    }
    
    // MARK: - Update Date Management
    private func updateLastUpdateDate() async {
        await MainActor.run {
            lastUpdateDate = Date()
            userDefaults.set(lastUpdateDate, forKey: lastUpdateKey)
        }
    }
    
    private func loadLastUpdateDate() {
        lastUpdateDate = userDefaults.object(forKey: lastUpdateKey) as? Date
    }
    
    // MARK: - Check for Updates
    func checkForUpdates() async -> Bool {
        // Qui potresti implementare una logica per controllare se ci sono aggiornamenti
        // Per ora restituiamo sempre true per forzare il download
        return true
    }
    
    // MARK: - Clear Cache
    func clearCache() {
        userDefaults.removeObject(forKey: cameraModelsKey)
        userDefaults.removeObject(forKey: filmPackModelsKey)
        userDefaults.removeObject(forKey: lastUpdateKey)
        lastUpdateDate = nil
    }
}
