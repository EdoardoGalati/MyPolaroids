# Gestione Modelli Pacchi Film 🎞️

## File JSON Configurabile

Il file `film_pack_models.json` contiene tutti i tipi e modelli di pacchi film disponibili nell'app. Puoi modificarlo per:

- ✅ **Aggiungere nuovi tipi di film**
- ✅ **Modificare capacità di default**
- ✅ **Aggiornare compatibilità fotocamere**
- ✅ **Aggiungere nuovi modelli di film**
- ✅ **Personalizzare descrizioni e categorie**

## Struttura del JSON

```json
{
  "film_pack_types": [
    {
      "id": "identificativo_univoco",
      "name": "Nome Visualizzato",
      "default_capacity": 8,
      "compatible_cameras": ["Lista fotocamere compatibili"],
      "description": "Descrizione del tipo di film"
    }
  ],
  "film_pack_models": [
    {
      "id": "identificativo_univoco",
      "name": "Nome Visualizzato",
      "description": "Descrizione del modello",
      "category": "Categoria del modello"
    }
  ]
}
```

## Campi Disponibili

### Film Pack Types
| Campo | Tipo | Obbligatorio | Descrizione |
|-------|------|--------------|-------------|
| `id` | String | ✅ | Identificativo univoco (es: "600", "itype") |
| `name` | String | ✅ | Nome visualizzato nell'app |
| `default_capacity` | Integer | ✅ | Numero di scatti di default |
| `compatible_cameras` | Array | ✅ | Lista delle fotocamere compatibili |
| `description` | String | ✅ | Descrizione del tipo di film |

### Film Pack Models
| Campo | Tipo | Obbligatorio | Descrizione |
|-------|------|--------------|-------------|
| `id` | String | ✅ | Identificativo univoco (es: "color", "black_white") |
| `name` | String | ✅ | Nome visualizzato nell'app |
| `description` | String | ✅ | Descrizione del modello |
| `category` | String | ✅ | Categoria (standard, monochrome, framed, duochrome, special) |

## Capacità di Default per Tipo

- **600/i-Type**: 8 scatti
- **SX-70**: 10 scatti
- **Go**: 16 scatti
- **Spectra**: 10 scatti
- **8x10/4x5**: 1 scatto

## Categorie Modelli Disponibili

- **standard**: Film base (Color, Black & White)
- **monochrome**: Bianco e nero
- **framed**: Film con cornici speciali
- **duochrome**: Film monocromatici colorati
- **special**: Effetti speciali (Metallic, Retro, Vintage)

## Esempio di Aggiunta Nuovo Tipo

```json
{
  "id": "instax_mini",
  "name": "Instax Mini",
  "default_capacity": 10,
  "compatible_cameras": ["Instax Mini 9", "Instax Mini 11"],
  "description": "Film compatto per fotocamere Instax Mini"
}
```

## Esempio di Aggiunta Nuovo Modello

```json
{
  "id": "pastel_colors",
  "name": "Pastel Colors",
  "description": "Film con colori pastello",
  "category": "special"
}
```

## Come Modificare

1. **Apri** `film_pack_models.json` nella cartella principale del progetto
2. **Modifica** i campi desiderati
3. **Salva** il file
4. **Riavvia** l'app per vedere le modifiche

**Nota**: Il file si trova in `MyPolaroids/film_pack_models.json`

## Note Importanti

- ⚠️ **Non rimuovere** i campi `id` o `name`
- ⚠️ **Mantieni** la struttura JSON valida
- ⚠️ **Riavvia** sempre l'app dopo modifiche
- ✅ **Backup** del file prima di modifiche importanti
- ✅ **Capacità realistiche** per ogni tipo di film

## Compatibilità Fotocamere

Assicurati che le fotocamere elencate in `compatible_cameras` corrispondano esattamente ai nomi delle fotocamere nell'app. Le compatibilità vengono verificate automaticamente.

---

💡 **Suggerimento**: Mantieni sempre una copia di backup del file JSON originale!
