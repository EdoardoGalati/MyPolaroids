# Sistema di Sincronizzazione Dati Online

## Panoramica

Questo sistema permette di scaricare automaticamente i dati delle fotocamere e dei pacchi pellicola da file JSON ospitati online, mantenendo una cache locale per il funzionamento offline.

## Funzionalità

- ✅ **Download automatico** all'apertura dell'app
- ✅ **Cache locale** per funzionamento offline
- ✅ **Sincronizzazione manuale** tramite impostazioni
- ✅ **Gestione errori** con fallback ai dati locali
- ✅ **Scadenza cache** configurabile (default: 7 giorni)

## Configurazione

### 1. Hosting dei File JSON

I file JSON devono essere ospitati online e accessibili via HTTPS. Opzioni consigliate:

- **GitHub Pages** (gratuito)
- **AWS S3** (molto economico)
- **Firebase Hosting** (gratuito)
- **Netlify** (gratuito)

### 2. Struttura dei File JSON

#### camera_models.json
```json
{
  "camera_models": [
    {
      "id": "polaroid_600",
      "name": "600",
      "brand": "Polaroid",
      "model": "600",
      "specific_model": "Original",
      "capacity": 8,
      "default_image": "camera.fill",
      "default_icon": "camera.fill",
      "year_introduced": 1981,
      "film_type": "600/i-Type"
    }
  ]
}
```

#### film_pack_models.json
```json
{
  "film_pack_types": [
    {
      "id": "600",
      "name": "600",
      "default_capacity": 8,
      "description": "Film classico compatibile con fotocamere 600 e i-Type"
    }
  ],
  "film_pack_models": [
    {
      "id": "600_color",
      "name": "Color",
      "type": "600",
      "capacity": 8,
      "description": "Film a colori classico"
    }
  ]
}
```

### 3. Aggiornamento degli URL

Modifica il file `DataConfig.swift`:

```swift
struct DataConfig {
    // Sostituisci con i tuoi URL reali
    static let cameraModelsURL = "https://tuodominio.com/camera_models.json"
    static let filmPackModelsURL = "https://tuodominio.com/film_pack_models.json"
    
    // Configurazione cache
    static let cacheExpirationDays: Int = 7
}
```

## Utilizzo

### Download Automatico

I dati vengono scaricati automaticamente:
- All'apertura dell'app
- Quando la cache è scaduta
- Quando non ci sono dati in cache

### Sincronizzazione Manuale

1. Vai in **Impostazioni**
2. Tocca **Sincronizzazione Dati**
3. Tocca **Sincronizza Ora**

### Gestione Cache

- **Cancella Cache**: Rimuove tutti i dati scaricati
- **Cache Locale**: I dati vengono salvati automaticamente
- **Scadenza**: La cache scade dopo 7 giorni (configurabile)

## Struttura del Codice

### DataDownloader.swift
Gestisce il download e la cache dei dati online.

### DataConfig.swift
Configurazione degli URL e delle impostazioni.

### DataSyncView.swift
Interfaccia utente per la gestione della sincronizzazione.

### ViewModel Aggiornati
- `CameraViewModel`: Scarica i modelli di fotocamera
- `FilmPackViewModel`: Scarica i modelli di pacco pellicola

## Gestione Errori

Il sistema gestisce automaticamente:
- **Connessione assente**: Usa i dati dalla cache
- **Server non raggiungibile**: Fallback ai dati locali
- **JSON malformato**: Mantiene i dati esistenti
- **Timeout**: Riprova con i dati in cache

## Monitoraggio

I log mostrano:
- 📱 Caricamento dalla cache
- 🌐 Download online
- ❌ Errori di connessione
- ✅ Sincronizzazione completata

## Sicurezza

- Solo connessioni HTTPS
- Timeout configurabile
- Validazione dei dati JSON
- Fallback ai dati locali

## Personalizzazione

Puoi modificare:
- **URL dei file JSON**
- **Scadenza della cache**
- **Timeout di connessione**
- **Logging e debug**

## Troubleshooting

### L'app non scarica i dati
1. Verifica la connessione internet
2. Controlla gli URL in `DataConfig.swift`
3. Verifica che i file JSON siano accessibili
4. Controlla i log per errori specifici

### Dati non aggiornati
1. Forza la sincronizzazione manuale
2. Cancella la cache e riprova
3. Verifica che i file JSON online siano aggiornati

### Errori di parsing
1. Verifica la struttura dei JSON
2. Controlla che i modelli Swift corrispondano
3. Usa i dati di fallback se necessario
