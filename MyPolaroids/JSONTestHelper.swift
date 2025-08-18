import Foundation

struct JSONTestHelper {
    
    // Testa la struttura del JSON scaricato
    static func testJSONStructure(_ jsonString: String, expectedType: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ [JSONTestHelper] Impossibile convertire la stringa in data")
            return false
        }
        
        do {
            switch expectedType {
            case "FilmPackModelsData":
                let _ = try JSONDecoder().decode(FilmPackModelsData.self, from: data)
                print("✅ [JSONTestHelper] FilmPackModelsData decodificato con successo")
                return true
                
            case "CameraModelsData":
                let _ = try JSONDecoder().decode(CameraModelsData.self, from: data)
                print("✅ [JSONTestHelper] CameraModelsData decodificato con successo")
                return true
                
            default:
                print("❌ [JSONTestHelper] Tipo non supportato: \(expectedType)")
                return false
            }
        } catch {
            print("❌ [JSONTestHelper] Errore di decodifica per \(expectedType): \(error)")
            return false
        }
    }
    
    // Stampa la struttura del JSON per debug
    static func printJSONStructure(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ [JSONTestHelper] Impossibile convertire la stringa in data")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("📋 [JSONTestHelper] Struttura JSON:")
                for (key, value) in json {
                    if let array = value as? [Any] {
                        print("  - \(key): Array con \(array.count) elementi")
                    } else if let dict = value as? [String: Any] {
                        print("  - \(key): Dizionario con \(dict.count) chiavi")
                    } else {
                        print("  - \(key): \(value)")
                    }
                }
            } else if let array = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                print("📋 [JSONTestHelper] JSON è un array con \(array.count) elementi")
            } else {
                print("📋 [JSONTestHelper] Struttura JSON non riconosciuta")
            }
        } catch {
            print("❌ [JSONTestHelper] Errore nel parsing JSON: \(error)")
        }
    }
    
    // Valida i dati scaricati
    static func validateDownloadedData<T: Codable>(_ data: T, type: String) -> Bool {
        do {
            let jsonData = try JSONEncoder().encode(data)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            
            print("🔍 [JSONTestHelper] Validazione dati \(type):")
            print("   - Dimensione: \(jsonData.count) bytes")
            print("   - Stringa JSON: \(jsonString.prefix(200))...")
            
            return true
        } catch {
            print("❌ [JSONTestHelper] Errore nella validazione di \(type): \(error)")
            return false
        }
    }
}
