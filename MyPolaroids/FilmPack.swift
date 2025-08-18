import Foundation

struct FilmPack: Identifiable, Codable {
    let id: UUID
    var tipo: String
    var modello: String
    var colore: String?
    var scattiTotali: Int
    var scattiRimanenti: Int
    var dataAcquisto: Date
    var dataScadenza: Date?
    var fotocameraAssociata: UUID?
    var note: String?
    
    init(tipo: String, modello: String, colore: String? = nil, scattiTotali: Int, dataAcquisto: Date = Date(), dataScadenza: Date? = nil, fotocameraAssociata: UUID? = nil, note: String? = nil) {
        self.id = UUID()
        self.tipo = tipo
        self.modello = modello
        self.colore = colore
        self.scattiTotali = scattiTotali
        self.scattiRimanenti = scattiTotali
        self.dataAcquisto = dataAcquisto
        self.dataScadenza = dataScadenza
        self.fotocameraAssociata = fotocameraAssociata
        self.note = note
    }
    
    // Calcola i giorni rimanenti alla scadenza
    var giorniAllaScadenza: Int? {
        guard let scadenza = dataScadenza else { return nil }
        let calendar = Calendar.current
        let oggi = Date()
        
        // Normalizza le date per confrontare solo giorno/mese/anno
        let oggiNormalizzata = calendar.startOfDay(for: oggi)
        let scadenzaNormalizzata = calendar.startOfDay(for: scadenza)
        
        let components = calendar.dateComponents([.day], from: oggiNormalizzata, to: scadenzaNormalizzata)
        return components.day
    }
    
    // Verifica se il pacco è scaduto
    var isScaduto: Bool {
        guard let scadenza = dataScadenza else { return false }
        let calendar = Calendar.current
        let oggi = Date()
        
        // Normalizza le date per confrontare solo giorno/mese/anno
        let oggiNormalizzata = calendar.startOfDay(for: oggi)
        let scadenzaNormalizzata = calendar.startOfDay(for: scadenza)
        
        return oggiNormalizzata > scadenzaNormalizzata
    }
    
    // Verifica se il pacco è in scadenza (entro 30 giorni)
    var isInScadenza: Bool {
        guard let giorni = giorniAllaScadenza else { return false }
        return giorni <= 30 && giorni >= 0
    }
    
    // Verifica se il pacco scade oggi
    var isScadenzaOggi: Bool {
        guard let scadenza = dataScadenza else { return false }
        let calendar = Calendar.current
        let oggi = Date()
        
        // Normalizza le date per confrontare solo giorno/mese/anno
        let oggiNormalizzata = calendar.startOfDay(for: oggi)
        let scadenzaNormalizzata = calendar.startOfDay(for: scadenza)
        
        return calendar.isDate(oggiNormalizzata, inSameDayAs: scadenzaNormalizzata)
    }
    
    // Verifica se il pacco è finito
    var isFinito: Bool {
        return scattiRimanenti == 0
    }
    
    // Verifica se il pacco è in uso
    var isInUso: Bool {
        return fotocameraAssociata != nil
    }
    
    // Calcola la percentuale di utilizzo
    var percentualeUtilizzo: Double {
        guard scattiTotali > 0 else { return 0 }
        return Double(scattiTotali - scattiRimanenti) / Double(scattiTotali) * 100
    }
    
    // Metodi statici per compatibilità e utilità
    // Questi verranno sostituiti dai dati del JSON
    
    // Calcola la data di scadenza di default (2 anni dall'acquisto)
    static func calcolaScadenzaDefault(dataAcquisto: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .year, value: 2, to: dataAcquisto) ?? dataAcquisto
    }
}
