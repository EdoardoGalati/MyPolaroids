import Foundation

struct TipologiaPaccoFilm: Identifiable {
    let id: String
    let tipo: String
    let modello: String
    let conteggioTotale: Int
    let scattiDisponibili: Int
    let pacchiDisponibili: Int
    let pacchiInScadenza: Int
    let pacchiScaduti: Int
    let pacchiCompletati: Int
    
    init(tipo: String, modello: String, pacchi: [FilmPack]) {
        self.id = "\(tipo)_\(modello)"
        self.tipo = tipo
        self.modello = modello
        
        // Filtra i pacchi di questa tipologia
        let pacchiTipologia = pacchi.filter { $0.tipo == tipo && $0.modello == modello }
        
        self.conteggioTotale = pacchiTipologia.count
        
        // Calcola scatti disponibili totali
        self.scattiDisponibili = pacchiTipologia.reduce(0) { total, pacco in
            total + pacco.scattiRimanenti
        }
        
        // Conta pacchi per stato
        self.pacchiDisponibili = pacchiTipologia.filter { pacco in
            pacco.scattiRimanenti > 0 && 
            (pacco.dataScadenza == nil || pacco.dataScadenza! > Date())
        }.count
        
        self.pacchiInScadenza = pacchiTipologia.filter { pacco in
            pacco.scattiRimanenti > 0 && 
            pacco.dataScadenza != nil && 
            pacco.dataScadenza! <= Date().addingTimeInterval(30 * 24 * 3600) && // 30 giorni
            pacco.dataScadenza! > Date()
        }.count
        
        self.pacchiScaduti = pacchiTipologia.filter { pacco in
            pacco.scattiRimanenti > 0 && 
            pacco.dataScadenza != nil && 
            pacco.dataScadenza! <= Date()
        }.count
        
        self.pacchiCompletati = pacchiTipologia.filter { pacco in
            pacco.scattiRimanenti == 0
        }.count
    }
}
