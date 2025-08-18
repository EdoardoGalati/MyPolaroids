import Foundation
import Combine

class FilmPackViewModel: ObservableObject {
    @Published var pacchiFilm: [FilmPack] = []
    @Published var fotocamere: [Camera] = []
    @Published var tipiFilm: [FilmPackType] = []
    @Published var modelliFilm: [FilmPackModel] = []
    
    var onPacchiFilmChanged: (() -> Void)?
    
    init() {
        caricaModelli()
        caricaPacchiFilm()
    }
    
    // Aggiunge un nuovo pacco film
    func aggiungiPaccoFilm(_ pacco: FilmPack) {
        pacchiFilm.append(pacco)
        salvaPacchiFilm()
        pulisciCacheCompatibilita()
    }
    
    // Aggiunge un nuovo pacco film all'inizio della lista
    func aggiungiPaccoFilmInCima(_ pacco: FilmPack) {
        pacchiFilm.insert(pacco, at: 0)
        salvaPacchiFilm()
        pulisciCacheCompatibilita()
    }
    
    // Rimuove un pacco film
    func rimuoviPaccoFilm(_ pacco: FilmPack) {
        if let index = pacchiFilm.firstIndex(where: { $0.id == pacco.id }) {
            pacchiFilm.remove(at: index)
            salvaPacchiFilm()
            pulisciCacheCompatibilita()
        }
    }
    
    // Aggiorna un pacco film esistente
    func aggiornaPaccoFilm(_ pacco: FilmPack) {
        if let index = pacchiFilm.firstIndex(where: { $0.id == pacco.id }) {
            pacchiFilm[index] = pacco
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
            return pacchiFilm.sorted { "\($0.tipo) \($0.modello)".lowercased() < "\($1.tipo) \($1.modello)".lowercased() }
        case SortingOption.alphabeticalZA.rawValue:
            return pacchiFilm.sorted { "\($0.tipo) \($0.modello)".lowercased() > "\($1.tipo) \($1.modello)".lowercased() }
        case SortingOption.dateAdded.rawValue:
            return pacchiFilm // Ordine originale di aggiunta
        case SortingOption.dateAddedReverse.rawValue:
            return pacchiFilm.reversed() // Ordine inverso di aggiunta
        default:
            return pacchiFilm
        }
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
    
    // Salva i pacchi film in UserDefaults
    private func salvaPacchiFilm() {
        if let encoded = try? JSONEncoder().encode(pacchiFilm) {
            UserDefaults.standard.set(encoded, forKey: "pacchiFilm")
        }
        // Notifica che i pacchi film sono cambiati
        onPacchiFilmChanged?()
    }
    
    // Carica i pacchi film da UserDefaults
    private func caricaPacchiFilm() {
        if let data = UserDefaults.standard.data(forKey: "pacchiFilm"),
           let decoded = try? JSONDecoder().decode([FilmPack].self, from: data) {
            pacchiFilm = decoded
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
            let modelliPerTipo = modelliFilm.filter { $0.category.lowercased() == tipo.lowercased() }
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
    
    // Ottiene le tipologie raggruppate per tipo e modello
    var tipologieRaggruppate: [TipologiaPaccoFilm] {
        var tipologie: [TipologiaPaccoFilm] = []
        var tipologieProcessate: Set<String> = []
        
        for pacco in pacchiFilmOrdinate {
            let chiave = "\(pacco.tipo)_\(pacco.modello)"
            
            if !tipologieProcessate.contains(chiave) {
                let tipologia = TipologiaPaccoFilm(tipo: pacco.tipo, modello: pacco.modello, pacchi: pacchiFilm)
                tipologie.append(tipologia)
                tipologieProcessate.insert(chiave)
            }
        }
        
        // Applica l'ordinamento personalizzato
        let sortingOption = UserDefaults.standard.string(forKey: "filmPackSortingOption") ?? SortingOption.dateAdded.rawValue
        
        switch sortingOption {
        case SortingOption.alphabeticalAZ.rawValue:
            return tipologie.sorted { first, second in
                if first.tipo == second.tipo {
                    return first.modello < second.modello
                }
                return first.tipo < second.tipo
            }
        case SortingOption.alphabeticalZA.rawValue:
            return tipologie.sorted { first, second in
                if first.tipo == second.tipo {
                    return first.modello > second.modello
                }
                return first.tipo > second.tipo
            }
        case SortingOption.dateAdded.rawValue:
            return tipologie // Mantiene l'ordine di aggiunta
        case SortingOption.dateAddedReverse.rawValue:
            return tipologie.reversed() // Ordine inverso di aggiunta
        default:
            return tipologie.sorted { first, second in
                if first.tipo == second.tipo {
                    return first.modello < second.modello
                }
                return first.tipo < second.tipo
            }
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
