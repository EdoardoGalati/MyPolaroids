import Foundation
import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    @Published var fotocamere: [Camera] = []
    @Published var modelliDisponibili: [CameraModel] = []
    @Published var filmPackViewModel: FilmPackViewModel?
    
    // Contatore per prevenire chiamate ricorsive
    private var aggiornaFotocameraCallCount = 0
    
    init() {
        caricaModelli()
        caricaFotocamere()
        setupFilmPackViewModel()
    }
    
    // Proprietà computata per le fotocamere ordinate
    var fotocamereOrdinate: [Camera] {
        let sortingOption = UserDefaults.standard.string(forKey: "cameraSortingOption") ?? SortingOption.dateAdded.rawValue
        
        switch sortingOption {
        case SortingOption.alphabeticalAZ.rawValue:
            return fotocamere.sorted { first, second in
                return compareStringsNatural(first.nickname, second.nickname)
            }
        case SortingOption.alphabeticalZA.rawValue:
            return fotocamere.sorted { first, second in
                return !compareStringsNatural(first.nickname, second.nickname) // Inverti per Z-A
            }
        case SortingOption.dateAdded.rawValue:
            return fotocamere.sorted { $0.dataAggiunta < $1.dataAggiunta } // Ordine per data di aggiunta (più vecchia prima)
        case SortingOption.dateAddedReverse.rawValue:
            return fotocamere.sorted { $0.dataAggiunta > $1.dataAggiunta } // Ordine per data di aggiunta (più recente prima)
        case SortingOption.loadedFirst.rawValue:
            return fotocamere.sorted { first, second in
                let firstLoaded = filmPackViewModel?.filmCaricato(in: first) != nil
                let secondLoaded = filmPackViewModel?.filmCaricato(in: second) != nil
                if firstLoaded == secondLoaded {
                    return compareStringsNatural(first.nickname, second.nickname) // A-Z per default
                }
                return firstLoaded && !secondLoaded
            }
        case SortingOption.unloadedFirst.rawValue:
            return fotocamere.sorted { first, second in
                let firstLoaded = filmPackViewModel?.filmCaricato(in: first) != nil
                let secondLoaded = filmPackViewModel?.filmCaricato(in: second) != nil
                if firstLoaded == secondLoaded {
                    return compareStringsNatural(first.nickname, second.nickname) // A-Z per default
                }
                return !firstLoaded && secondLoaded
            }
        default:
            return fotocamere
        }
    }
    
    // Funzione helper per confronto naturale delle stringhe (numeri alla fine)
    private func compareStringsNatural(_ first: String, _ second: String) -> Bool {
        let firstLower = first.lowercased()
        let secondLower = second.lowercased()
        
        // Se entrambe le stringhe sono uguali, sono uguali
        if firstLower == secondLower {
            return false // Non importa l'ordine se sono uguali
        }
        
        // Se entrambe le stringhe iniziano con numeri, ordina numericamente
        if firstLower.first?.isNumber == true && secondLower.first?.isNumber == true {
            // Estrai i numeri iniziali
            let firstNumber = extractLeadingNumber(from: firstLower)
            let secondNumber = extractLeadingNumber(from: secondLower)
            
            if firstNumber != secondNumber {
                return firstNumber < secondNumber
            }
            
            // Se i numeri sono uguali, confronta le parti rimanenti
            let firstRemaining = String(firstLower.dropFirst(String(firstNumber).count))
            let secondRemaining = String(secondLower.dropFirst(String(secondNumber).count))
            return firstRemaining < secondRemaining
        }
        
        // Se solo la prima inizia con numero, metti la seconda prima (numeri alla fine)
        if firstLower.first?.isNumber == true && secondLower.first?.isNumber == false {
            return false // La prima (con numero) va dopo
        }
        
        // Se solo la seconda inizia con numero, metti la prima prima (numeri alla fine)
        if firstLower.first?.isNumber == false && secondLower.first?.isNumber == true {
            return true // La prima (senza numero) va prima
        }
        
        // Altrimenti, ordinamento alfabetico standard
        return firstLower < secondLower
    }
    
    // Funzione helper per estrarre il numero iniziale da una stringa
    private func extractLeadingNumber(from string: String) -> Int {
        let numbers = string.prefix { $0.isNumber }
        return Int(numbers) ?? 0
    }
    
    // Aggiunge una nuova fotocamera
    func aggiungiFotocamera(_ fotocamera: Camera) {
        var fotocameraAggiornata = fotocamera
        // Assicurati che la data di aggiunta sia impostata
        if fotocameraAggiornata.dataAggiunta == Date.distantPast {
            fotocameraAggiornata.dataAggiunta = Date()
        }
        fotocamere.append(fotocameraAggiornata)
        salvaFotocamere()
        filmPackViewModel?.setFotocamere(fotocamere)
    }
    
    // Crea una nuova fotocamera con i modelli disponibili
    func creaFotocamera(nickname: String, modello: String, coloreIcona: String? = nil) -> Camera {
        var fotocamera = Camera(
            nickname: nickname,
            modello: modello,
            coloreIcona: coloreIcona,
            modelliDisponibili: modelliDisponibili
        )
        // Assicurati che la data di aggiunta sia impostata correttamente
        fotocamera.dataAggiunta = Date()
        return fotocamera
    }
    
    // Rimuove una fotocamera
    func rimuoviFotocamera(_ fotocamera: Camera) {
        if let index = fotocamere.firstIndex(where: { $0.id == fotocamera.id }) {
            // Elimina prima tutti i pacchi film associati
            filmPackViewModel?.eliminaPacchiFilmPerFotocamera(fotocamera.id)
            
            // Poi rimuovi la fotocamera
            fotocamere.remove(at: index)
            salvaFotocamere()
            filmPackViewModel?.setFotocamere(fotocamere)
            
            print("🗑️ Fotocamera eliminata: \(fotocamera.nickname) (\(fotocamera.modello))")
        }
    }
    
    // Aggiorna una fotocamera esistente
    func aggiornaFotocamera(_ fotocamera: Camera) {
        print("🔧 [CameraViewModel] ===== INIZIO AGGIORNAFOTOCAMERA =====")
        print("🔧 [CameraViewModel] aggiornaFotocamera() chiamata")
        print("🔧 [CameraViewModel] Stack trace: \(Thread.callStackSymbols.prefix(3))")
        print("🔧 [CameraViewModel] Fotocamera da aggiornare:")
        print("   - id: \(fotocamera.id)")
        print("🔧 [CameraViewModel] Numero fotocamere attuali: \(fotocamere.count)")
        
        // Controllo se questa è una chiamata ricorsiva
        aggiornaFotocameraCallCount += 1
        if aggiornaFotocameraCallCount > 3 {
            print("❌ [CameraViewModel] ERRORE: Troppe chiamate ricorsive! Interrompo.")
            aggiornaFotocameraCallCount = 0
            return
        }
        
        if let index = fotocamere.firstIndex(where: { $0.id == fotocamera.id }) {
            print("🔧 [CameraViewModel] Fotocamera trovata all'indice: \(index)")
            print("🔧 [CameraViewModel] Fotocamera PRIMA dell'aggiornamento:")
            print("   - nickname: '\(fotocamere[index].nickname)'")
            print("   - modello: '\(fotocamere[index].modello)'")
            print("   - coloreIcona: '\(fotocamere[index].coloreIcona)'")
            
            // Creo un nuovo array per forzare l'aggiornamento dell'UI
            print("🔧 [CameraViewModel] Creazione nuovo array...")
            var nuovoArray = fotocamere
            var fotocameraAggiornata = fotocamera
            // Mantieni la data di aggiunta esistente
            fotocameraAggiornata.dataAggiunta = fotocamere[index].dataAggiunta
            nuovoArray[index] = fotocameraAggiornata
            print("🔧 [CameraViewModel] Nuovo array creato, aggiornamento fotocamere...")
            fotocamere = nuovoArray
            print("🔧 [CameraViewModel] Array fotocamere aggiornato!")
            
            print("🔧 [CameraViewModel] Fotocamera DOPO l'aggiornamento:")
            print("   - nickname: '\(fotocamere[index].nickname)'")
            print("   - modello: '\(fotocamere[index].modello)'")
            print("   - coloreIcona: '\(fotocamere[index].coloreIcona)'")
            
            print("🔧 [CameraViewModel] Chiamata salvaFotocamere()")
            salvaFotocamere()
            print("🔧 [CameraViewModel] salvaFotocamere() completata")
            
            // Rimuovo questa chiamata che causa il loop infinito
            // filmPackViewModel?.setFotocamere(fotocamere)
            print("🔧 [CameraViewModel] Aggiornamento completato (senza setFotocamere)")
            aggiornaFotocameraCallCount = 0
            print("🔧 [CameraViewModel] ===== FINE AGGIORNAFOTOCAMERA =====")
        } else {
            print("❌ [CameraViewModel] ERRORE: Fotocamera con id \(fotocamera.id) non trovata!")
            print("❌ [CameraViewModel] ID disponibili: \(fotocamere.map { $0.id })")
            aggiornaFotocameraCallCount = 0
            print("🔧 [CameraViewModel] ===== FINE AGGIORNAFOTOCAMERA CON ERRORE =====")
        }
    }
    
    // Salva le fotocamere in UserDefaults
    private func salvaFotocamere() {
        print("🔧 [CameraViewModel] salvaFotocamere() iniziata")
        print("🔧 [CameraViewModel] Numero fotocamere da salvare: \(fotocamere.count)")
        
        if let encoded = try? JSONEncoder().encode(fotocamere) {
            print("🔧 [CameraViewModel] Encoding JSON completato, dimensione: \(encoded.count) bytes")
            UserDefaults.standard.set(encoded, forKey: "fotocamere")
            print("🔧 [CameraViewModel] Dati salvati in UserDefaults con chiave 'fotocamere'")
            
            // Verifica che il salvataggio sia avvenuto
            if let savedData = UserDefaults.standard.data(forKey: "fotocamere") {
                print("🔧 [CameraViewModel] Verifica: dati letti da UserDefaults, dimensione: \(savedData.count) bytes")
            } else {
                print("❌ [CameraViewModel] ERRORE: Dati non trovati in UserDefaults dopo il salvataggio!")
            }
        } else {
            print("❌ [CameraViewModel] ERRORE: Encoding JSON fallito!")
        }
    }
    
    // Carica i modelli di fotocamera dal JSON
    private func caricaModelli() {
        print("🔄 [CameraViewModel] ===== INIZIO CARICAMENTO MODELLI =====")
        
        // Prima prova a caricare dalla cache locale
        if let cachedData = DataDownloader.shared.loadFromCache(forKey: DataConfig.UserDefaultsKeys.cameraModelsCache, type: [CameraModel].self) {
            modelliDisponibili = cachedData
            print("📱 [CameraViewModel] ✅ Cache locale trovata: \(cachedData.count) modelli")
            print("📋 [CameraViewModel] Modelli dalla cache:")
            for (index, modello) in cachedData.enumerated() {
                print("   \(index + 1). \(modello.brand) \(modello.name) (\(modello.specific_model))")
            }
        } else {
            print("📱 [CameraViewModel] ❌ Cache locale vuota o non trovata")
        }
        
        // Poi prova a scaricare online
        print("🌐 [CameraViewModel] 🚀 Avvio download online in background...")
        Task {
            await downloadModelliOnline()
        }
        print("🔄 [CameraViewModel] ===== FINE CARICAMENTO MODELLI =====")
    }
    
    // Scarica i modelli online
    @MainActor
    private func downloadModelliOnline() async {
        print("🌐 [CameraViewModel] ===== INIZIO DOWNLOAD ONLINE =====")
        print("🌐 [CameraViewModel] Chiamata a DataDownloader.shared.downloadCameraModels()...")
        
        do {
            let modelli = try await DataDownloader.shared.downloadCameraModels()
            modelliDisponibili = modelli
            
            print("🌐 [CameraViewModel] ✅ DOWNLOAD COMPLETATO: \(modelli.count) modelli")
            print("📋 [CameraViewModel] Dettagli modelli scaricati:")
            for (index, modello) in modelli.enumerated() {
                print("   \(index + 1). \(modello.brand) \(modello.name) (\(modello.specific_model))")
            }
            print("🌐 [CameraViewModel] ===== DOWNLOAD ONLINE COMPLETATO =====")
            
        } catch {
            print("❌ [CameraViewModel] ❌ ERRORE nel download online: \(error)")
            print("❌ [CameraViewModel] Dettagli errore: \(error.localizedDescription)")
            
            // Se non ci sono dati in cache, usa i modelli di default
            if modelliDisponibili.isEmpty {
                print("⚠️ [CameraViewModel] Usando modelli di default perché cache vuota")
                modelliDisponibili = [
                    CameraModel(id: "polaroid_600", name: "600", brand: "Polaroid", model: "600", specific_model: "Original", capacity: 8, default_image: "camera.fill", default_icon: "camera.fill", year_introduced: 1981, film_type: "600/i-Type"),
                ]
            } else {
                print("📱 [CameraViewModel] Mantenendo \(modelliDisponibili.count) modelli dalla cache")
            }
            print("🌐 [CameraViewModel] ===== DOWNLOAD ONLINE FALLITO =====")
        }
    }
    
    // Carica le fotocamere da UserDefaults
    private func caricaFotocamere() {
        if let data = UserDefaults.standard.data(forKey: "fotocamere"),
           let decoded = try? JSONDecoder().decode([Camera].self, from: data) {
            // Per compatibilità con i dati esistenti, assegna una data di aggiunta se mancante
            fotocamere = decoded.map { fotocamera in
                var fotocameraAggiornata = fotocamera
                // Se la fotocamera non ha una data di aggiunta (dati esistenti), usa la data corrente
                if fotocameraAggiornata.dataAggiunta == Date.distantPast {
                    fotocameraAggiornata.dataAggiunta = Date()
                }
                return fotocameraAggiornata
            }
        }
    }
    
    // Configura il FilmPackViewModel
    func setupFilmPackViewModel() {
        filmPackViewModel = FilmPackViewModel()
        filmPackViewModel?.setFotocamere(fotocamere)
        filmPackViewModel?.onPacchiFilmChanged = { [weak self] in
            self?.aggiornaFotocamereDaPacchiFilm()
        }
    }
    
    // Aggiorna le fotocamere quando i pacchi film cambiano
    func aggiornaFotocamereDaPacchiFilm() {
        // Ricarica le fotocamere per aggiornare i riferimenti ai pacchi film
        if let data = UserDefaults.standard.data(forKey: "fotocamere"),
           let decoded = try? JSONDecoder().decode([Camera].self, from: data) {
            // Mantieni le date di aggiunta esistenti per le fotocamere che esistono già
            fotocamere = decoded.map { fotocameraCaricata in
                if let existingIndex = fotocamere.firstIndex(where: { $0.id == fotocameraCaricata.id }) {
                    // Mantieni la data di aggiunta esistente
                    var fotocameraAggiornata = fotocameraCaricata
                    fotocameraAggiornata.dataAggiunta = fotocamere[existingIndex].dataAggiunta
                    return fotocameraAggiornata
                } else {
                    // Nuova fotocamera, usa la data di aggiunta dal JSON o la data corrente se mancante
                    var fotocameraAggiornata = fotocameraCaricata
                    if fotocameraAggiornata.dataAggiunta == Date.distantPast {
                        fotocameraAggiornata.dataAggiunta = Date()
                    }
                    return fotocameraAggiornata
                }
            }
        }
    }
}
