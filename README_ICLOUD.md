# 🔄 Sincronizzazione iCloud - MyPolaroids

## 📋 Panoramica

Questa implementazione aggiunge la sincronizzazione automatica dei dati tra dispositivi tramite iCloud e CloudKit. I tuoi dati (fotocamere e pacchi film) si sincronizzeranno automaticamente tra tutti i tuoi dispositivi iOS e macOS.

## ✨ Funzionalità

- **Sincronizzazione automatica** in background
- **Gestione conflitti** intelligente
- **Stato sincronizzazione** in tempo reale
- **Sincronizzazione manuale** su richiesta
- **Gestione errori** robusta
- **Compatibilità** con i dati esistenti

## 🚀 Configurazione

### 1. Abilita iCloud nel Progetto Xcode

1. Apri il progetto in Xcode
2. Seleziona il target `MyPolaroids`
3. Vai su **Signing & Capabilities**
4. Clicca **+ Capability**
5. Aggiungi **iCloud**
6. Spunta **CloudKit**
7. Configura il container iCloud: `iCloud.Heterochrmia.Instantbox.com`

### 2. File Entitlements

Il file `MyPolaroids.entitlements` è già configurato con:
- CloudKit abilitato
- Container iCloud configurato
- Permessi per la sincronizzazione

### 3. Bundle Identifier

Assicurati che il Bundle Identifier sia coerente con il container iCloud:
- Bundle ID: `com.Heterochrmia.Instantbox` (o simile)
- Container iCloud: `iCloud.Heterochrmia.Instantbox.com`

## 🏗️ Architettura

### CloudKitManager
Gestisce tutta la logica di sincronizzazione:
- Connessione a iCloud
- Upload/download dati
- Gestione conflitti
- Monitoraggio stato

### CloudKitConfig
Configurazione centralizzata per:
- Record types
- Field names
- Query predicates
- Gestione errori

### Integrazione ViewModel
I ViewModel esistenti sono stati estesi per:
- Salvataggio automatico in iCloud
- Caricamento da iCloud
- Sincronizzazione trasparente

## 📱 Utilizzo

### Sincronizzazione Automatica
I dati si sincronizzano automaticamente quando:
- Aggiungi una nuova fotocamera
- Modifichi una fotocamera esistente
- Aggiungi un nuovo pacco film
- Modifichi un pacco film esistente

### Sincronizzazione Manuale
1. Vai su **Impostazioni**
2. Tocca **Sincronizzazione iCloud**
3. Tocca **Sincronizza ora**

### Monitoraggio Stato
La vista **Sincronizzazione iCloud** mostra:
- Stato connessione iCloud
- Ultima sincronizzazione
- Errori di sincronizzazione
- Stato sincronizzazione corrente

## 🔧 Risoluzione Problemi

### Errore "Account iCloud non disponibile"
1. Verifica di essere connesso a iCloud
2. Controlla la connessione internet
3. Riavvia l'app

### Errore "Permessi iCloud negati"
1. Vai su **Impostazioni > iCloud**
2. Abilita **CloudKit** per MyPolaroids
3. Riavvia l'app

### Sincronizzazione lenta
- La prima sincronizzazione può richiedere tempo
- Verifica la connessione internet
- Assicurati di avere spazio iCloud sufficiente

### Dati non sincronizzati
1. Forza una sincronizzazione manuale
2. Verifica lo stato iCloud
3. Controlla i log dell'app per errori

## 📊 Struttura Dati CloudKit

### Record Type: Camera
```json
{
  "cameraData": "JSON encoded Camera object",
  "deviceID": "unique device identifier",
  "modificationDate": "timestamp",
  "cameraID": "UUID string"
}
```

### Record Type: FilmPack
```json
{
  "filmPackData": "JSON encoded FilmPack object",
  "deviceID": "unique device identifier",
  "modificationDate": "timestamp",
  "filmPackID": "UUID string"
}
```

## 🔒 Sicurezza e Privacy

- **Dati privati**: I dati sono salvati nel database privato iCloud
- **Crittografia**: Tutti i dati sono crittografati in transito e a riposo
- **Accesso limitato**: Solo tu puoi accedere ai tuoi dati
- **Nessun tracking**: Apple non traccia i tuoi dati personali

## 📈 Performance

### Ottimizzazioni Implementate
- **Batch operations** per upload multipli
- **Query ottimizzate** con indici appropriati
- **Sincronizzazione asincrona** per non bloccare l'UI
- **Gestione memoria** efficiente

### Limiti CloudKit
- **Rate limiting**: Max 40 richieste/secondo
- **Dimensione record**: Max 1MB per record
- **Quota**: Limitata dallo spazio iCloud disponibile

## 🧪 Testing

### Test Locali
1. Simulatore iOS con account iCloud di test
2. Verifica sincronizzazione tra simulatore e dispositivo
3. Test gestione errori e conflitti

### Test Produzione
1. Account iCloud reale
2. Test su dispositivi multipli
3. Verifica sincronizzazione in background

## 🔄 Aggiornamenti Futuri

### Funzionalità Pianificate
- **Sincronizzazione selettiva** (solo dati specifici)
- **Gestione conflitti avanzata** (merge intelligente)
- **Sincronizzazione offline** (queue per quando offline)
- **Notifiche push** per aggiornamenti
- **Backup automatico** periodico

### Miglioramenti Performance
- **Compressione dati** per ridurre uso banda
- **Cache intelligente** per dati frequentemente usati
- **Sincronizzazione incrementale** (solo modifiche)

## 📚 Risorse Utili

- [CloudKit Documentation](https://developer.apple.com/cloudkit/)
- [iCloud Developer Guide](https://developer.apple.com/icloud/)
- [CloudKit Best Practices](https://developer.apple.com/documentation/cloudkit/cloudkit_best_practices)

## 🤝 Supporto

Per problemi o domande:
1. Controlla i log dell'app
2. Verifica la configurazione iCloud
3. Controlla la connessione internet
4. Riavvia l'app e riprova

---

**Nota**: Questa implementazione richiede iOS 15.0+ e un account iCloud attivo.
