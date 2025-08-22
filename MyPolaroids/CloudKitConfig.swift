import Foundation
import CloudKit

struct CloudKitConfig {
    // MARK: - Container
    static let containerIdentifier = "iCloud.Heterochrmia.Instantbox.com"
    
    // MARK: - Record Types
    struct RecordTypes {
        static let camera = "Camera"
        static let filmPack = "FilmPack"
    }
    
    // MARK: - Field Names
    struct FieldNames {
        // Camera fields
        static let cameraData = "cameraData"
        static let deviceID = "deviceID"
        static let lastModified = "lastModified" // Cambiato da modificationDate
        static let cameraID = "cameraID"
        
        // Film Pack fields
        static let filmPackData = "filmPackData"
        static let filmPackID = "filmPackID"
    }
    
    // MARK: - Indexes (per performance)
    // Nota: CloudKit gestisce automaticamente gli indici
    // Gli indici vengono creati automaticamente quando si eseguono query frequenti
    
    // MARK: - Query Predicates
    static func cameraQuery(for deviceID: String? = nil) -> CKQuery {
        // Query ultra-semplice per tutti i record Camera
        let query = CKQuery(recordType: RecordTypes.camera, predicate: NSPredicate(value: true))
        return query
    }
    
    static func filmPackQuery(for deviceID: String? = nil) -> CKQuery {
        // Query ultra-semplice per tutti i record FilmPack
        let query = CKQuery(recordType: RecordTypes.filmPack, predicate: NSPredicate(value: true))
        return query
    }
    
    // MARK: - Record Creation
    static func createCameraRecord(from camera: Camera, deviceID: String) -> CKRecord {
        let record = CKRecord(recordType: RecordTypes.camera)
        record[FieldNames.cameraData] = try? JSONEncoder().encode(camera)
        record[FieldNames.deviceID] = deviceID
        record[FieldNames.lastModified] = Date() // Cambiato da modificationDate
        record[FieldNames.cameraID] = camera.id.uuidString
        return record
    }
    
    static func createFilmPackRecord(from filmPack: FilmPack, deviceID: String) -> CKRecord {
        let record = CKRecord(recordType: RecordTypes.filmPack)
        record[FieldNames.filmPackData] = try? JSONEncoder().encode(filmPack)
        record[FieldNames.deviceID] = deviceID
        record[FieldNames.lastModified] = Date() // Cambiato da modificationDate
        record[FieldNames.filmPackID] = filmPack.id.uuidString
        return record
    }
    
    // MARK: - Error Handling
    static func handleCloudKitError(_ error: Error) -> String {
        if let cloudKitError = error as? CKError {
            switch cloudKitError.code {
            case .notAuthenticated:
                return "Non sei autenticato con iCloud"
            case .permissionFailure:
                return "Permessi iCloud negati"
            case .quotaExceeded:
                return "Spazio iCloud esaurito"
            case .networkUnavailable:
                return "Rete non disponibile"
            case .networkFailure:
                return "Errore di rete"
            case .serverResponseLost:
                return "Risposta server persa"
            case .serviceUnavailable:
                return "Servizio iCloud non disponibile"
            case .requestRateLimited:
                return "Troppe richieste, riprova più tardi"
            case .unknownItem:
                return "Container CloudKit non configurato. Verifica la configurazione in Xcode."
            case .serverRecordChanged:
                return "Dati modificati sul server. Sincronizzazione richiesta."
            case .invalidArguments:
                return "Query CloudKit non valida. Verifica la configurazione dei record types."
            case .badDatabase:
                return "Database CloudKit non accessibile. Verifica i permessi iCloud."
            case .zoneNotFound:
                return "Zona CloudKit non trovata. Container non configurato."
            default:
                return "Errore iCloud: \(cloudKitError.localizedDescription)"
            }
        }
        return "Errore sconosciuto: \(error.localizedDescription)"
    }
}
