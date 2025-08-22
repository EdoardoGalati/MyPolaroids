import Foundation
import Combine
import UserNotifications

class FilmPackViewModel: ObservableObject {
    @Published var pacchiFilm: [FilmPack] = []
    @Published var fotocamere: [Camera] = []
    @Published var tipiFilm: [FilmPackType] = []
    @Published var modelliFilm: [FilmPackModel] = []
    
    // CloudKit Manager per sincronizzazione iCloud
    private let cloudKitManager = CloudKitManager()
    
    var onPacchiFilmChanged: (() -> Void)?
    
    init() {
        caricaModelli()
        caricaPacchiFilm()
        inizializzaOrdineTipologieStabile()
        
        // Imposta i callback per la sincronizzazione CloudKit
        cloudKitManager.onFilmPacksSynced = { [weak self] syncedFilmPacks in
            DispatchQueue.main.async {
                print("📦 [FilmPackViewModel] 🔄 Ricevuti \(syncedFilmPacks.count) pacchi film sincronizzati da iCloud")
                self?.pacchiFilm = syncedFilmPacks
                print("📦 [FilmPackViewModel] ✅ Lista pacchi film aggiornata con dati da iCloud")
            }
        }
    }
    
    // Aggiunge un nuovo pacco film
    func aggiungiPaccoFilm(_ pacco: FilmPack) {
        pacchiFilm.append(pacco)
        salvaPacchiFilm()
        pulisciCacheCompatibilita()
    }
    
    // Aggiunge un nuovo pacco film all'inizio della lista
    // IMPORTANTE: Questa funzione mantiene l'ordine stabile delle tipologie
    // per evitare il bug di navigazione. Quando viene aggiunto un nuovo pacco:
    // 1. Se è di una tipologia esistente, l'ordine rimane invariato
    // 2. Se è di una nuova tipologia, viene aggiunta alla fine dell'ordine stabile
    // 3. La UI si aggiorna senza cambiare la navigazione corrente
    func aggiungiPaccoFilmInCima(_ pacco: FilmPack) {
        // Inserisci il nuovo pacco all'inizio
        pacchiFilm.insert(pacco, at: 0)
        
        // Aggiorna l'ordine stabile delle tipologie se necessario
        let chiave = "\(pacco.tipo)_\(pacco.modello)"
        if !ordineTipologieStabile.contains(chiave) {
            ordineTipologieStabile.append(chiave)
            print("🔒 [FilmPackViewModel] Nuova tipologia aggiunta all'ordine stabile: \(chiave)")
        }
        
        // Salva e pulisci la cache
        salvaPacchiFilm()
        pulisciCacheCompatibilita()
        
        // Forza l'aggiornamento della UI per le tipologie
        // Questo è cruciale per mantenere la stabilità della navigazione
        objectWillChange.send()
        
        print("📦 [FilmPackViewModel] Nuovo pacco aggiunto in cima: \(pacco.tipo) • \(pacco.modello)")
        print("📦 [FilmPackViewModel] Ordine tipologie mantenuto stabile per evitare bug di navigazione")
    }
    
    // Rimuove un pacco film
    func rimuoviPaccoFilm(_ pacco: FilmPack) {
        if let index = pacchiFilm.firstIndex(where: { $0.id == pacco.id }) {
            pacchiFilm.remove(at: index)
            
            // Controlla se ci sono ancora pacchi di questo tipo e modello
            let chiave = "\(pacco.tipo)_\(pacco.modello)"
            let pacchiRimanenti = pacchiFilm.filter { 
                "\($0.tipo)_\($0.modello)" == chiave 
            }
            
            // Se non ci sono più pacchi di questo tipo, rimuovi dall'ordine stabile
            if pacchiRimanenti.isEmpty {
                if let indexStabile = ordineTipologieStabile.firstIndex(of: chiave) {
                    ordineTipologieStabile.remove(at: indexStabile)
                    print("🔒 [FilmPackViewModel] Tipologia rimossa dall'ordine stabile: \(chiave)")
                }
            }
            
            salvaPacchiFilm()
            pulisciCacheCompatibilita()
        }
    }
    
    // Aggiorna un pacco film esistente
    func aggiornaPaccoFilm(_ pacco: FilmPack) {
        if let index = pacchiFilm.firstIndex(where: { $0.id == pacco.id }) {
            let paccoVecchio = pacchiFilm[index]
            pacchiFilm[index] = pacco
            
            // Se il tipo o modello è cambiato, aggiorna l'ordine stabile
            let chiaveVecchia = "\(paccoVecchio.tipo)_\(paccoVecchio.modello)"
            let chiaveNuova = "\(pacco.tipo)_\(pacco.modello)"
            
            if chiaveVecchia != chiaveNuova {
                // Rimuovi la vecchia tipologia dall'ordine stabile se non ci sono più pacchi
                let pacchiVecchiaTipologia = pacchiFilm.filter { 
                    "\($0.tipo)_\($0.modello)" == chiaveVecchia 
                }
                
                if pacchiVecchiaTipologia.isEmpty {
                    if let indexStabile = ordineTipologieStabile.firstIndex(of: chiaveVecchia) {
                        ordineTipologieStabile.remove(at: indexStabile)
                        print("🔒 [FilmPackViewModel] Vecchia tipologia rimossa dall'ordine stabile: \(chiaveVecchia)")
                    }
                }
                
                // Aggiungi la nuova tipologia all'ordine stabile se non esiste
                if !ordineTipologieStabile.contains(chiaveNuova) {
                    ordineTipologieStabile.append(chiaveNuova)
                    print("🔒 [FilmPackViewModel] Nuova tipologia aggiunta all'ordine stabile: \(chiaveNuova)")
                }
            }
            
            salvaPacchiFilm()
            pulisciCacheCompatibilita()
        }
    }
    
    // Associa un pacco film a una fotocamera
    func associaPaccoFilm(_ pacco: FilmPack, a fotocamera: Camera) {
        var paccoAggiornato = pacco
        paccoAggiornato.fotocameraAssociata = fotocamera.id
        aggiornaPaccoFilm(paccoAggiornato)
    }
    
    // Disassocia un pacco film
    func disassociaPaccoFilm(_ pacco: FilmPack) {
        var paccoAggiornato = pacco
        paccoAggiornato.fotocameraAssociata = nil
        aggiornaPaccoFilm(paccoAggiornato)
    }
    
    // Consuma uno scatto da un pacco film
    func consumaScatto(da pacco: FilmPack) {
        guard pacco.scattiRimanenti > 0 else { return }
        
        var paccoAggiornato = pacco
        paccoAggiornato.scattiRimanenti -= 1
        aggiornaPaccoFilm(paccoAggiornato)
    }
    
    // Ottiene i pacchi film associati a una fotocamera
    func pacchiPerFotocamera(_ fotocamera: Camera) -> [FilmPack] {
        return pacchiFilm.filter { $0.fotocameraAssociata == fotocamera.id }
    }
    
    // Proprietà computata per i pacchi film ordinati
    var pacchiFilmOrdinate: [FilmPack] {
        let sortingOption = UserDefaults.standard.string(forKey: "filmPackSortingOption") ?? SortingOption.dateAdded.rawValue
        
        switch sortingOption {
        case SortingOption.alphabeticalAZ.rawValue:
            return pacchiFilm.sorted { first, second in
                let firstString = "\(first.tipo) \(first.modello)"
                let secondString = "\(second.tipo) \(second.modello)"
                return compareStringsNatural(firstString, secondString)
            }
        case SortingOption.alphabeticalZA.rawValue:
            return pacchiFilm.sorted { first, second in
                let firstString = "\(first.tipo) \(first.modello)"
                let secondString = "\(second.tipo) \(second.modello)"
                return !compareStringsNatural(firstString, secondString) // Inverti per Z-A
            }
        case SortingOption.dateAdded.rawValue:
            return pacchiFilm.sorted { $0.dataAcquisto < $1.dataAcquisto } // Ordine per data di acquisto (più vecchio prima)
        case SortingOption.dateAddedReverse.rawValue:
            return pacchiFilm.sorted { $0.dataAcquisto > $1.dataAcquisto } // Ordine per data di acquisto (più recente prima)
        default:
            return pacchiFilm
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
    
    // Ottiene i pacchi film disponibili (non associati) ordinati
    var pacchiDisponibili: [FilmPack] {
        let disponibili = pacchiFilmOrdinate.filter { $0.fotocameraAssociata == nil && !$0.isFinito && !$0.isScaduto }
        return disponibili
    }
    
    // Ottiene i pacchi film in scadenza ordinati
    var pacchiInScadenza: [FilmPack] {
        let inScadenza = pacchiFilmOrdinate.filter { $0.isInScadenza }
        return inScadenza
    }
    
    // Ottiene i pacchi film scaduti ordinati
    var pacchiScaduti: [FilmPack] {
        let scaduti = pacchiFilmOrdinate.filter { $0.isScaduto }
        return scaduti
    }
    
    // Ottiene i pacchi film finiti ordinati
    var pacchiFiniti: [FilmPack] {
        let finiti = pacchiFilmOrdinate.filter { $0.isFinito }
        return finiti
    }
    
    // Salva i pacchi film in UserDefaults e iCloud
    private func salvaPacchiFilm() {
        if let encoded = try? JSONEncoder().encode(pacchiFilm) {
            UserDefaults.standard.set(encoded, forKey: "pacchiFilm")
        }
        // Notifica che i pacchi film sono cambiati
        onPacchiFilmChanged?()
        
        // Sincronizza con iCloud in background
        Task {
            await sincronizzaPacchiFilmConICloud()
        }
    }
    
    // Sincronizza i pacchi film con iCloud
    @MainActor
    private func sincronizzaPacchiFilmConICloud() async {
        print("☁️ [FilmPackViewModel] Inizio sincronizzazione pacchi film con iCloud...")
        
        do {
            try await cloudKitManager.syncFilmPacks(pacchiFilm)
            print("☁️ [FilmPackViewModel] ✅ Sincronizzazione iCloud completata")
        } catch {
            print("❌ [FilmPackViewModel] ❌ Errore sincronizzazione iCloud: \(error.localizedDescription)")
        }
    }
    
    // Carica i pacchi film da UserDefaults e iCloud
    private func caricaPacchiFilm() {
        if let data = UserDefaults.standard.data(forKey: "pacchiFilm"),
           let decoded = try? JSONDecoder().decode([FilmPack].self, from: data) {
            pacchiFilm = decoded
            // Aggiorna l'ordine stabile delle tipologie dopo aver caricato i pacchi
            inizializzaOrdineTipologieStabile()
        }
        
        // Carica anche da iCloud in background
        Task {
            await caricaPacchiFilmDaICloud()
        }
    }
    
    // Carica i pacchi film da iCloud
    @MainActor
    private func caricaPacchiFilmDaICloud() async {
        print("☁️ [FilmPackViewModel] Inizio caricamento pacchi film da iCloud...")
        
        do {
            try await cloudKitManager.syncFilmPacks(pacchiFilm)
            print("☁️ [FilmPackViewModel] ✅ Caricamento da iCloud completato")
        } catch {
            print("❌ [FilmPackViewModel] ❌ Errore caricamento da iCloud: \(error.localizedDescription)")
        }
    }
    
    // Carica i modelli di pacchi film dal JSON
    private func caricaModelli() {
        print("🔄 [FilmPackViewModel] Inizio caricamento modelli...")
        
        // Prima prova a caricare dalla cache locale
        print("🔄 [FilmPackViewModel] ===== INIZIO CARICAMENTO MODELLI =====")
        
        if let cachedModelli = DataDownloader.shared.loadFromCache(forKey: DataConfig.UserDefaultsKeys.filmPackModelsCache, type: [FilmPackModel].self) {
            modelliFilm = cachedModelli
            print("📱 [FilmPackViewModel] ✅ Cache modelli trovata: \(modelliFilm.count) modelli")
            print("📱 [FilmPackViewModel] 🔍 Primi 3 modelli:")
            for (index, modello) in modelliFilm.prefix(3).enumerated() {
                print("   \(index): ID=\(modello.id), Name=\(modello.name), film_type=\(modello.film_type ?? "nil"), gradient=\(modello.gradient != nil ? "presente" : "nil")")
            }
            print("📱 [FilmPackViewModel] 🔍 Modelli con gradienti: \(modelliFilm.filter { $0.gradient != nil }.count)")
            print("📱 [FilmPackViewModel] 🔍 Modelli senza gradienti: \(modelliFilm.filter { $0.gradient == nil }.count)")
        } else {
            print("📱 [FilmPackViewModel] ❌ Cache modelli vuota o non trovata")
        }
        
        if let cachedTipi = DataDownloader.shared.loadFromCache(forKey: DataConfig.UserDefaultsKeys.filmPackTypesCache, type: [FilmPackType].self) {
            tipiFilm = cachedTipi
            print("📱 [FilmPackViewModel] ✅ Cache tipi trovata: \(tipiFilm.count) tipi")
        } else {
            print("📱 [FilmPackViewModel] ❌ Cache tipi vuota o non trovata")
        }
        
        // Poi prova a scaricare online
        print("🌐 [FilmPackViewModel] 🚀 Avvio download online in background...")
        Task {
            await downloadModelliOnline()
        }
        print("🔄 [FilmPackViewModel] ===== FINE CARICAMENTO MODELLI =====")
    }
    
    // Scarica i modelli online
    @MainActor
    private func downloadModelliOnline() async {
        print("🌐 [FilmPackViewModel] ===== INIZIO DOWNLOAD ONLINE =====")
        print("🌐 [FilmPackViewModel] Chiamata a DataDownloader.shared.downloadFilmPackModels() e downloadFilmPackTypes()...")
        
        do {
            // Scarica entrambi i tipi di dati in parallelo
            async let filmPacks = DataDownloader.shared.downloadFilmPackModels()
            async let types = DataDownloader.shared.downloadFilmPackTypes()
            
            print("🌐 [FilmPackViewModel] ⏳ Attendo completamento download parallelo...")
            let (downloadedFilmPacks, downloadedTypes) = try await (filmPacks, types)
            
            print("🌐 [FilmPackViewModel] ✅ DOWNLOAD COMPLETATO:")
            print("   - Film Packs: \(downloadedFilmPacks.count)")
            print("   - Tipi: \(downloadedTypes.count)")
            
            // Aggiorna i tipi e modelli con i dati scaricati
            tipiFilm = downloadedTypes
            modelliFilm = downloadedFilmPacks
            
            print("✅ [FilmPackViewModel] Modelli scaricati online con successo!")
            print("📋 [FilmPackViewModel] Tipi film scaricati: \(tipiFilm.count)")
            print("📋 [FilmPackViewModel] Modelli film scaricati: \(modelliFilm.count)")
            print("📱 [FilmPackViewModel] 🔍 Primi 3 modelli scaricati:")
            for (index, modello) in modelliFilm.prefix(3).enumerated() {
                print("   \(index): ID=\(modello.id), Name=\(modello.name), film_type=\(modello.film_type ?? "nil"), gradient=\(modello.gradient != nil ? "presente" : "nil")")
            }
            print("📱 [FilmPackViewModel] 🔍 Modelli con gradienti: \(modelliFilm.filter { $0.gradient != nil }.count)")
            print("📱 [FilmPackViewModel] 🔍 Modelli senza gradienti: \(modelliFilm.filter { $0.gradient == nil }.count)")
            print("🌐 [FilmPackViewModel] ===== DOWNLOAD ONLINE COMPLETATO =====")
            
        } catch {
            print("❌ [FilmPackViewModel] ❌ ERRORE nel download online: \(error)")
            print("❌ [FilmPackViewModel] Dettagli errore: \(error.localizedDescription)")
            
            // Se non ci sono dati in cache, usa i modelli di default
            if tipiFilm.isEmpty && modelliFilm.isEmpty {
                print("⚠️ [FilmPackViewModel] Usando modelli di default perché cache vuota")
                setupModelliDefault()
            } else {
                print("📱 [FilmPackViewModel] Mantenendo dati dalla cache: \(tipiFilm.count) tipi, \(modelliFilm.count) modelli")
            }
            print("🌐 [FilmPackViewModel] ===== DOWNLOAD ONLINE FALLITO =====")
        }
    }
    
    // Test di decodifica JSON per debug
    func testDecodificaJSON() {
        print("🧪 [FilmPackViewModel] ===== TEST DECODIFICA JSON =====")
        
        // Prova a caricare il JSON locale
        if let url = Bundle.main.url(forResource: "film_pack_models", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(FilmPackModelsData.self, from: data)
                
                print("✅ [FilmPackViewModel] JSON decodificato con successo!")
                print("📋 [FilmPackViewModel] Tipi: \(jsonData.film_pack_types.count)")
                print("📋 [FilmPackViewModel] Modelli: \(jsonData.film_pack_models.count)")
                print("📱 [FilmPackViewModel] 🔍 Modelli con gradienti: \(jsonData.film_pack_models.filter { $0.gradient != nil }.count)")
                print("📱 [FilmPackViewModel] 🔍 Primi 3 modelli:")
                for (index, modello) in jsonData.film_pack_models.prefix(3).enumerated() {
                    print("   \(index): ID=\(modello.id), Name=\(modello.name), film_type=\(modello.film_type ?? "nil"), gradient=\(modello.gradient != nil ? "presente" : "nil")")
                }
                
            } catch {
                print("❌ [FilmPackViewModel] ERRORE decodifica JSON: \(error)")
                print("❌ [FilmPackViewModel] Dettagli: \(error.localizedDescription)")
            }
        } else {
            print("❌ [FilmPackViewModel] File JSON non trovato nel bundle")
        }
        
        print("🧪 [FilmPackViewModel] ===== FINE TEST DECODIFICA =====")
    }
    
    // Pulisce la cache e forza il ricaricamento
    func pulisciCacheModelli() {
        print("🧹 [FilmPackViewModel] Pulizia cache modelli...")
        DataDownloader.shared.clearCache()
        modelliFilm = []
        tipiFilm = []
        print("🧹 [FilmPackViewModel] Cache pulita, ricaricamento modelli...")
        caricaModelli()
    }
    
    // Setup modelli di default se il JSON non è disponibile
    private func setupModelliDefault() {
        print("⚠️ [FilmPackViewModel] Setup modelli di default (JSON non disponibile)")
        
        tipiFilm = [
            FilmPackType(id: "600", name: "600", default_capacity: 8, description: "Film classico compatibile con fotocamere 600 e i-Type"),
            FilmPackType(id: "itype", name: "i-Type", default_capacity: 8, description: "Film moderno senza batteria integrata"),
            FilmPackType(id: "sx70", name: "SX-70", default_capacity: 10, description: "Film per fotocamere folding SX-70"),
            FilmPackType(id: "go", name: "Go", default_capacity: 16, description: "Film compatto per fotocamera Go"),
            FilmPackType(id: "spectra", name: "Spectra", default_capacity: 10, description: "Film wide per fotocamere Spectra"),
            FilmPackType(id: "8x10", name: "8x10", default_capacity: 1, description: "Film grande formato 8x10"),
            FilmPackType(id: "4x5", name: "4x5", default_capacity: 1, description: "Film medio formato 4x5")
        ]
        
        modelliFilm = []
        print("📋 [FilmPackViewModel] Modelli di default impostati: \(modelliFilm.count) modelli")
    }
    
    // Ottiene i tipi di film disponibili
    var tipiDisponibili: [String] {
        return tipiFilm.map { $0.name }
    }
    
    // Ottiene i modelli disponibili per un tipo specifico
    func modelliPerTipo(_ tipo: String) -> [String] {
        // Usa i modelli scaricati online se disponibili, altrimenti fallback
        if !modelliFilm.isEmpty {
            let modelliPerTipo = modelliFilm.filter { 
                if let filmType = $0.film_type {
                    return filmType.lowercased() == tipo.lowercased()
                }
                return false
            }
            return modelliPerTipo.map { $0.name }
        }
        
        // Fallback ai modelli hardcoded se non ci sono dati online
        let modelliPerTipo: [String: [String]] = [
            "600": ["Color", "Black & White", "Color Frame", "Black Frame B&W", "Duochrome (Blue)", "Duochrome (Green)", "Duochrome (Yellow)", "Duochrome (Red)", "Duochrome (Orange)", "Metallic", "Gold Frame", "Silver Frame", "Round Frame", "Retro", "Vintage"],
            "i-Type": ["Color", "Black & White", "Color Frame", "Black Frame B&W", "Duochrome (Blue)", "Duochrome (Green)", "Duochrome (Yellow)", "Duochrome (Red)", "Duochrome (Orange)", "Metallic", "Gold Frame", "Silver Frame", "Round Frame", "Retro", "Vintage"],
            "SX-70": ["Color", "Black & White", "Color Frame", "Black Frame B&W", "Duochrome (Blue)", "Duochrome (Green)", "Duochrome (Yellow)", "Duochrome (Red)", "Duochrome (Orange)", "Metallic", "Gold Frame", "Silver Frame", "Round Frame", "Retro", "Vintage"],
            "Go": ["Color", "Black & White", "Color Frame", "Black Frame B&W"],
            "Spectra": ["Color", "Black & White", "Color Frame", "Black Frame B&W"],
            "8x10": ["Color", "Black & White"],
            "4x5": ["Color", "Black & White"]
        ]
        
        return modelliPerTipo[tipo] ?? ["Color", "Black & White"]
    }
    
    // Ottiene la capacità di default per un tipo di film
    func capacitaDefaultPerTipo(_ tipo: String) -> Int {
        if let tipoFilm = tipiFilm.first(where: { $0.name == tipo }) {
            return tipoFilm.default_capacity
        }
        return 8 // Default
    }
    
    // Ottiene le fotocamere compatibili per un tipo di film
    func fotocamereCompatibiliPerTipo(_ tipo: String) -> [String] {
        // Usa il fallback per ottenere le fotocamere compatibili
        let fotocamereCompatibili = isCompatibileFallback(tipo, con: "")
        // Restituisce le fotocamere compatibili dal fallback
        let compatibilitaHardcoded: [String: [String]] = [
            "600": ["Polaroid 600", "Polaroid i-Type", "Polaroid I-2"],
            "i-Type": ["Polaroid i-Type", "Polaroid 600", "Polaroid Now", "Polaroid OneStep+", "Polaroid OneStep 2", "Polaroid I-2"],
            "SX-70": ["Polaroid SX-70", "Polaroid I-2"],
            "Go": ["Polaroid Go"],
            "Spectra": ["Polaroid Spectra"],
            "8x10": ["Polaroid 8x10"],
            "4x5": ["Polaroid 4x5"]
        ]
        
        return compatibilitaHardcoded[tipo] ?? []
    }
    
    // Cache per la compatibilità con timestamp per controllo periodico
    private var compatibilitaCache: [String: (risultato: Bool, timestamp: Date)] = [:]
    private let intervalloAggiornamentoCache: TimeInterval = 1.0 // 1 secondo
    
    // Verifica se un tipo di film è compatibile con una fotocamera (con cache intelligente)
    func isCompatibile(_ tipoFilm: String, con fotocamera: Camera) -> Bool {
        // Controlla se l'utente ha attivato l'opzione per ignorare la compatibilità
        let ignoreCompatibility = UserDefaults.standard.bool(forKey: "ignoreCompatibility")
        if ignoreCompatibility {
            print("🔧 [FilmPackViewModel] Compatibilità ignorata per impostazione utente")
            return true
        }
        
        let chiaveCache = "\(tipoFilm)_\(fotocamera.id)"
        let ora = Date()
        
        // Controlla se è in cache e se è ancora valida
        if let cacheEntry = compatibilitaCache[chiaveCache] {
            let tempoTrascorso = ora.timeIntervalSince(cacheEntry.timestamp)
            
            // Se la cache è ancora valida (meno di 1 secondo), usa il risultato
            if tempoTrascorso < intervalloAggiornamentoCache {
                return cacheEntry.risultato
            }
        }
        
        // Calcola la compatibilità basata sul film_type della fotocamera
        let isCompatibile = isFilmTypeCompatibile(tipoFilm, con: fotocamera)
        
        // Aggiorna la cache con timestamp
        compatibilitaCache[chiaveCache] = (risultato: isCompatibile, timestamp: ora)
        
        // Pulisce periodicamente la cache scaduta
        pulisciCacheScaduta()
        
        return isCompatibile
    }
    
    // Verifica se un tipo di film è compatibile con una fotocamera basandosi sul film_type
    private func isFilmTypeCompatibile(_ tipoFilm: String, con fotocamera: Camera) -> Bool {
        guard let filmType = fotocamera.filmType else { 
            // Se non c'è film_type, fallback alla compatibilità basata sul nome del modello
            return isCompatibileFallback(tipoFilm, con: fotocamera.modello)
        }
        
        // Il film_type può contenere più tipi separati da "/" (es: "i-Type/600/SX70")
        let tipiSupportati = filmType.components(separatedBy: "/")
        
        // Mappa i nomi dei tipi di film ai valori del film_type
        let mappaTipi: [String: String] = [
            "600": "600",
            "i-Type": "i-Type", 
            "SX-70": "SX-70",
            "Go": "Go",
            "Spectra": "Spectra",
            "8x10": "8x10",
            "4x5": "4x5"
        ]
        
        // Verifica se il tipo di film richiesto è supportato dalla fotocamera
        if let tipoMappato = mappaTipi[tipoFilm] {
            return tipiSupportati.contains(tipoMappato)
        }
        
        return false
    }
    
    // Fallback per compatibilità basata sul nome del modello (per fotocamere senza film_type)
    private func isCompatibileFallback(_ tipoFilm: String, con modelloFotocamera: String) -> Bool {
        // Mappa di compatibilità hardcoded per fotocamere senza film_type
        let compatibilitaHardcoded: [String: [String]] = [
            "600": ["Polaroid 600", "Polaroid i-Type", "Polaroid I-2"],
            "i-Type": ["Polaroid i-Type", "Polaroid 600", "Polaroid Now", "Polaroid OneStep+", "Polaroid OneStep 2", "Polaroid I-2"],
            "SX-70": ["Polaroid SX-70", "Polaroid I-2"],
            "Go": ["Polaroid Go"],
            "Spectra": ["Polaroid Spectra"],
            "8x10": ["Polaroid 8x10"],
            "4x5": ["Polaroid 4x5"]
        ]
        
        if let fotocamereCompatibili = compatibilitaHardcoded[tipoFilm] {
            return fotocamereCompatibili.contains(modelloFotocamera)
        }
        
        return false
    }
    
    // Resetta l'ordine stabile delle tipologie (utile per debug o reset)
    func resettaOrdineTipologieStabile() {
        ordineTipologieStabile.removeAll()
        inizializzaOrdineTipologieStabile()
        print("🔒 [FilmPackViewModel] Ordine stabile tipologie resettato")
    }
    
    // Debug: stampa l'ordine stabile delle tipologie
    func debugOrdineTipologieStabile() {
        print("🔒 [FilmPackViewModel] === DEBUG ORDINE STABILE ===")
        print("🔒 [FilmPackViewModel] Ordine attuale: \(ordineTipologieStabile)")
        print("🔒 [FilmPackViewModel] Numero tipologie: \(ordineTipologieStabile.count)")
        print("🔒 [FilmPackViewModel] =========================")
    }
    
    // Inizializza l'ordine stabile delle tipologie
    // Questa funzione viene chiamata:
    // 1. All'inizializzazione del viewModel
    // 2. Dopo aver caricato i pacchi film da UserDefaults
    // 3. Quando viene resettato l'ordine stabile
    // Garantisce che l'ordine sia sempre sincronizzato con i dati esistenti
    private func inizializzaOrdineTipologieStabile() {
        guard ordineTipologieStabile.isEmpty else { return }
        
        var tipologieProcessate: Set<String> = []
        
        for pacco in pacchiFilm {
            let chiave = "\(pacco.tipo)_\(pacco.modello)"
            
            if !tipologieProcessate.contains(chiave) {
                ordineTipologieStabile.append(chiave)
                tipologieProcessate.insert(chiave)
            }
        }
        
        print("🔒 [FilmPackViewModel] Ordine stabile tipologie inizializzato: \(ordineTipologieStabile)")
    }
    
    // Proprietà per mantenere l'ordine stabile delle tipologie
    // Questa array memorizza l'ordine di prima apparizione di ogni tipologia
    // e viene utilizzato per garantire che l'ordine rimanga stabile
    // anche quando vengono aggiunti, rimossi o modificati i pacchi film
    private var ordineTipologieStabile: [String] = []
    
    // Ottiene le tipologie raggruppate per tipo e modello
    // IMPORTANTE: Manteniamo l'ordine stabile per evitare bug di navigazione
    // quando vengono aggiunti nuovi pacchi film. Il problema era che:
    // 1. L'utente navigava a una tipologia specifica
    // 2. Aggiungeva un nuovo pacco con "Add Film Pack of This Type"
    // 3. La vista passava automaticamente a un'altra tipologia
    // Questo sistema risolve il problema mantenendo l'ordine di prima apparizione
    var tipologieRaggruppate: [TipologiaPaccoFilm] {
        var tipologie: [TipologiaPaccoFilm] = []
        var tipologieProcessate: Set<String> = []
        
        // Prima crea tutte le tipologie esistenti mantenendo l'ordine di prima apparizione
        for pacco in pacchiFilmOrdinate {
            let chiave = "\(pacco.tipo)_\(pacco.modello)"
            
            if !tipologieProcessate.contains(chiave) {
                let tipologia = TipologiaPaccoFilm(tipo: pacco.tipo, modello: pacco.modello, pacchi: pacchiFilm)
                tipologie.append(tipologia)
                tipologieProcessate.insert(chiave)
            }
        }
        
        // Applica l'ordinamento personalizzato, ma mantieni stabile l'ordine per tipologie con stesso tipo
        let sortingOption = UserDefaults.standard.string(forKey: "filmPackSortingOption") ?? SortingOption.dateAdded.rawValue
        
        switch sortingOption {
        case SortingOption.alphabeticalAZ.rawValue:
            return tipologie.sorted { (first: TipologiaPaccoFilm, second: TipologiaPaccoFilm) in
                if first.tipo == second.tipo {
                    return compareStringsNatural(first.modello, second.modello)
                }
                return compareStringsNatural(first.tipo, second.tipo)
            }
        case SortingOption.alphabeticalZA.rawValue:
            return tipologie.sorted { (first: TipologiaPaccoFilm, second: TipologiaPaccoFilm) in
                if first.tipo == second.tipo {
                    return !compareStringsNatural(first.modello, second.modello) // Inverti per Z-A
                }
                return !compareStringsNatural(first.tipo, second.tipo) // Inverti per Z-A
            }
        case SortingOption.dateAdded.rawValue:
            // Ordina per data di acquisto del primo pacco di ogni tipologia (più vecchio prima)
            return tipologie.sorted { (first: TipologiaPaccoFilm, second: TipologiaPaccoFilm) in
                let firstDate = first.pacchiDellaTipologia.min(by: { (pacco1: FilmPack, pacco2: FilmPack) -> Bool in
                    return pacco1.dataAcquisto < pacco2.dataAcquisto
                })?.dataAcquisto ?? Date.distantFuture
                let secondDate = second.pacchiDellaTipologia.min(by: { (pacco1: FilmPack, pacco2: FilmPack) -> Bool in
                    return pacco1.dataAcquisto < pacco2.dataAcquisto
                })?.dataAcquisto ?? Date.distantFuture
                return firstDate < secondDate
            }
        case SortingOption.dateAddedReverse.rawValue:
            // Ordina per data di acquisto del primo pacco di ogni tipologia (più recente prima)
            return tipologie.sorted { (first: TipologiaPaccoFilm, second: TipologiaPaccoFilm) in
                let firstDate = first.pacchiDellaTipologia.min(by: { (pacco1: FilmPack, pacco2: FilmPack) -> Bool in
                    return pacco1.dataAcquisto < pacco2.dataAcquisto
                })?.dataAcquisto ?? Date.distantFuture
                let secondDate = second.pacchiDellaTipologia.min(by: { (pacco1: FilmPack, pacco2: FilmPack) -> Bool in
                    return pacco1.dataAcquisto < pacco2.dataAcquisto
                })?.dataAcquisto ?? Date.distantFuture
                return firstDate > secondDate
            }
        default:
            // Default: ordine di prima apparizione per mantenere la stabilità della navigazione
            return ordinaTipologiePerOrdineStabile(tipologie)
        }
    }
    
    // Funzione helper per mantenere l'ordine stabile delle tipologie
    // Questa funzione garantisce che l'ordine delle tipologie rimanga stabile
    // anche quando vengono aggiunti nuovi pacchi film, evitando il bug di navigazione
    // dove la vista passava a tipologie diverse dopo l'aggiunta di un pacco
    private func ordinaTipologiePerOrdineStabile(_ tipologie: [TipologiaPaccoFilm]) -> [TipologiaPaccoFilm] {
        return tipologie.sorted { first, second in
            let chiaveFirst = "\(first.tipo)_\(first.modello)"
            let chiaveSecond = "\(second.tipo)_\(second.modello)"
            
            let indexFirst = ordineTipologieStabile.firstIndex(of: chiaveFirst) ?? Int.max
            let indexSecond = ordineTipologieStabile.firstIndex(of: chiaveSecond) ?? Int.max
            
            // Se entrambe le tipologie sono nell'ordine stabile, ordina per indice
            if indexFirst != Int.max && indexSecond != Int.max {
                return indexFirst < indexSecond
            }
            
            // Se solo una è nell'ordine stabile, metti quella prima
            if indexFirst != Int.max && indexSecond == Int.max {
                return true
            }
            if indexFirst == Int.max && indexSecond != Int.max {
                return false
            }
            
            // Se nessuna è nell'ordine stabile, ordina alfabeticamente con ordinamento naturale
            if first.tipo == second.tipo {
                return compareStringsNatural(first.modello, second.modello)
            }
            return compareStringsNatural(first.tipo, second.tipo)
        }
    }
    
    // Imposta le fotocamere (chiamato dal CameraViewModel)
    func setFotocamere(_ fotocamere: [Camera]) {
        self.fotocamere = fotocamere
        // Pulisce la cache quando cambiano le fotocamere
        pulisciCacheCompatibilita()
    }
    
    // Elimina tutti i pacchi film associati a una fotocamera (quando viene eliminata)
    func eliminaPacchiFilmPerFotocamera(_ fotocameraId: UUID) {
        let pacchiDaEliminare = pacchiFilm.filter { $0.fotocameraAssociata == fotocameraId }
        
        for pacco in pacchiDaEliminare {
            if let index = pacchiFilm.firstIndex(where: { $0.id == pacco.id }) {
                pacchiFilm.remove(at: index)
                print("🗑️ Pacco film eliminato con fotocamera: \(pacco.tipo) \(pacco.modello)")
            }
        }
        
        if !pacchiDaEliminare.isEmpty {
            salvaPacchiFilm()
            pulisciCacheCompatibilita()
            print("🗑️ Eliminati \(pacchiDaEliminare.count) pacchi film associati alla fotocamera")
        }
    }
    
    // Pulisce la cache della compatibilità
    private func pulisciCacheCompatibilita() {
        compatibilitaCache.removeAll()
        print("🧹 Cache compatibilità pulita")
    }
    
    // Pulisce automaticamente la cache scaduta
    private func pulisciCacheScaduta() {
        let ora = Date()
        let chiaviDaRimuovere = compatibilitaCache.compactMap { chiave, valore in
            let tempoTrascorso = ora.timeIntervalSince(valore.timestamp)
            return tempoTrascorso >= intervalloAggiornamentoCache * 2 ? chiave : nil
        }
        
        for chiave in chiaviDaRimuovere {
            compatibilitaCache.removeValue(forKey: chiave)
        }
        
        if !chiaviDaRimuovere.isEmpty {
            print("🧹 Cache scaduta pulita: \(chiaviDaRimuovere.count) voci rimosse")
        }
    }
    
    // MARK: - Gestione Film-Fotocamera
    
    // Carica un film in una fotocamera
    func caricaFilm(_ pacco: FilmPack, in fotocamera: Camera) {
        // Trova e aggiorna il pacco film nell'array
        if let indexPacco = pacchiFilm.firstIndex(where: { $0.id == pacco.id }) {
            // Rimuovi eventuali film già caricati nella fotocamera
            if let filmCaricato = pacchiFilm.first(where: { $0.fotocameraAssociata == fotocamera.id }),
               let indexFilmCaricato = pacchiFilm.firstIndex(where: { $0.id == filmCaricato.id }) {
                pacchiFilm[indexFilmCaricato].fotocameraAssociata = nil
            }
            
            // Associa il nuovo film alla fotocamera
            pacchiFilm[indexPacco].fotocameraAssociata = fotocamera.id
            
            // Salva le modifiche
            salvaPacchiFilm()
            pulisciCacheCompatibilita()
        }
    }
    
    // Rimuovi il film da una fotocamera (espulsione)
    func rimuoviFilmDaFotocamera(_ fotocamera: Camera) {
        if let pacco = pacchiFilm.first(where: { $0.fotocameraAssociata == fotocamera.id }),
           let indexPacco = pacchiFilm.firstIndex(where: { $0.id == pacco.id }) {
            // Rimuovi completamente il pacco film (non solo disassociazione)
            pacchiFilm.remove(at: indexPacco)
            salvaPacchiFilm()
            pulisciCacheCompatibilita()
            print("🗑️ Pacco film espulso e eliminato: \(pacco.tipo) \(pacco.modello)")
        }
    }
    
    // Consuma scatti da un film
    func consumaScatti(_ numero: Int, da fotocamera: Camera) -> Bool {
        guard let pacco = pacchiFilm.first(where: { $0.fotocameraAssociata == fotocamera.id }),
              let indexPacco = pacchiFilm.firstIndex(where: { $0.id == pacco.id }) else { return false }
        
        // Aggiorna scatti rimanenti
        pacchiFilm[indexPacco].scattiRimanenti -= numero
        
        // Programma notifica di sviluppo foto
        NotificationManager.shared.scheduleDevelopmentReminder(for: pacchiFilm[indexPacco], camera: fotocamera)
        
        // Se film finito, elimina completamente il pacco
        if pacchiFilm[indexPacco].scattiRimanenti == 0 {
            // Film finito - elimina completamente il pacco
            let paccoEliminato = pacchiFilm.remove(at: indexPacco)
            
            // Salva modifiche
            salvaPacchiFilm()
            pulisciCacheCompatibilita()
            
            print("🗑️ Pacco film finito e eliminato: \(paccoEliminato.tipo) \(paccoEliminato.modello)")
            return true // Film finito
        }
        
        // Salva modifiche
        salvaPacchiFilm()
        pulisciCacheCompatibilita()
        return false // Film non finito
    }
    
    // Ottieni film caricato in una fotocamera
    func filmCaricato(in fotocamera: Camera) -> FilmPack? {
        return pacchiFilm.first { $0.fotocameraAssociata == fotocamera.id }
    }
    
    // Verifica se una fotocamera ha film caricato
    func fotocameraHaFilm(_ fotocamera: Camera) -> Bool {
        return pacchiFilm.contains { $0.fotocameraAssociata == fotocamera.id }
    }
}
