import Foundation
import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    @Published var fotocamere: [Camera] = []
    @Published var modelliDisponibili: [CameraModel] = []
    @Published var filmPackViewModel: FilmPackViewModel?
    
    init() {
        caricaModelli()
        caricaFotocamere()
        setupFilmPackViewModel()
    }
    
    // Aggiunge una nuova fotocamera
    func aggiungiFotocamera(_ fotocamera: Camera) {
        fotocamere.append(fotocamera)
        salvaFotocamere()
        filmPackViewModel?.setFotocamere(fotocamere)
    }
    
    // Crea una nuova fotocamera con i modelli disponibili
    func creaFotocamera(nickname: String, modello: String, descrizione: String? = nil, coloreIcona: String? = nil) -> Camera {
        return Camera(
            nickname: nickname,
            modello: modello,
            descrizione: descrizione,
            immagine: nil,
            coloreIcona: coloreIcona,
            modelliDisponibili: modelliDisponibili
        )
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
        if let index = fotocamere.firstIndex(where: { $0.id == fotocamera.id }) {
            fotocamere[index] = fotocamera
            salvaFotocamere()
            filmPackViewModel?.setFotocamere(fotocamere)
        }
    }
    
    // Salva le fotocamere in UserDefaults
    private func salvaFotocamere() {
        if let encoded = try? JSONEncoder().encode(fotocamere) {
            UserDefaults.standard.set(encoded, forKey: "fotocamere")
        }
    }
    
    // Carica i modelli di fotocamera dal JSON
    private func caricaModelli() {
        guard let url = Bundle.main.url(forResource: "camera_models", withExtension: "json") else {
            print("File camera_models.json non trovato")
            // Fallback: crea modelli di default se il JSON non è disponibile
            modelliDisponibili = [
                CameraModel(id: "polaroid_600", name: "Polaroid 600", capacity: 8, default_image: "camera.fill", default_icon: "camera.fill", description: "Classica fotocamera Polaroid 600", year_introduced: 1981, film_type: "600/i-Type"),
                CameraModel(id: "polaroid_sx70", name: "Polaroid SX-70", capacity: 10, default_image: "camera.aperture", default_icon: "camera.aperture", description: "Iconica fotocamera folding SX-70", year_introduced: 1972, film_type: "SX-70"),
                CameraModel(id: "polaroid_itype", name: "Polaroid i-Type", capacity: 8, default_image: "camera.metering.center", default_icon: "camera.metering.center", description: "Fotocamera moderna compatibile con film i-Type", year_introduced: 2017, film_type: "i-Type"),
                CameraModel(id: "polaroid_go", name: "Polaroid Go", capacity: 16, default_image: "camera.metering.none", default_icon: "camera.metering.none", description: "Fotocamera compatta e portatile", year_introduced: 2021, film_type: "Go"),
                CameraModel(id: "polaroid_now", name: "Polaroid Now", capacity: 8, default_image: "camera.metering.partial", default_icon: "camera.metering.partial", description: "Fotocamera moderna con autofocus", year_introduced: 2019, film_type: "i-Type"),
                CameraModel(id: "polaroid_onestep_plus", name: "Polaroid OneStep+", capacity: 8, default_image: "camera.metering.spot", default_icon: "camera.metering.spot", description: "Fotocamera con connettività Bluetooth", year_introduced: 2018, film_type: "i-Type"),
                CameraModel(id: "polaroid_onestep2", name: "Polaroid OneStep 2", capacity: 8, default_image: "camera.metering.unknown", default_icon: "camera.metering.unknown", description: "Fotocamera entry-level con design retrò", year_introduced: 2017, film_type: "i-Type")
            ]
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(CameraModelsData.self, from: data)
            modelliDisponibili = decoded.camera_models
        } catch {
            print("Errore nel caricamento dei modelli: \(error)")
            // Fallback con modelli di default in caso di errore di parsing
            modelliDisponibili = [
                CameraModel(id: "polaroid_600", name: "Polaroid 600", capacity: 8, default_image: "camera.fill", default_icon: "camera.fill", description: "Classica fotocamera Polaroid 600", year_introduced: 1981, film_type: "600/i-Type"),
                CameraModel(id: "polaroid_sx70", name: "Polaroid SX-70", capacity: 10, default_image: "camera.aperture", default_icon: "camera.aperture", description: "Iconica fotocamera folding SX-70", year_introduced: 1972, film_type: "SX-70"),
                CameraModel(id: "polaroid_itype", name: "Polaroid i-Type", capacity: 8, default_image: "camera.metering.center", default_icon: "camera.metering.center", description: "Fotocamera moderna compatibile con film i-Type", year_introduced: 2017, film_type: "i-Type"),
                CameraModel(id: "polaroid_go", name: "Polaroid Go", capacity: 16, default_image: "camera.metering.none", default_icon: "camera.metering.none", description: "Fotocamera compatta e portatile", year_introduced: 2021, film_type: "Go"),
                CameraModel(id: "polaroid_now", name: "Polaroid Now", capacity: 8, default_image: "camera.metering.partial", default_icon: "camera.metering.partial", description: "Fotocamera moderna con autofocus", year_introduced: 2019, film_type: "i-Type"),
                CameraModel(id: "polaroid_onestep_plus", name: "Polaroid OneStep+", capacity: 8, default_image: "camera.metering.spot", default_icon: "camera.metering.spot", description: "Fotocamera con connettività Bluetooth", year_introduced: 2018, film_type: "i-Type"),
                CameraModel(id: "polaroid_onestep2", name: "Polaroid OneStep 2", capacity: 8, default_image: "camera.metering.unknown", default_icon: "camera.metering.unknown", description: "Fotocamera entry-level con design retrò", year_introduced: 2017, film_type: "i-Type")
            ]
        }
    }
    
    // Carica le fotocamere da UserDefaults
    private func caricaFotocamere() {
        if let data = UserDefaults.standard.data(forKey: "fotocamere"),
           let decoded = try? JSONDecoder().decode([Camera].self, from: data) {
            fotocamere = decoded
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
            fotocamere = decoded
        }
    }
}
