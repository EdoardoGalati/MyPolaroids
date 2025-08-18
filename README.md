# MyPolaroids 📸

Un'app iOS per gestire la propria collezione di macchine fotografiche Polaroid, sviluppata con SwiftUI.

## Caratteristiche

- **Gestione Collezione**: Aggiungi, visualizza e rimuovi fotocamere Polaroid
- **Modelli Predefiniti**: Supporto per i modelli più popolari (600, SX-70, i-Type, Go, Now, OneStep+)
- **Capienza Automatica**: Calcolo automatico degli scatti disponibili in base al modello
- **Nickname Personalizzati**: Assegna nomi personalizzati alle tue fotocamere
- **Descrizioni**: Aggiungi note e descrizioni personalizzate
- **Interfaccia Moderna**: Design pulito e intuitivo con SwiftUI
- **Persistenza Locale**: Salvataggio automatico dei dati in locale

## Modelli Supportati

- **Polaroid 600**: 8 scatti
- **Polaroid SX-70**: 10 scatti  
- **Polaroid i-Type**: 8 scatti
- **Polaroid Go**: 16 scatti
- **Polaroid Now**: 8 scatti
- **Polaroid OneStep+**: 8 scatti
- **Polaroid OneStep 2**: 8 scatti

## Struttura del Progetto

```
MyPolaroids/
├── Camera.swift                 # Modello dati per le fotocamere
├── CameraViewModel.swift        # ViewModel per la logica dell'app
├── ListaFotocamereView.swift   # Vista principale con lista fotocamere
├── AggiungiFotocameraView.swift # Form per aggiungere nuove fotocamere
├── DettagliFotocameraView.swift # Vista dettagli fotocamera
├── SF Symbols Extensions.swift  # Estensioni per le icone personalizzate
└── ContentView.swift           # Vista principale dell'app
```

## Funzionalità Principali

### 📱 Vista Principale
- Lista di tutte le fotocamere con nickname, modello e capienza
- Stato vuoto con messaggio di benvenuto
- Pulsante "+" per aggiungere nuove fotocamere

### ➕ Aggiunta Fotocamera
- Form completo per inserimento dati
- Selezione modello da lista predefinita
- Calcolo automatico della capienza
- Campo descrizione opzionale
- Validazione dei dati inseriti

### 🗑️ Gestione Fotocamere
- Eliminazione tramite swipe
- Navigazione ai dettagli completi
- Visualizzazione di tutte le informazioni

### 💾 Persistenza Dati
- Salvataggio automatico in UserDefaults
- Caricamento automatico all'avvio
- Codifica/decodifica JSON per i dati

## Tecnologie Utilizzate

- **SwiftUI**: Interfaccia utente moderna e dichiarativa
- **Combine**: Gestione dello stato reattivo
- **UserDefaults**: Persistenza dati locale semplice
- **SF Symbols**: Icone native di sistema personalizzate

## Requisiti

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installazione

1. Clona il repository
2. Apri `MyPolaroids.xcodeproj` in Xcode
3. Seleziona il target e il simulatore
4. Premi ⌘+R per eseguire l'app

## Roadmap Futura

- [ ] Gestione inventario pacchi film
- [ ] Associazione fotocamere-pacchi
- [ ] Cronologia scatti
- [ ] Backup e sincronizzazione iCloud
- [ ] Widget per Home Screen
- [ ] Notifiche per scadenza film

## Contributi

L'app è attualmente in fase di sviluppo. Le funzionalità di gestione inventario e associazioni verranno implementate nelle prossime versioni.

---

Sviluppato con ❤️ per gli amanti della fotografia analogica
