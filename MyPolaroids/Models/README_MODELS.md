# Gestione Modelli Fotocamera 📸

## File JSON Configurabile

Il file `camera_models.json` contiene tutti i modelli di fotocamera disponibili nell'app. Puoi modificarlo per:

- ✅ **Aggiungere nuovi modelli**
- ✅ **Modificare dati esistenti**
- ✅ **Cambiare icone di default**
- ✅ **Aggiornare capacità e descrizioni**

## Struttura del JSON

```json
{
  "camera_models": [
    {
      "id": "identificativo_univoco",
      "name": "Nome Visualizzato",
      "capacity": 8,
      "default_image": "nome_icona_sf_symbols",
      "description": "Descrizione del modello",
      "year_introduced": 1981,
      "film_type": "Tipo di film compatibile"
    }
  ]
}
```

## Campi Disponibili

| Campo | Tipo | Obbligatorio | Descrizione |
|-------|------|--------------|-------------|
| `id` | String | ✅ | Identificativo univoco (es: "polaroid_600") |
| `name` | String | ✅ | Nome visualizzato nell'app |
| `capacity` | Integer | ✅ | Numero di scatti disponibili |
| `default_image` | String | ✅ | Nome icona SF Symbols |
| `description` | String | ✅ | Descrizione del modello |
| `year_introduced` | Integer | ✅ | Anno di introduzione |
| `film_type` | String | ✅ | Tipo di film compatibile |

## Icone SF Symbols Disponibili

Puoi utilizzare qualsiasi icona di SF Symbols. Ecco alcune suggerite per le fotocamere:

- `camera.fill` - Fotocamera generica
- `camera.aperture` - Fotocamera con apertura
- `camera.metering.center` - Fotocamera con metering
- `camera.metering.none` - Fotocamera semplice
- `camera.metering.partial` - Fotocamera avanzata
- `camera.metering.spot` - Fotocamera professionale
- `camera.metering.unknown` - Fotocamera sconosciuta

## Esempio di Aggiunta Nuovo Modello

```json
{
  "id": "polaroid_spectra",
  "name": "Polaroid Spectra",
  "capacity": 10,
  "default_image": "camera.aperture",
  "description": "Fotocamera Spectra con film wide",
  "year_introduced": 1986,
  "film_type": "Spectra"
}
```

## Come Modificare

1. **Apri** `camera_models.json` nella cartella principale del progetto
2. **Modifica** i campi desiderati
3. **Salva** il file
4. **Riavvia** l'app per vedere le modifiche

**Nota**: Il file si trova in `MyPolaroids/camera_models.json`

## Note Importanti

- ⚠️ **Non rimuovere** il campo `id` o `name`
- ⚠️ **Mantieni** la struttura JSON valida
- ⚠️ **Riavvia** sempre l'app dopo modifiche
- ✅ **Backup** del file prima di modifiche importanti

## Ricerca Icone SF Symbols

Per trovare nuove icone:
1. Apri **Xcode**
2. Vai su **Editor → SF Symbols**
3. Cerca icone relative a "camera"
4. Copia il nome dell'icona desiderata

---

💡 **Suggerimento**: Mantieni sempre una copia di backup del file JSON originale!
