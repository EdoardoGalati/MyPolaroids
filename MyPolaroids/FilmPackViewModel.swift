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
    
    // Ottiene i pacchi film disponibili (non associati)
    var pacchiDisponibili: [FilmPack] {
        return pacchiFilm.filter { $0.fotocameraAssociata == nil && !$0.isFinito && !$0.isScaduto }
    }
    
    // Ottiene i pacchi film in scadenza
    var pacchiInScadenza: [FilmPack] {
        return pacchiFilm.filter { $0.isInScadenza }
    }
    
    // Ottiene i pacchi film scaduti
    var pacchiScaduti: [FilmPack] {
        return pacchiFilm.filter { $0.isScaduto }
    }
    
    // Ottiene i pacchi film finiti
    var pacchiFiniti: [FilmPack] {
        return pacchiFilm.filter { $0.isFinito }
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
        guard let url = Bundle.main.url(forResource: "film_pack_models", withExtension: "json") else {
            print("File film_pack_models.json non trovato")
            // Fallback: crea modelli di default se il JSON non è disponibile
            setupModelliDefault()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(FilmPackModelsData.self, from: data)
            tipiFilm = decoded.film_pack_types
            modelliFilm = decoded.film_pack_models
        } catch {
            print("Errore nel caricamento dei modelli: \(error)")
            setupModelliDefault()
        }
    }
    
    // Setup modelli di default se il JSON non è disponibile
    private func setupModelliDefault() {
        tipiFilm = [
            FilmPackType(id: "600", name: "600", default_capacity: 8, compatible_cameras: ["Polaroid 600", "Polaroid i-Type"], description: "Film classico compatibile con fotocamere 600 e i-Type"),
            FilmPackType(id: "itype", name: "i-Type", default_capacity: 8, compatible_cameras: ["Polaroid i-Type", "Polaroid 600", "Polaroid Now", "Polaroid OneStep+", "Polaroid OneStep 2"], description: "Film moderno senza batteria integrata"),
            FilmPackType(id: "sx70", name: "SX-70", default_capacity: 10, compatible_cameras: ["Polaroid SX-70"], description: "Film per fotocamere folding SX-70"),
            FilmPackType(id: "go", name: "Go", default_capacity: 16, compatible_cameras: ["Polaroid Go"], description: "Film compatto per fotocamera Go"),
            FilmPackType(id: "spectra", name: "Spectra", default_capacity: 10, compatible_cameras: ["Polaroid Spectra"], description: "Film wide per fotocamere Spectra"),
            FilmPackType(id: "8x10", name: "8x10", default_capacity: 1, compatible_cameras: ["Polaroid 8x10"], description: "Film grande formato 8x10"),
            FilmPackType(id: "4x5", name: "4x5", default_capacity: 1, compatible_cameras: ["Polaroid 4x5"], description: "Film medio formato 4x5")
        ]
        
        modelliFilm = [
            FilmPackModel(id: "color", name: "Color", description: "Film a colori standard Polaroid", category: "standard", colors: ["rosso", "blu", "giallo", "verde"]),
            FilmPackModel(id: "black_white", name: "Black & White", description: "Film bianco e nero classico", category: "monochrome", colors: ["grigioScuro", "nero"]),
            FilmPackModel(id: "black_frame_bw", name: "Black Frame B&W", description: "Bianco e nero con cornice nera", category: "monochrome", colors: ["grigioScuro", "nero", "bianco"]),
            FilmPackModel(id: "color_frame", name: "Color Frame", description: "Film con cornice colorata", category: "framed", colors: ["rosso", "blu", "giallo", "verde", "rosa"]),
            FilmPackModel(id: "duochrome_blue", name: "Duochrome (Blue)", description: "Film monocromatico blu", category: "duochrome", colors: ["blu", "ciano"]),
            FilmPackModel(id: "duochrome_green", name: "Duochrome (Green)", description: "Film monocromatico verde", category: "duochrome", colors: ["verde", "giallo"]),
            FilmPackModel(id: "duochrome_yellow", name: "Duochrome (Yellow)", description: "Film monocromatico giallo", category: "duochrome", colors: ["giallo", "arancione"]),
            FilmPackModel(id: "duochrome_red", name: "Duochrome (Red)", description: "Film monocromatico rosso", category: "duochrome", colors: ["rosso", "rosa"]),
            FilmPackModel(id: "duochrome_orange", name: "Duochrome (Orange)", description: "Film monocromatico arancione", category: "duochrome", colors: ["arancione", "giallo"]),
            FilmPackModel(id: "metallic", name: "Metallic", description: "Film con effetto metallizzato", category: "special", colors: ["argento", "oro"]),
            FilmPackModel(id: "gold_frame", name: "Gold Frame", description: "Film con cornice dorata", category: "framed", colors: ["oro", "giallo", "beige"]),
            FilmPackModel(id: "silver_frame", name: "Silver Frame", description: "Film con cornice argentata", category: "framed", colors: ["argento", "grigio", "bianco"]),
            FilmPackModel(id: "round_frame", name: "Round Frame", description: "Film con cornice rotonda", category: "framed", colors: ["blu", "verde", "giallo", "rosso"]),
            FilmPackModel(id: "retro", name: "Retro", description: "Film con stile retrò", category: "special", colors: ["marrone", "beige", "crema"]),
            FilmPackModel(id: "vintage", name: "Vintage", description: "Film con stile vintage", category: "special", colors: ["marrone", "grigio", "beige"])
        ]
    }
    
    // Ottiene i tipi di film disponibili
    var tipiDisponibili: [String] {
        return tipiFilm.map { $0.name }
    }
    
    // Ottiene i modelli disponibili per un tipo specifico
    func modelliPerTipo(_ tipo: String) -> [String] {
        return modelliFilm.map { $0.name }
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
        if let tipoFilm = tipiFilm.first(where: { $0.name == tipo }) {
            return tipoFilm.compatible_cameras
        }
        return []
    }
    
    // Cache per la compatibilità con timestamp per controllo periodico
    private var compatibilitaCache: [String: (risultato: Bool, timestamp: Date)] = [:]
    private let intervalloAggiornamentoCache: TimeInterval = 1.0 // 1 secondo
    
    // Verifica se un tipo di film è compatibile con una fotocamera (con cache intelligente)
    func isCompatibile(_ tipoFilm: String, con fotocamera: String) -> Bool {
        let chiaveCache = "\(tipoFilm)_\(fotocamera)"
        let ora = Date()
        
        // Controlla se è in cache e se è ancora valida
        if let cacheEntry = compatibilitaCache[chiaveCache] {
            let tempoTrascorso = ora.timeIntervalSince(cacheEntry.timestamp)
            
            // Se la cache è ancora valida (meno di 1 secondo), usa il risultato
            if tempoTrascorso < intervalloAggiornamentoCache {
                return cacheEntry.risultato
            }
        }
        
        // Calcola la compatibilità (nuova o cache scaduta)
        let fotocamereCompatibili = fotocamereCompatibiliPerTipo(tipoFilm)
        let isCompatibile = fotocamereCompatibili.contains(fotocamera)
        
        // Aggiorna la cache con timestamp
        compatibilitaCache[chiaveCache] = (risultato: isCompatibile, timestamp: ora)
        
        // Debug: stampa solo quando aggiorna la cache
    //    print("🔄 Aggiornamento cache compatibilità: tipo '\(tipoFilm)' con fotocamera '\(fotocamera)'")
    //    print("   📸 Fotocamere compatibili: \(fotocamereCompatibili)")
    //    print("   ✅ Risultato: \(isCompatibile)")
        
        // Pulisce periodicamente la cache scaduta
        pulisciCacheScaduta()
        
        return isCompatibile
    }
    
    // Ottiene le tipologie raggruppate per tipo e modello
    var tipologieRaggruppate: [TipologiaPaccoFilm] {
        var tipologie: [TipologiaPaccoFilm] = []
        var tipologieProcessate: Set<String> = []
        
        for pacco in pacchiFilm {
            let chiave = "\(pacco.tipo)_\(pacco.modello)"
            
            if !tipologieProcessate.contains(chiave) {
                let tipologia = TipologiaPaccoFilm(tipo: pacco.tipo, modello: pacco.modello, pacchi: pacchiFilm)
                tipologie.append(tipologia)
                tipologieProcessate.insert(chiave)
            }
        }
        
        // Ordina per tipo e poi per modello
        return tipologie.sorted { first, second in
            if first.tipo == second.tipo {
                return first.modello < second.modello
            }
            return first.tipo < second.tipo
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
